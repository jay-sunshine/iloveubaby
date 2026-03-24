import argparse
import math
import os
import random
import sys

import bpy
import mathutils


def parse_args():
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1 :]
    else:
        argv = []

    parser = argparse.ArgumentParser(
        description="Restyle a simple tree into a Humanica-like layered canopy hull tree."
    )
    parser.add_argument("--input", required=True, help="Input .glb path")
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--seed", type=int, default=17, help="Random seed")
    parser.add_argument("--segments", type=int, default=8, help="Canopy segment count")
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


def import_glb(path):
    bpy.ops.import_scene.gltf(filepath=path)


def find_meshes():
    return [o for o in bpy.context.scene.objects if o.type == "MESH"]


def scene_bounds(objs):
    xs = []
    ys = []
    zs = []
    for o in objs:
        mw = o.matrix_world
        for c in o.bound_box:
            p = mw @ mathutils.Vector(c)
            xs.append(p.x)
            ys.append(p.y)
            zs.append(p.z)
    return (min(xs), max(xs)), (min(ys), max(ys)), (min(zs), max(zs))


def remove_mesh_objects(objs):
    for o in objs:
        bpy.data.objects.remove(o, do_unlink=True)


def make_bark_texture(seed, w=128, h=256):
    rng = random.Random(seed + 1007)
    img = bpy.data.images.new("IMG_Hull_Bark", width=w, height=h, alpha=False)
    px = [0.0] * (w * h * 4)
    p = 0
    for y in range(h):
        ny = y / float(max(1, h - 1))
        for x in range(w):
            nx = x / float(max(1, w - 1))
            stripe = (
                math.sin(nx * 25.0 + ny * 2.2) * 0.2
                + math.sin(nx * 63.0 + ny * 2.8) * 0.1
            )
            shade = max(0.0, min(1.0, 0.58 + stripe + (rng.random() - 0.5) * 0.08))
            r = 0.10 + shade * 0.14
            g = 0.07 + shade * 0.10
            b = 0.05 + shade * 0.07
            px[p + 0] = max(0.0, min(1.0, r))
            px[p + 1] = max(0.0, min(1.0, g))
            px[p + 2] = max(0.0, min(1.0, b))
            px[p + 3] = 1.0
            p += 4
    img.pixels = px
    img.pack()
    return img


def make_leaf_texture(seed, size=256):
    rng = random.Random(seed + 2003)
    img = bpy.data.images.new("IMG_Hull_Leaf", width=size, height=size, alpha=False)
    px = [0.0] * (size * size * 4)
    p = 0
    for y in range(size):
        ny = y / float(max(1, size - 1))
        for x in range(size):
            nx = x / float(max(1, size - 1))
            blob = (
                math.sin(nx * 22.0 + ny * 17.0) * 0.12
                + math.sin(nx * 47.0 + ny * 31.0) * 0.08
                + (rng.random() - 0.5) * 0.04
            )
            shade = max(0.0, min(1.0, 0.62 + blob - ny * 0.08))
            r = 0.08 + shade * 0.14
            g = 0.28 + shade * 0.52
            b = 0.10 + shade * 0.20
            px[p + 0] = max(0.0, min(1.0, r))
            px[p + 1] = max(0.0, min(1.0, g))
            px[p + 2] = max(0.0, min(1.0, b))
            px[p + 3] = 1.0
            p += 4
    img.pixels = px
    img.pack()
    return img


def make_trunk_material(seed):
    bark = make_bark_texture(seed)
    mat = bpy.data.materials.new(name="M_Tree_Hull_Trunk")
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = next((n for n in nt.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf is None:
        bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = bark
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Metallic"].default_value = 0.0
    bsdf.inputs["Roughness"].default_value = 1.0
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = 0.0
    elif "Specular" in bsdf.inputs:
        bsdf.inputs["Specular"].default_value = 0.0
    return mat


def make_leaf_material(seed):
    leaf = make_leaf_texture(seed)
    mat = bpy.data.materials.new(name="M_Tree_Hull_Leaf")
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = next((n for n in nt.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf is None:
        bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = leaf
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Metallic"].default_value = 0.0
    bsdf.inputs["Roughness"].default_value = 1.0
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = 0.0
    elif "Specular" in bsdf.inputs:
        bsdf.inputs["Specular"].default_value = 0.0
    return mat


def add_trunk(tree_h, segments):
    trunk_h = tree_h * 0.40
    trunk_r = tree_h * 0.075
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=max(6, segments),
        radius=trunk_r,
        depth=trunk_h,
        location=(0.0, 0.0, trunk_h * 0.5),
    )
    trunk = bpy.context.active_object
    trunk.name = "tree_trunk"
    return trunk, trunk_h


def add_layered_canopy(tree_h, trunk_h, segments, seed):
    rng = random.Random(seed)
    layers = []
    specs = [
        (0.31, 0.35, 0.19, 0.14),
        (0.46, 0.27, 0.14, 0.11),
    ]
    for i, (z_rel, r_bottom, r_top, depth_rel) in enumerate(specs):
        z = trunk_h + tree_h * z_rel
        depth = tree_h * depth_rel
        bpy.ops.mesh.primitive_cone_add(
            vertices=max(6, segments),
            radius1=tree_h * r_bottom,
            radius2=tree_h * r_top,
            depth=depth,
            location=(0.0, 0.0, z),
            rotation=(0.0, 0.0, math.radians(rng.uniform(-8.0, 8.0))),
        )
        o = bpy.context.active_object
        o.name = f"tree_canopy_layer_{i+1}"
        # Slight oval and asymmetry
        o.scale = (rng.uniform(1.03, 1.12), rng.uniform(0.92, 1.02), 1.0)
        layers.append(o)

    # Small top cap to avoid cone-tip look.
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=max(6, segments),
        ring_count=3,
        radius=tree_h * 0.08,
        location=(0.0, 0.0, trunk_h + tree_h * 0.64),
    )
    cap = bpy.context.active_object
    cap.name = "tree_canopy_cap"
    cap.scale = (1.1, 0.95, 0.6)
    layers.append(cap)

    select_only(layers[0])
    for o in layers[1:]:
        o.select_set(True)
    bpy.ops.object.join()
    canopy = bpy.context.active_object
    canopy.name = "tree_canopy"
    return canopy


def set_flat(obj):
    select_only(obj)
    bpy.ops.object.shade_flat()


def triangulate(obj):
    tri = obj.modifiers.new(name="Triangulate", type="TRIANGULATE")
    select_only(obj)
    bpy.ops.object.modifier_apply(modifier=tri.name)


def export_glb(path):
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        export_apply=True,
        export_texcoords=True,
        export_normals=True,
        export_tangents=False,
        export_materials="EXPORT",
        use_selection=False,
    )


def count_tris(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def main():
    args = parse_args()
    if not os.path.isfile(args.input):
        raise FileNotFoundError(f"Input not found: {args.input}")

    clear_scene()
    import_glb(args.input)
    meshes = find_meshes()
    if not meshes:
        raise RuntimeError("No mesh objects found in input GLB.")

    (_, _), (_, _), (zmin, zmax) = scene_bounds(meshes)
    tree_h = max(0.6, zmax - zmin)
    remove_mesh_objects(meshes)

    trunk_seg = max(6, args.segments - 1)
    canopy_seg = max(6, args.segments)
    trunk, trunk_h = add_trunk(tree_h, trunk_seg)
    canopy = add_layered_canopy(tree_h, trunk_h, canopy_seg, args.seed)

    trunk_mat = make_trunk_material(args.seed)
    leaf_mat = make_leaf_material(args.seed)
    trunk.data.materials.clear()
    trunk.data.materials.append(trunk_mat)
    canopy.data.materials.clear()
    canopy.data.materials.append(leaf_mat)

    set_flat(trunk)
    set_flat(canopy)
    triangulate(trunk)
    triangulate(canopy)

    tris_total = count_tris(trunk) + count_tris(canopy)

    ensure_parent(args.output)
    export_glb(args.output)
    print(f"[done] tris total={tris_total}")


if __name__ == "__main__":
    main()
