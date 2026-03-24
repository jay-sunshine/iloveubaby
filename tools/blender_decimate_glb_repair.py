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
        description="Decimate GLB and repair shading with normal transfer."
    )
    parser.add_argument("--input", required=True, help="Input .glb path")
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--target", type=int, default=800, help="Target total face count")
    parser.add_argument(
        "--smooth-angle",
        type=float,
        default=60.0,
        help="Auto smooth angle in degrees",
    )
    return parser.parse_args(argv)


def ensure_parent(path):
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)


def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def import_glb(path):
    bpy.ops.import_scene.gltf(filepath=path)


def get_mesh_objects():
    return [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]


def face_count(objs):
    return sum(len(obj.data.polygons) for obj in objs)


def select_only(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def apply_modifier(obj, modifier_name):
    select_only(obj)
    bpy.ops.object.modifier_apply(modifier=modifier_name)


def duplicate_sources(mesh_objs):
    pairs = []
    collection = bpy.context.scene.collection
    for obj in mesh_objs:
        src = obj.copy()
        src.data = obj.data.copy()
        src.name = f"{obj.name}__src"
        collection.objects.link(src)
        src.hide_set(True)
        src.hide_render = True
        pairs.append((obj, src))
    return pairs


def decimate_object(obj, ratio):
    mod = obj.modifiers.new(name="CodexDecimate", type="DECIMATE")
    mod.decimate_type = "COLLAPSE"
    mod.ratio = ratio
    mod.use_collapse_triangulate = True
    apply_modifier(obj, mod.name)


def transfer_normals(dst, src):
    mod = dst.modifiers.new(name="CodexDataTransfer", type="DATA_TRANSFER")
    mod.object = src
    mod.use_loop_data = True
    mod.data_types_loops = {"CUSTOM_NORMAL"}
    mod.loop_mapping = "POLYINTERP_NEAREST"
    apply_modifier(dst, mod.name)


def apply_smooth_fix(obj, angle_degrees):
    select_only(obj)
    bpy.ops.object.shade_smooth_by_angle(
        angle=math.radians(angle_degrees), keep_sharp_edges=True
    )

    wn = obj.modifiers.new(name="CodexWeightedNormal", type="WEIGHTED_NORMAL")
    wn.keep_sharp = True
    wn.weight = 50
    apply_modifier(obj, wn.name)


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


def remove_sources(pairs):
    for _, src in pairs:
        bpy.data.objects.remove(src, do_unlink=True)


def main():
    args = parse_args()
    if args.target <= 0:
        raise ValueError("--target must be > 0")
    if not os.path.isfile(args.input):
        raise FileNotFoundError(f"Input not found: {args.input}")

    clear_scene()
    import_glb(args.input)

    meshes = get_mesh_objects()
    if not meshes:
        raise RuntimeError("No mesh objects found in input GLB.")

    before = face_count(meshes)
    sources = duplicate_sources(meshes)

    ratio = 1.0
    if before > args.target:
        ratio = max(0.0001, min(1.0, float(args.target) / float(before)))
        for obj in meshes:
            decimate_object(obj, ratio)

    after = face_count(meshes)

    if after > args.target * 1.15:
        correction = max(0.0001, min(1.0, float(args.target) / float(after)))
        for obj in meshes:
            decimate_object(obj, correction)
        after = face_count(meshes)

    for dst, src in sources:
        transfer_normals(dst, src)
        apply_smooth_fix(dst, args.smooth_angle)

    remove_sources(sources)

    ensure_parent(args.output)
    export_glb(args.output)
    print(
        f"[done] faces before={before}, after={after}, target={args.target}, ratio={ratio:.6f}"
    )


if __name__ == "__main__":
    main()
