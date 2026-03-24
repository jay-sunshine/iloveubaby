import argparse
import os
import sys

import bpy


def parse_args():
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1 :]
    else:
        argv = []

    parser = argparse.ArgumentParser(
        description="Quickly style a white humanoid mesh into a simple armored soldier."
    )
    parser.add_argument("--input", required=True, help="Input model path (.glb/.gltf/.fbx/.obj)")
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--body-texture", default="", help="Optional body albedo texture path")
    parser.add_argument("--armor-texture", default="", help="Optional armor albedo texture path")
    parser.add_argument("--scale", type=float, default=1.0, help="Uniform scale for imported model")
    return parser.parse_args(argv)


def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def import_model(path):
    ext = os.path.splitext(path)[1].lower()
    if ext == ".fbx":
        bpy.ops.import_scene.fbx(filepath=path)
    elif ext in (".glb", ".gltf"):
        bpy.ops.import_scene.gltf(filepath=path)
    elif ext == ".obj":
        bpy.ops.wm.obj_import(filepath=path)
    else:
        raise ValueError(f"Unsupported input format: {ext}")


def find_main_mesh():
    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    if not meshes:
        raise RuntimeError("No mesh found in imported file.")
    meshes.sort(key=lambda o: len(o.data.vertices), reverse=True)
    return meshes[0]


def find_armature():
    for obj in bpy.data.objects:
        if obj.type == "ARMATURE":
            return obj
    return None


def ensure_principled_material(name):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = None
    out = None
    for n in nt.nodes:
        if n.type == "BSDF_PRINCIPLED":
            bsdf = n
        elif n.type == "OUTPUT_MATERIAL":
            out = n
    if bsdf is None:
        bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    if out is None:
        out = nt.nodes.new("ShaderNodeOutputMaterial")
    return mat, nt, bsdf, out


def assign_material_with_optional_texture(obj, mat_name, tex_path, base_color, roughness=0.85, specular=0.08):
    mat, nt, bsdf, out = ensure_principled_material(mat_name)

    # Reset links for deterministic output.
    for link in list(nt.links):
        nt.links.remove(link)

    bsdf.inputs["Base Color"].default_value = base_color
    if "Roughness" in bsdf.inputs:
        bsdf.inputs["Roughness"].default_value = roughness
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = specular
    elif "Specular" in bsdf.inputs:
        bsdf.inputs["Specular"].default_value = specular

    if tex_path and os.path.isfile(tex_path):
        tex = nt.nodes.new("ShaderNodeTexImage")
        tex.image = bpy.data.images.load(tex_path, check_existing=True)
        nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])

    nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    obj.data.materials.clear()
    obj.data.materials.append(mat)
    return mat


def add_armor_piece(name, loc, scale, mat):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return obj


def build_quick_armor(body, armor_mat):
    dims = body.dimensions
    loc = body.location
    pieces = []

    # Chest plate
    pieces.append(
        add_armor_piece(
            "armor_chest",
            (loc.x, loc.y, loc.z + dims.z * 0.17),
            (dims.x * 0.32, dims.y * 0.22, dims.z * 0.15),
            armor_mat,
        )
    )

    # Shoulder guards
    pieces.append(
        add_armor_piece(
            "armor_shoulder_l",
            (loc.x - dims.x * 0.24, loc.y, loc.z + dims.z * 0.24),
            (dims.x * 0.10, dims.y * 0.13, dims.z * 0.08),
            armor_mat,
        )
    )
    pieces.append(
        add_armor_piece(
            "armor_shoulder_r",
            (loc.x + dims.x * 0.24, loc.y, loc.z + dims.z * 0.24),
            (dims.x * 0.10, dims.y * 0.13, dims.z * 0.08),
            armor_mat,
        )
    )

    # Waist guards
    pieces.append(
        add_armor_piece(
            "armor_waist_front",
            (loc.x, loc.y + dims.y * 0.22, loc.z + dims.z * 0.02),
            (dims.x * 0.24, dims.y * 0.05, dims.z * 0.10),
            armor_mat,
        )
    )
    pieces.append(
        add_armor_piece(
            "armor_waist_back",
            (loc.x, loc.y - dims.y * 0.22, loc.z + dims.z * 0.02),
            (dims.x * 0.24, dims.y * 0.05, dims.z * 0.10),
            armor_mat,
        )
    )

    for p in pieces:
        p.parent = body
        p.matrix_parent_inverse = body.matrix_world.inverted()

    return pieces


def export_glb(path):
    out_dir = os.path.dirname(path)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        use_selection=False,
        export_apply=True,
        export_materials="EXPORT",
        export_animations=True,
        export_animation_mode="ACTIONS",
        export_nla_strips=False,
        export_force_sampling=True,
    )


def main():
    args = parse_args()
    src = os.path.abspath(args.input)
    dst = os.path.abspath(args.output)
    body_tex = os.path.abspath(args.body_texture) if args.body_texture else ""
    armor_tex = os.path.abspath(args.armor_texture) if args.armor_texture else ""

    if not os.path.isfile(src):
        raise FileNotFoundError(f"Input file not found: {src}")

    clear_scene()
    import_model(src)

    body = find_main_mesh()
    armature = find_armature()

    if args.scale != 1.0:
        body.scale = (body.scale.x * args.scale, body.scale.y * args.scale, body.scale.z * args.scale)
        bpy.context.view_layer.objects.active = body
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    assign_material_with_optional_texture(
        body,
        "M_Soldier_Body",
        body_tex,
        base_color=(0.56, 0.56, 0.56, 1.0),
        roughness=0.9,
        specular=0.05,
    )

    armor_mat = assign_material_with_optional_texture(
        body,
        "M_Soldier_Armor",
        armor_tex,
        base_color=(0.18, 0.18, 0.20, 1.0),
        roughness=0.55,
        specular=0.18,
    )

    # Restore body material because helper above assigns to target object.
    assign_material_with_optional_texture(
        body,
        "M_Soldier_Body",
        body_tex,
        base_color=(0.56, 0.56, 0.56, 1.0),
        roughness=0.9,
        specular=0.05,
    )

    armor_pieces = build_quick_armor(body, armor_mat)

    if armature is not None:
        for p in armor_pieces:
            mod = p.modifiers.new(name="Armature", type="ARMATURE")
            mod.object = armature

    export_glb(dst)
    print(f"[done] output={dst}")


if __name__ == "__main__":
    main()
