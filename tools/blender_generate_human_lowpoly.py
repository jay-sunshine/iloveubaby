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
        description="Generate a simple low-poly humanoid and export GLB."
    )
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--target", type=int, default=600, help="Target face count")
    parser.add_argument("--height", type=float, default=1.9, help="Character height")
    parser.add_argument(
        "--smooth",
        action="store_true",
        help="Use smooth shading (default keeps flat low-poly style).",
    )
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


def add_cylinder(name, radius, depth, loc, rot=(0.0, 0.0, 0.0), verts=8):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=max(3, verts), radius=radius, depth=depth, location=loc, rotation=rot
    )
    obj = bpy.context.active_object
    obj.name = name
    return obj


def add_cube(name, scale, loc, rot=(0.0, 0.0, 0.0)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc, rotation=rot)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    return obj


def add_uv_sphere(name, radius, loc, seg=10, ring=6):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=seg, ring_count=ring, radius=radius, location=loc
    )
    obj = bpy.context.active_object
    obj.name = name
    return obj


def build_humanoid(height):
    h = height
    parts = []

    # Core
    parts.append(add_cube("pelvis", (0.16, 0.11, 0.07), (0.0, 0.0, h * 0.47)))
    parts.append(
        add_cylinder(
            "torso",
            radius=h * 0.11,
            depth=h * 0.36,
            loc=(0.0, 0.0, h * 0.64),
            verts=8,
        )
    )
    parts.append(
        add_cylinder(
            "chest",
            radius=h * 0.12,
            depth=h * 0.26,
            loc=(0.0, 0.0, h * 0.77),
            verts=8,
        )
    )
    parts.append(
        add_cylinder(
            "neck",
            radius=h * 0.035,
            depth=h * 0.10,
            loc=(0.0, 0.0, h * 0.92),
            verts=8,
        )
    )
    head = add_uv_sphere(
        "head", radius=h * 0.095, loc=(0.0, 0.0, h * 1.03), seg=10, ring=6
    )
    head.scale = (0.90, 0.86, 1.06)
    parts.append(head)

    # Shoulders / connectors
    parts.append(add_cube("shoulder_bridge", (0.24, 0.09, 0.05), (0.0, 0.0, h * 0.83)))

    # Arms
    for side in (-1, 1):
        x = side * h * 0.20
        parts.append(
            add_cylinder(
                f"upper_arm_{side}",
                radius=h * 0.042,
                depth=h * 0.21,
                loc=(x, 0.0, h * 0.76),
                rot=(0.0, math.radians(5), math.radians(side * 5)),
                verts=8,
            )
        )
        parts.append(
            add_cylinder(
                f"forearm_{side}",
                radius=h * 0.036,
                depth=h * 0.20,
                loc=(x + side * h * 0.015, 0.0, h * 0.61),
                rot=(0.0, math.radians(4), math.radians(side * 3)),
                verts=8,
            )
        )
        parts.append(
            add_cube(
                f"hand_{side}",
                scale=(h * 0.030, h * 0.028, h * 0.040),
                loc=(x + side * h * 0.018, 0.0, h * 0.51),
            )
        )

    # Legs
    for side in (-1, 1):
        x = side * h * 0.065
        parts.append(
            add_cylinder(
                f"thigh_{side}",
                radius=h * 0.048,
                depth=h * 0.25,
                loc=(x, 0.0, h * 0.34),
                rot=(0.0, 0.0, math.radians(side * 1)),
                verts=8,
            )
        )
        parts.append(
            add_cylinder(
                f"shin_{side}",
                radius=h * 0.042,
                depth=h * 0.24,
                loc=(x, 0.0, h * 0.18),
                verts=8,
            )
        )
        parts.append(
            add_cube(
                f"foot_{side}",
                scale=(h * 0.05, h * 0.09, h * 0.03),
                loc=(x, h * 0.03, h * 0.055),
            )
        )

    # Hip bridge keeps legs connected when fused.
    parts.append(add_cube("hip_bridge", (0.12, 0.09, 0.05), (0.0, 0.0, h * 0.41)))

    select_only(parts[0])
    for p in parts[1:]:
        p.select_set(True)
    bpy.ops.object.join()
    obj = bpy.context.active_object
    obj.name = "lowpoly_human"
    return obj


def remesh_and_decimate(obj, target_faces):
    select_only(obj)

    rem = obj.modifiers.new(name="VoxelRemesh", type="REMESH")
    rem.mode = "VOXEL"
    rem.voxel_size = 0.07
    rem.use_smooth_shade = False
    rem.use_remove_disconnected = False
    bpy.ops.object.modifier_apply(modifier=rem.name)

    tri = obj.modifiers.new(name="Triangulate", type="TRIANGULATE")
    bpy.ops.object.modifier_apply(modifier=tri.name)

    before = len(obj.data.polygons)
    if before <= target_faces:
        return before, before

    ratio = max(0.0001, min(1.0, float(target_faces) / float(before)))
    dec = obj.modifiers.new(name="Decimate", type="DECIMATE")
    dec.decimate_type = "COLLAPSE"
    dec.ratio = ratio
    dec.use_collapse_triangulate = True
    bpy.ops.object.modifier_apply(modifier=dec.name)
    after = len(obj.data.polygons)

    if after > target_faces * 1.06:
        ratio2 = max(0.0001, min(1.0, float(target_faces) / float(after)))
        dec2 = obj.modifiers.new(name="Decimate2", type="DECIMATE")
        dec2.decimate_type = "COLLAPSE"
        dec2.ratio = ratio2
        dec2.use_collapse_triangulate = True
        bpy.ops.object.modifier_apply(modifier=dec2.name)
        after = len(obj.data.polygons)

    return before, after


def assign_material(obj):
    mat = bpy.data.materials.new(name="M_Human_Lowpoly")
    mat.use_nodes = True
    bsdf = next((n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (0.66, 0.66, 0.67, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.88
    obj.data.materials.clear()
    obj.data.materials.append(mat)


def apply_shading(obj, smooth):
    select_only(obj)
    if smooth:
        bpy.ops.object.shade_smooth()
    else:
        bpy.ops.object.shade_flat()


def export_glb(path):
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        export_apply=True,
        export_texcoords=False,
        export_normals=True,
        export_tangents=False,
        export_materials="EXPORT",
        use_selection=False,
    )


def main():
    args = parse_args()
    if args.target <= 120:
        raise ValueError("--target must be >= 120")

    clear_scene()
    model = build_humanoid(args.height)
    before, after = remesh_and_decimate(model, args.target)
    assign_material(model)
    apply_shading(model, args.smooth)

    ensure_parent(args.output)
    export_glb(args.output)
    print(f"[done] faces before={before}, after={after}, target={args.target}")


if __name__ == "__main__":
    main()
