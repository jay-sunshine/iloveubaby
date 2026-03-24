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
        description="Generate a very low-poly tree with an oval canopy and curved sides."
    )
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--height", type=float, default=2.0, help="Total tree height")
    parser.add_argument("--trunk-verts", type=int, default=8, help="Trunk cylinder vertices")
    parser.add_argument("--canopy-segments", type=int, default=8, help="Canopy sphere segments")
    parser.add_argument("--canopy-rings", type=int, default=5, help="Canopy sphere rings")
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


def add_trunk(height, verts):
    trunk_h = height * 0.38
    trunk_r = height * 0.075
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=max(3, verts),
        radius=trunk_r,
        depth=trunk_h,
        location=(0.0, 0.0, trunk_h * 0.5),
    )
    trunk = bpy.context.active_object
    trunk.name = "tree_trunk"
    return trunk, trunk_h


def shape_canopy_oval(canopy):
    # Vertex coordinates are local-space.
    # Build an oval canopy (wider middle, softer top) instead of a flat bald crown.
    for v in canopy.data.vertices:
        v.co.x *= 1.16
        v.co.y *= 0.98
        v.co.z *= 0.82

    z_vals = [v.co.z for v in canopy.data.vertices]
    z_min = min(z_vals)
    z_max = max(z_vals)
    z_size = max(1e-6, z_max - z_min)

    # Slight side bulge so profile feels more natural.
    for v in canopy.data.vertices:
        t = (v.co.z - z_min) / z_size  # 0 bottom, 1 top
        if 0.18 < t < 0.75:
            bulge = 1.06
        else:
            bulge = 0.96
        v.co.x *= bulge
        v.co.y *= bulge

    # Soften top point (not flat top).
    top_cut = z_min + z_size * 0.88
    for v in canopy.data.vertices:
        if v.co.z > top_cut:
            t_top = (v.co.z - top_cut) / max(1e-6, (z_max - top_cut))
            v.co.z -= z_size * 0.08 * t_top
            v.co.x *= 1.02
            v.co.y *= 1.02

    # Keep lower part clean for trunk connection.
    bottom_plane = z_min + z_size * 0.06
    for v in canopy.data.vertices:
        if v.co.z < bottom_plane:
            v.co.z = bottom_plane

    canopy.data.update()


def add_canopy(height, trunk_h, segments, rings):
    canopy_r = height * 0.34
    center_z = trunk_h + canopy_r * 0.74
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=max(6, segments),
        ring_count=max(4, rings),
        radius=canopy_r,
        location=(0.0, 0.0, center_z),
    )
    canopy = bpy.context.active_object
    canopy.name = "tree_canopy"
    shape_canopy_oval(canopy)
    return canopy


def assign_materials(trunk, canopy):
    mat_trunk = bpy.data.materials.new(name="M_TreeTrunk_Flat")
    mat_trunk.use_nodes = True
    bsdf_t = next((n for n in mat_trunk.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf_t is not None:
        bsdf_t.inputs["Base Color"].default_value = (0.24, 0.15, 0.08, 1.0)
        bsdf_t.inputs["Roughness"].default_value = 0.92

    mat_leaf = bpy.data.materials.new(name="M_TreeCanopy_Flat")
    mat_leaf.use_nodes = True
    bsdf_c = next((n for n in mat_leaf.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf_c is not None:
        bsdf_c.inputs["Base Color"].default_value = (0.14, 0.45, 0.20, 1.0)
        bsdf_c.inputs["Roughness"].default_value = 0.88

    trunk.data.materials.clear()
    trunk.data.materials.append(mat_trunk)
    canopy.data.materials.clear()
    canopy.data.materials.append(mat_leaf)


def set_flat_shading(obj):
    select_only(obj)
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
    if args.height <= 0:
        raise ValueError("--height must be > 0")

    clear_scene()
    trunk, trunk_h = add_trunk(args.height, args.trunk_verts)
    canopy = add_canopy(args.height, trunk_h, args.canopy_segments, args.canopy_rings)
    assign_materials(trunk, canopy)
    set_flat_shading(trunk)
    set_flat_shading(canopy)

    trunk_faces = len(trunk.data.polygons)
    canopy_faces = len(canopy.data.polygons)
    total_faces = trunk_faces + canopy_faces

    ensure_parent(args.output)
    export_glb(args.output)
    print(
        f"[done] faces trunk={trunk_faces}, canopy={canopy_faces}, total={total_faces}"
    )


if __name__ == "__main__":
    main()
