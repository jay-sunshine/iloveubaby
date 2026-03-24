import argparse
import math
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
        description="Generate a low-poly armored soldier (no helmet) and export GLB."
    )
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--target", type=int, default=800, help="Target face count")
    return parser.parse_args(argv)


def ensure_parent(path):
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)


def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def select_only(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def add_cube(name, location, scale):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    return obj


def add_cylinder(name, location, radius, depth, rotation=(0.0, 0.0, 0.0), vertices=16):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices, radius=radius, depth=depth, location=location, rotation=rotation
    )
    obj = bpy.context.active_object
    obj.name = name
    return obj


def add_sphere(name, location, radius, segments=16, rings=8):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=segments, ring_count=rings, radius=radius, location=location
    )
    obj = bpy.context.active_object
    obj.name = name
    return obj


def add_body_parts():
    parts = []

    # Connected body scaffold (all parts overlap).
    parts.append(add_cylinder("spine", (0.0, 0.0, 1.08), radius=0.19, depth=0.92))
    parts.append(add_cube("pelvis", (0.0, 0.0, 0.79), (0.22, 0.16, 0.12)))
    parts.append(add_sphere("head", (0.0, 0.0, 1.72), radius=0.14))
    parts.append(add_cylinder("neck", (0.0, 0.0, 1.55), radius=0.08, depth=0.16))

    # Arms
    parts.append(
        add_cylinder(
            "arm_l", (-0.24, 0.0, 1.22), radius=0.08, depth=0.80, rotation=(0, math.radians(90), 0)
        )
    )
    parts.append(
        add_cylinder(
            "arm_r", (0.24, 0.0, 1.22), radius=0.08, depth=0.80, rotation=(0, math.radians(90), 0)
        )
    )
    parts.append(add_sphere("hand_l", (-0.56, 0.0, 1.02), radius=0.08))
    parts.append(add_sphere("hand_r", (0.56, 0.0, 1.02), radius=0.08))

    # Legs
    parts.append(add_cylinder("leg_l", (-0.11, 0.0, 0.47), radius=0.095, depth=0.78))
    parts.append(add_cylinder("leg_r", (0.11, 0.0, 0.47), radius=0.095, depth=0.78))
    parts.append(add_cube("foot_l", (-0.11, 0.08, 0.08), (0.11, 0.18, 0.07)))
    parts.append(add_cube("foot_r", (0.11, 0.08, 0.08), (0.11, 0.18, 0.07)))

    # Armor shell
    parts.append(add_cube("chestplate", (0.0, 0.10, 1.18), (0.27, 0.07, 0.32)))
    parts.append(add_cube("backplate", (0.0, -0.10, 1.18), (0.27, 0.07, 0.32)))
    parts.append(add_cube("shoulder_l", (-0.28, 0.03, 1.40), (0.16, 0.12, 0.09)))
    parts.append(add_cube("shoulder_r", (0.28, 0.03, 1.40), (0.16, 0.12, 0.09)))
    parts.append(add_cube("waist_guard_f", (0.0, 0.13, 0.84), (0.24, 0.04, 0.16)))
    parts.append(add_cube("waist_guard_b", (0.0, -0.13, 0.84), (0.24, 0.04, 0.16)))
    parts.append(add_cube("skirt_panel_lf", (-0.11, 0.11, 0.66), (0.08, 0.03, 0.18)))
    parts.append(add_cube("skirt_panel_rf", (0.11, 0.11, 0.66), (0.08, 0.03, 0.18)))
    parts.append(add_cube("bracer_l", (-0.38, 0.03, 1.04), (0.12, 0.04, 0.16)))
    parts.append(add_cube("bracer_r", (0.38, 0.03, 1.04), (0.12, 0.04, 0.16)))

    # Slight stylization.
    for name in ["shoulder_l", "shoulder_r", "skirt_panel_lf", "skirt_panel_rf"]:
        obj = bpy.data.objects[name]
        if "l" in name:
            obj.rotation_euler = (math.radians(4), 0, math.radians(8))
        else:
            obj.rotation_euler = (math.radians(4), 0, math.radians(-8))

    return parts


def join_all(parts):
    select_only(parts[0])
    for obj in parts[1:]:
        obj.select_set(True)
    bpy.ops.object.join()
    obj = bpy.context.active_object
    obj.name = "soldier_body_armor"
    return obj


def apply_transforms(obj):
    select_only(obj)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)


def fuse_mesh(obj):
    # Convert block assembly into one connected shell.
    rem = obj.modifiers.new(name="VoxelRemesh", type="REMESH")
    rem.mode = "VOXEL"
    rem.voxel_size = 0.03
    rem.use_smooth_shade = False
    rem.use_remove_disconnected = False
    bpy.ops.object.modifier_apply(modifier=rem.name)


def remesh_and_target_faces(obj, target_faces):
    before = len(obj.data.polygons)
    if before < target_faces:
        tri = obj.modifiers.new(name="TriangulateForDensity", type="TRIANGULATE")
        bpy.ops.object.modifier_apply(modifier=tri.name)
        before = len(obj.data.polygons)

    ratio = min(1.0, max(0.0001, float(target_faces) / float(max(1, before))))

    dec = obj.modifiers.new(name="Decimate", type="DECIMATE")
    dec.decimate_type = "COLLAPSE"
    dec.ratio = ratio
    dec.use_collapse_triangulate = True
    bpy.ops.object.modifier_apply(modifier=dec.name)

    after = len(obj.data.polygons)
    if after > target_faces * 1.08:
        ratio2 = min(1.0, max(0.0001, float(target_faces) / float(after)))
        dec2 = obj.modifiers.new(name="Decimate2", type="DECIMATE")
        dec2.decimate_type = "COLLAPSE"
        dec2.ratio = ratio2
        dec2.use_collapse_triangulate = True
        bpy.ops.object.modifier_apply(modifier=dec2.name)
        after = len(obj.data.polygons)
    return before, after


def auto_uv(obj):
    select_only(obj)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(
        angle_limit=math.radians(66.0), island_margin=0.01, area_weight=0.0
    )
    bpy.ops.object.mode_set(mode="OBJECT")


def assign_basic_material(obj):
    mat = bpy.data.materials.new(name="M_Soldier_Base")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = (0.22, 0.22, 0.24, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.68
        bsdf.inputs["Metallic"].default_value = 0.15
    obj.data.materials.clear()
    obj.data.materials.append(mat)


def smooth_fix(obj):
    select_only(obj)
    bpy.ops.object.shade_smooth_by_angle(
        angle=math.radians(40.0), keep_sharp_edges=True
    )

    wn = obj.modifiers.new(name="WeightedNormal", type="WEIGHTED_NORMAL")
    wn.keep_sharp = True
    wn.weight = 50
    bpy.ops.object.modifier_apply(modifier=wn.name)


def export_glb(path):
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        export_apply=True,
        export_texcoords=True,
        export_normals=True,
        export_tangents=True,
        export_materials="EXPORT",
        use_selection=False,
    )


def main():
    args = parse_args()
    if args.target <= 0:
        raise ValueError("--target must be > 0")

    clear_scene()
    parts = add_body_parts()
    model = join_all(parts)
    apply_transforms(model)
    fuse_mesh(model)
    before, after = remesh_and_target_faces(model, args.target)
    auto_uv(model)
    assign_basic_material(model)
    smooth_fix(model)

    ensure_parent(args.output)
    export_glb(args.output)
    print(f"[done] faces before={before}, after={after}, target={args.target}")


if __name__ == "__main__":
    main()
