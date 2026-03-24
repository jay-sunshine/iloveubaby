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
        description="Generate a very simple low-poly tree: cylinder trunk + cone canopy."
    )
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--height", type=float, default=2.0, help="Total tree height")
    parser.add_argument("--trunk-verts", type=int, default=10, help="Cylinder vertices")
    parser.add_argument("--leaf-verts", type=int, default=10, help="Cone vertices")
    parser.add_argument(
        "--smooth",
        action="store_true",
        help="Use smooth shading (default is flat shading).",
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


def add_trunk(height, verts):
    trunk_h = height * 0.35
    trunk_r = height * 0.08
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=max(3, verts),
        radius=trunk_r,
        depth=trunk_h,
        location=(0.0, 0.0, trunk_h * 0.5),
    )
    trunk = bpy.context.active_object
    trunk.name = "tree_trunk"
    return trunk, trunk_h


def add_cone_canopy(height, trunk_h, verts):
    canopy_h = height * 0.95
    canopy_r = height * 0.42
    # Slight overlap into trunk so it looks attached.
    canopy_z = trunk_h + canopy_h * 0.5 - height * 0.05
    bpy.ops.mesh.primitive_cone_add(
        vertices=max(3, verts),
        radius1=canopy_r,
        radius2=0.0,
        depth=canopy_h,
        location=(0.0, 0.0, canopy_z),
    )
    canopy = bpy.context.active_object
    canopy.name = "tree_canopy"
    return canopy


def set_shading(obj, smooth):
    select_only(obj)
    if smooth:
        bpy.ops.object.shade_smooth()
    else:
        bpy.ops.object.shade_flat()


def assign_materials(trunk, canopy):
    mat_trunk = bpy.data.materials.new(name="M_TreeTrunk_Simple")
    mat_trunk.use_nodes = True
    bsdf_t = next((n for n in mat_trunk.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf_t is not None:
        bsdf_t.inputs["Base Color"].default_value = (0.22, 0.14, 0.08, 1.0)
        bsdf_t.inputs["Roughness"].default_value = 0.9

    mat_leaf = bpy.data.materials.new(name="M_TreeLeaf_Simple")
    mat_leaf.use_nodes = True
    bsdf_l = next((n for n in mat_leaf.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf_l is not None:
        bsdf_l.inputs["Base Color"].default_value = (0.12, 0.48, 0.20, 1.0)
        bsdf_l.inputs["Roughness"].default_value = 0.85

    trunk.data.materials.clear()
    trunk.data.materials.append(mat_trunk)
    canopy.data.materials.clear()
    canopy.data.materials.append(mat_leaf)


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
    canopy = add_cone_canopy(args.height, trunk_h, args.leaf_verts)
    set_shading(trunk, args.smooth)
    set_shading(canopy, args.smooth)
    assign_materials(trunk, canopy)

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
