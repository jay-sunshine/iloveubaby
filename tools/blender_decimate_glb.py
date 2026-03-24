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

    parser = argparse.ArgumentParser(description="Decimate a GLB to target face count.")
    parser.add_argument("--input", required=True, help="Input .glb path")
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--target", type=int, default=1000, help="Target total face count")
    return parser.parse_args(argv)


def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def import_glb(path):
    bpy.ops.import_scene.gltf(filepath=path)


def get_mesh_objects():
    return [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]


def face_count(objs):
    return sum(len(obj.data.polygons) for obj in objs)


def apply_decimate(obj, ratio):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    mod = obj.modifiers.new(name="CodexDecimate", type="DECIMATE")
    mod.decimate_type = "COLLAPSE"
    mod.ratio = ratio
    mod.use_collapse_triangulate = True
    bpy.ops.object.modifier_apply(modifier=mod.name)


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


def ensure_parent(path):
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)


def main():
    args = parse_args()
    if args.target <= 0:
        raise ValueError("--target must be > 0")
    if not os.path.isfile(args.input):
        raise FileNotFoundError(f"Input not found: {args.input}")

    clear_scene()
    import_glb(args.input)

    objs = get_mesh_objects()
    if not objs:
        raise RuntimeError("No mesh objects found in input GLB.")

    before = face_count(objs)
    if before <= args.target:
        ensure_parent(args.output)
        export_glb(args.output)
        print(f"[done] faces before={before}, already <= target={args.target}")
        return

    ratio = max(0.0001, min(1.0, float(args.target) / float(before)))
    for obj in objs:
        apply_decimate(obj, ratio)

    after = face_count(objs)

    # One corrective pass if rounding drift is large.
    if after > args.target * 1.15:
        correction = max(0.0001, min(1.0, float(args.target) / float(after)))
        for obj in objs:
            apply_decimate(obj, correction)
        after = face_count(objs)

    ensure_parent(args.output)
    export_glb(args.output)
    print(f"[done] faces before={before}, after={after}, target={args.target}")


if __name__ == "__main__":
    main()
