import argparse
import math
import os
import sys

import bpy
from mathutils import Euler, Vector


def parse_args():
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1 :]
    else:
        argv = []

    parser = argparse.ArgumentParser(
        description="Build low-poly troop variants from Human Dummy + RPG weapons."
    )
    parser.add_argument("--human", required=True, help="HumanCharacterDummy_M.fbx path")
    parser.add_argument("--palette", required=True, help="HumanCharacterDummy_ColorPalette.png path")
    parser.add_argument("--weapons-dir", required=True, help="Weapons models directory")
    parser.add_argument(
        "--weapons-texture",
        required=True,
        help="Weapon atlas texture path (RPG_Weapons_Lite_Texture_01.png)",
    )
    parser.add_argument(
        "--weapons-dir-alt",
        default="",
        help="Optional secondary weapons directory (e.g. MedievalWeaponPack/FBX)",
    )
    parser.add_argument(
        "--weapons-texture-alt",
        default="",
        help="Optional secondary weapons atlas texture (e.g. Color_Atlas1.png)",
    )
    parser.add_argument(
        "--horse-glb",
        default="",
        help="Optional horse GLB for cavalry variant (rider + horse merged export).",
    )
    parser.add_argument("--out-dir", required=True, help="Output directory for generated GLBs")
    return parser.parse_args(argv)


def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def import_fbx(path):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.fbx(filepath=path)
    after = set(bpy.data.objects)
    return list(after - before)


def import_glb(path):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    after = set(bpy.data.objects)
    return list(after - before)


def find_largest_mesh(objects):
    meshes = [o for o in objects if o.type == "MESH"]
    if not meshes:
        return None
    meshes.sort(key=lambda o: len(o.data.vertices), reverse=True)
    return meshes[0]


def find_anchor(preferred_names):
    for name in preferred_names:
        obj = bpy.data.objects.get(name)
        if obj is not None:
            return obj
    return None


def find_human_root(objects):
    preferred = ["Human_DummyModel_M", "Human_DummyModel_F", "Human_DummyModel"]
    for name in preferred:
        obj = bpy.data.objects.get(name)
        if obj is not None:
            return obj
    roots = [o for o in objects if o.parent is None]
    for obj in roots:
        if obj.type == "EMPTY":
            return obj
    return roots[0] if roots else None


def find_horse_mesh(objects):
    helper_names = {"\u68f1\u89d2\u7403", "Icosphere", "Icosphere.001"}
    meshes = []
    for source_obj in objects:
        try:
            name = source_obj.name
        except ReferenceError:
            continue
        obj = bpy.data.objects.get(name)
        if obj is None:
            continue
        if obj.type != "MESH" or obj.name in helper_names:
            continue
        meshes.append(obj)
    if not meshes:
        return None
    named = [o for o in meshes if "horse" in o.name.lower()]
    if named:
        named.sort(key=lambda o: len(o.data.vertices), reverse=True)
        return named[0]
    meshes.sort(key=lambda o: len(o.data.vertices), reverse=True)
    return meshes[0]


def pose_rider_for_cavalry(armature_obj):
    if armature_obj is None or armature_obj.type != "ARMATURE":
        return
    bpy.context.view_layer.objects.active = armature_obj
    bpy.ops.object.mode_set(mode="POSE")

    # Quick seated pose so silhouette reads as mounted cavalry.
    pose_map = {
        "B-thigh.L": (72.0, 8.0, 6.0),
        "B-thigh.R": (72.0, -8.0, -6.0),
        "B-foot.L": (-48.0, 5.0, 2.0),
        "B-foot.R": (-48.0, -5.0, -2.0),
        "B-spine": (8.0, 0.0, 0.0),
        "B-spine1": (6.0, 0.0, 0.0),
        "B-spine2": (4.0, 0.0, 0.0),
    }
    for bone_name, rot_deg in pose_map.items():
        pb = armature_obj.pose.bones.get(bone_name)
        if pb is None:
            continue
        pb.rotation_mode = "XYZ"
        pb.rotation_euler = Euler(
            (
                math.radians(rot_deg[0]),
                math.radians(rot_deg[1]),
                math.radians(rot_deg[2]),
            ),
            "XYZ",
        )

    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.context.view_layer.update()


def align_rider_to_horse(human_root, hips_obj, horse_mesh):
    if human_root is None or hips_obj is None or horse_mesh is None:
        return
    world_corners = [horse_mesh.matrix_world @ Vector(corner) for corner in horse_mesh.bound_box]
    min_x = min(v.x for v in world_corners)
    max_x = max(v.x for v in world_corners)
    min_y = min(v.y for v in world_corners)
    max_y = max(v.y for v in world_corners)
    min_z = min(v.z for v in world_corners)
    max_z = max(v.z for v in world_corners)

    seat = Vector(
        (
            (min_x + max_x) * 0.5,
            min_y + (max_y - min_y) * 0.46,
            min_z + (max_z - min_z) * 0.79 + 0.02,
        )
    )
    delta = seat - hips_obj.matrix_world.translation
    human_root.location += delta
    bpy.context.view_layer.update()


def ensure_human_palette(material, palette_path):
    material.use_nodes = True
    nt = material.node_tree
    if nt is None:
        return

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

    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(palette_path, check_existing=True)

    # Replace existing links for deterministic export.
    for link in list(nt.links):
        nt.links.remove(link)
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    if "Roughness" in bsdf.inputs:
        bsdf.inputs["Roughness"].default_value = 0.78
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = 0.06
    elif "Specular" in bsdf.inputs:
        bsdf.inputs["Specular"].default_value = 0.06


def import_weapon_mesh(weapon_path):
    created = import_fbx(weapon_path)
    mesh_obj = find_largest_mesh(created)
    if mesh_obj is None:
        raise RuntimeError(f"No weapon mesh found in: {weapon_path}")
    return mesh_obj


def resolve_weapon_asset(candidates, weapon_sources):
    for candidate in candidates:
        for source in weapon_sources:
            directory = source.get("dir", "")
            if not directory:
                continue
            p = os.path.join(directory, candidate)
            if os.path.isfile(p):
                return p, source.get("texture", "")
    raise FileNotFoundError(f"Weapon file not found, candidates={candidates}")


def relink_weapon_materials(mesh_obj, texture_path):
    if mesh_obj is None or mesh_obj.type != "MESH":
        return
    if not os.path.isfile(texture_path):
        return
    img = bpy.data.images.load(texture_path, check_existing=True)
    for mat in mesh_obj.data.materials:
        if mat is None:
            continue
        mat.use_nodes = True
        nt = mat.node_tree
        if nt is None:
            continue
        has_tex = False
        for n in nt.nodes:
            if n.type == "TEX_IMAGE":
                n.image = img
                has_tex = True
        if not has_tex:
            bsdf = None
            out = None
            for n in nt.nodes:
                if n.type == "BSDF_PRINCIPLED":
                    bsdf = n
                elif n.type == "OUTPUT_MATERIAL":
                    out = n
            if bsdf is not None and out is not None:
                tex = nt.nodes.new("ShaderNodeTexImage")
                tex.image = img
                nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])


def attach_weapon(mesh_obj, anchor_obj, loc_offset, rot_offset_deg, scale_xyz):
    mesh_obj.parent = anchor_obj
    # Keep local transform in anchor space; do not cancel parent transform.
    mesh_obj.matrix_parent_inverse.identity()
    mesh_obj.location = Vector(loc_offset)
    mesh_obj.rotation_euler = Euler(
        (
            math.radians(rot_offset_deg[0]),
            math.radians(rot_offset_deg[1]),
            math.radians(rot_offset_deg[2]),
        ),
        "XYZ",
    )
    mesh_obj.scale = Vector(scale_xyz)


def bake_meshes(mesh_objects):
    dg = bpy.context.evaluated_depsgraph_get()
    baked = []
    for obj in mesh_objects:
        obj_eval = obj.evaluated_get(dg)
        baked_mesh = bpy.data.meshes.new_from_object(
            obj_eval, depsgraph=dg, preserve_all_data_layers=True
        )
        baked_obj = bpy.data.objects.new(f"{obj.name}_baked", baked_mesh)
        baked_obj.matrix_world = obj.matrix_world.copy()
        bpy.context.scene.collection.objects.link(baked_obj)
        baked.append(baked_obj)
    return baked


def join_objects(objects, out_name):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    out = bpy.context.active_object
    out.name = out_name
    return out


def normalize_for_export(obj, target_height=1.72):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)

    # Move to origin and put feet on ground (z=0).
    world_corners = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    min_x = min(v.x for v in world_corners)
    max_x = max(v.x for v in world_corners)
    min_y = min(v.y for v in world_corners)
    max_y = max(v.y for v in world_corners)
    min_z = min(v.z for v in world_corners)
    obj.location.x -= (min_x + max_x) * 0.5
    obj.location.y -= (min_y + max_y) * 0.5
    obj.location.z -= min_z
    bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)

    h = max(0.001, obj.dimensions.z)
    scale = target_height / h
    obj.scale *= scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)


def export_glb(out_path):
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=out_path,
        export_format="GLB",
        use_selection=False,
        export_apply=True,
        export_materials="EXPORT",
        export_animations=False,
    )


def build_variant(
    human_path,
    palette_path,
    weapon_sources,
    out_path,
    variant_name,
    weapon_specs,
    horse_path="",
):
    clear_scene()
    created = import_fbx(human_path)
    human_mesh = find_largest_mesh(created)
    if human_mesh is None:
        raise RuntimeError("Human mesh not found after import.")
    human_root = find_human_root(created)
    human_armature = bpy.data.objects.get("B-hips")

    if human_mesh.data.materials and human_mesh.data.materials[0] is not None:
        ensure_human_palette(human_mesh.data.materials[0], palette_path)
    else:
        mat = bpy.data.materials.new(name="M_HumanPalette")
        human_mesh.data.materials.clear()
        human_mesh.data.materials.append(mat)
        ensure_human_palette(mat, palette_path)

    right_anchor = find_anchor(["B-handProp.R", "handProp.R", "HandProp.R"])
    left_anchor = find_anchor(["B-handProp.L", "handProp.L", "HandProp.L"])
    spine_anchor = find_anchor(["B-spineProxy", "spineProxy", "SpineProxy"])
    if right_anchor is None or left_anchor is None:
        raise RuntimeError("Hand anchors not found in HumanCharacterDummy_M.fbx")

    mesh_objects = [human_mesh]
    if variant_name == "troop_cavalry":
        if horse_path and os.path.isfile(horse_path):
            pose_rider_for_cavalry(human_armature)
            horse_created = import_glb(horse_path)

            # Remove known helper/debug meshes from horse pack.
            for helper_name in ["\u68f1\u89d2\u7403", "Icosphere", "Icosphere.001"]:
                helper = bpy.data.objects.get(helper_name)
                if helper is not None:
                    bpy.data.objects.remove(helper, do_unlink=True)

            horse_mesh = find_horse_mesh(horse_created)
            if horse_mesh is None:
                raise RuntimeError(f"No horse mesh found in: {horse_path}")
            align_rider_to_horse(human_root, human_armature, horse_mesh)
            mesh_objects.append(horse_mesh)
        else:
            print(f"[warn] cavalry horse missing, fallback to rider-only: {horse_path}")

    for spec in weapon_specs:
        file_candidates = spec.get("file_candidates", [])
        if not file_candidates and "file" in spec:
            file_candidates = [spec["file"]]
        weapon_file, weapon_texture_path = resolve_weapon_asset(file_candidates, weapon_sources)
        weapon_obj = import_weapon_mesh(weapon_file)
        relink_weapon_materials(weapon_obj, weapon_texture_path)
        anchor_key = spec.get("anchor", "R")
        if anchor_key == "L":
            anchor = left_anchor
        elif anchor_key == "SPINE":
            anchor = spine_anchor if spine_anchor is not None else right_anchor
        else:
            anchor = right_anchor
        attach_weapon(
            weapon_obj,
            anchor,
            spec.get("loc", (0.0, 0.0, 0.0)),
            spec.get("rot", (0.0, 0.0, 0.0)),
            spec.get("scale", (1.0, 1.0, 1.0)),
        )
        mesh_objects.append(weapon_obj)

    baked = bake_meshes(mesh_objects)

    # Keep only baked meshes for a clean output hierarchy.
    for obj in list(bpy.data.objects):
        if obj not in baked:
            bpy.data.objects.remove(obj, do_unlink=True)

    merged = join_objects(baked, variant_name)
    normalize_for_export(merged, target_height=1.72)
    export_glb(out_path)
    print(f"[done] {variant_name} -> {out_path}")


def main():
    args = parse_args()
    human_path = os.path.abspath(args.human)
    palette_path = os.path.abspath(args.palette)
    weapons_dir = os.path.abspath(args.weapons_dir)
    weapons_texture_path = os.path.abspath(args.weapons_texture)
    weapons_dir_alt = os.path.abspath(args.weapons_dir_alt) if args.weapons_dir_alt else ""
    weapons_texture_alt = (
        os.path.abspath(args.weapons_texture_alt) if args.weapons_texture_alt else ""
    )
    horse_path = os.path.abspath(args.horse_glb) if args.horse_glb else ""
    out_dir = os.path.abspath(args.out_dir)

    weapon_sources = []
    if weapons_dir_alt:
        weapon_sources.append({"dir": weapons_dir_alt, "texture": weapons_texture_alt})
    weapon_sources.append({"dir": weapons_dir, "texture": weapons_texture_path})

    variants = {
        "troop_infantry_shield": [
            {
                "file_candidates": ["Sword_01.fbx", "Sword.fbx", "Gladius.fbx"],
                "anchor": "R",
                "loc": (0.00, 0.52, 0.00),
                "rot": (0.0, 0.0, 0.0),
                "scale": (1.0, 1.0, 1.0),
            },
            {
                "file_candidates": ["Shield_01.fbx", "Shield.fbx"],
                "anchor": "L",
                "loc": (0.08, 0.00, 0.00),
                "rot": (0.0, 0.0, 0.0),
                "scale": (1.0, 1.0, 1.0),
            },
        ],
        "troop_spear": [
            {
                "file_candidates": ["Spear.fbx", "Spear_01.fbx", "Sword_01.fbx", "Sword.fbx"],
                "anchor": "R",
                "loc": (0.00, 0.74, 0.00),
                "rot": (0.0, 0.0, 0.0),
                "scale": (1.0, 1.0, 1.0),
            }
        ],
        "troop_archer": [
            {
                "file_candidates": ["Bow_01.fbx", "Bow.fbx"],
                "anchor": "L",
                "loc": (0.00, 0.00, 0.00),
                "rot": (0.0, 0.0, 0.0),
                "scale": (1.0, 1.0, 1.0),
            },
            {
                "file_candidates": ["Arrow_01.fbx", "Arrow.fbx"],
                "anchor": "SPINE",
                "loc": (0.10, 0.04, -0.10),
                "rot": (80.0, 0.0, 20.0),
                "scale": (1.0, 1.0, 1.0),
            },
        ],
        "troop_cavalry": [
            {
                "file_candidates": ["Ax_01.fbx", "Axe.fbx", "Hammer.fbx"],
                "anchor": "R",
                "loc": (0.00, 0.56, 0.00),
                "rot": (0.0, 0.0, 0.0),
                "scale": (1.0, 1.0, 1.0),
            }
        ],
        "troop_infantry": [
            {
                "file_candidates": ["Sword_01.fbx", "Sword.fbx", "Saber.fbx"],
                "anchor": "R",
                "loc": (0.00, 0.52, 0.00),
                "rot": (0.0, 0.0, 0.0),
                "scale": (1.0, 1.0, 1.0),
            }
        ],
    }

    os.makedirs(out_dir, exist_ok=True)
    for name, specs in variants.items():
        out_path = os.path.join(out_dir, f"{name}.glb")
        build_variant(
            human_path,
            palette_path,
            weapon_sources,
            out_path,
            name,
            specs,
            horse_path=horse_path,
        )


if __name__ == "__main__":
    main()
