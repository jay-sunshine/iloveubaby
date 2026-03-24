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
        description="Restyle a simple tree into a Humanica-like low-poly textured tree."
    )
    parser.add_argument("--input", required=True, help="Input .glb path")
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--seed", type=int, default=17, help="Random seed")
    parser.add_argument("--layers", type=int, default=4, help="Canopy card layers")
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
    img = bpy.data.images.new("IMG_Humanica_Bark", width=w, height=h, alpha=False)
    px = [0.0] * (w * h * 4)
    p = 0
    for y in range(h):
        ny = y / float(max(1, h - 1))
        for x in range(w):
            nx = x / float(max(1, w - 1))
            stripe = (
                math.sin(nx * 27.0 + ny * 2.5) * 0.22
                + math.sin(nx * 61.0 + ny * 3.2) * 0.12
            )
            grain = (rng.random() - 0.5) * 0.08
            shade = max(0.0, min(1.0, 0.55 + stripe + grain))
            r = 0.10 + shade * 0.15
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


def make_leaf_texture(seed, size=512):
    rng = random.Random(seed + 2003)
    img = bpy.data.images.new("IMG_Humanica_Leaf", width=size, height=size, alpha=True)
    px = [0.0] * (size * size * 4)

    blobs = []
    for _ in range(75):
        blobs.append(
            (
                rng.uniform(0.15, 0.85),
                rng.uniform(0.15, 0.85),
                rng.uniform(0.05, 0.18),
                rng.uniform(-0.2, 0.22),
            )
        )

    p = 0
    for y in range(size):
        ny = y / float(max(1, size - 1))
        for x in range(size):
            nx = x / float(max(1, size - 1))
            dx = nx - 0.5
            dy = ny - 0.52
            ellipse = (dx * dx) / 0.24 + (dy * dy) / 0.18
            edge = max(0.0, min(1.0, 1.15 - ellipse))

            noise = 0.0
            for bx, by, br, ba in blobs:
                ddx = nx - bx
                ddy = ny - by
                d = (ddx * ddx + ddy * ddy) / (br * br)
                if d < 1.0:
                    noise += ba * (1.0 - d) * (1.0 - d)

            base = max(0.0, min(1.0, 0.62 + noise))
            grad = 0.85 + 0.18 * (1.0 - ny)
            dark = 0.86 if math.sin(nx * 95.0 + ny * 77.0) > 0.92 else 1.0

            r = (0.08 + base * 0.13) * grad * dark
            g = (0.30 + base * 0.50) * grad * dark
            b = (0.10 + base * 0.18) * grad * dark

            alpha = max(0.0, min(1.0, edge))
            # Hand-painted torn edge
            jitter = 0.85 + 0.15 * math.sin(nx * 73.0 + ny * 59.0)
            alpha *= jitter

            px[p + 0] = max(0.0, min(1.0, r))
            px[p + 1] = max(0.0, min(1.0, g))
            px[p + 2] = max(0.0, min(1.0, b))
            px[p + 3] = alpha
            p += 4

    img.pixels = px
    img.pack()
    return img


def make_trunk_material(seed):
    bark = make_bark_texture(seed)
    mat = bpy.data.materials.new(name="M_Tree_Humanica_Trunk")
    mat.use_nodes = True
    nt = mat.node_tree
    nodes = nt.nodes
    links = nt.links
    bsdf = next((n for n in nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf is None:
        bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = bark
    links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = 0.9
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = 0.1
    return mat


def make_leaf_material(seed):
    leaf = make_leaf_texture(seed)
    mat = bpy.data.materials.new(name="M_Tree_Humanica_Leaf")
    mat.use_nodes = True
    nt = mat.node_tree
    nodes = nt.nodes
    links = nt.links
    bsdf = next((n for n in nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf is None:
        bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = leaf
    links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
    bsdf.inputs["Roughness"].default_value = 0.88
    bsdf.inputs["Metallic"].default_value = 0.0
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = 0.07
    if "Emission Strength" in bsdf.inputs:
        bsdf.inputs["Emission Strength"].default_value = 0.04

    # Export as alpha-cut leaf cards.
    mat.blend_method = "CLIP"
    if hasattr(mat, "shadow_method"):
        mat.shadow_method = "CLIP"
    mat.alpha_threshold = 0.45
    mat.use_backface_culling = False
    return mat


def build_trunk(height, radius):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=10,
        radius=radius,
        depth=height,
        location=(0.0, 0.0, height * 0.5),
    )
    trunk = bpy.context.active_object
    trunk.name = "tree_trunk"
    return trunk


def add_card(z, width, height, angle_deg):
    bpy.ops.mesh.primitive_plane_add(size=1.0, location=(0.0, 0.0, z))
    card = bpy.context.active_object
    card.rotation_euler = (0.0, 0.0, math.radians(angle_deg))
    card.scale = (width * 0.5, 1.0, height * 0.5)
    # Billboard card should stand up along Z.
    card.rotation_euler.x = math.radians(90.0)
    return card


def build_canopy_cards(trunk_top, tree_h, layers):
    cards = []
    layer_count = max(3, layers)
    # 3 cards per layer gives richer silhouette while still low-poly.
    angles = [0.0, 60.0, 120.0]
    for i in range(layer_count):
        t = i / float(max(1, layer_count - 1))
        z = trunk_top + tree_h * (0.16 + t * 0.36)
        w = tree_h * (0.72 - t * 0.18)
        h = tree_h * (0.46 - t * 0.08)
        for a in angles:
            card = add_card(z=z, width=w, height=h, angle_deg=a + (i % 2) * 10.0)
            cards.append(card)

    select_only(cards[0])
    for c in cards[1:]:
        c.select_set(True)
    bpy.ops.object.join()
    canopy = bpy.context.active_object
    canopy.name = "tree_canopy_cards"
    return canopy


def add_outline_hull(trunk_top, tree_h):
    # A tiny low-poly hull helps silhouette readability in top-down view.
    bpy.ops.mesh.primitive_ico_sphere_add(
        subdivisions=1,
        radius=tree_h * 0.34,
        location=(0.0, 0.0, trunk_top + tree_h * 0.33),
    )
    hull = bpy.context.active_object
    hull.name = "tree_canopy_hull"
    hull.scale = (1.18, 1.08, 0.86)
    return hull


def make_hull_material():
    mat = bpy.data.materials.new(name="M_Tree_Hull_Shade")
    mat.use_nodes = True
    bsdf = next((n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf:
        bsdf.inputs["Base Color"].default_value = (0.07, 0.24, 0.11, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.95
        if "Specular IOR Level" in bsdf.inputs:
            bsdf.inputs["Specular IOR Level"].default_value = 0.02
    return mat


def set_shading_flat(obj):
    select_only(obj)
    bpy.ops.object.shade_flat()


def triangulate(obj):
    tri = obj.modifiers.new(name="Triangulate", type="TRIANGULATE")
    select_only(obj)
    bpy.ops.object.modifier_apply(modifier=tri.name)


def count_tris(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


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
    trunk_h = tree_h * 0.40
    trunk_r = tree_h * 0.075
    trunk_top = trunk_h

    remove_mesh_objects(meshes)

    trunk = build_trunk(height=trunk_h, radius=trunk_r)
    canopy_cards = build_canopy_cards(trunk_top=trunk_top, tree_h=tree_h, layers=args.layers)
    canopy_hull = add_outline_hull(trunk_top=trunk_top, tree_h=tree_h)

    trunk_mat = make_trunk_material(args.seed)
    leaf_mat = make_leaf_material(args.seed)
    hull_mat = make_hull_material()

    trunk.data.materials.clear()
    trunk.data.materials.append(trunk_mat)
    canopy_cards.data.materials.clear()
    canopy_cards.data.materials.append(leaf_mat)
    canopy_hull.data.materials.clear()
    canopy_hull.data.materials.append(hull_mat)

    set_shading_flat(trunk)
    set_shading_flat(canopy_cards)
    set_shading_flat(canopy_hull)

    triangulate(trunk)
    triangulate(canopy_cards)
    triangulate(canopy_hull)

    tri_trunk = count_tris(trunk)
    tri_cards = count_tris(canopy_cards)
    tri_hull = count_tris(canopy_hull)
    tri_total = tri_trunk + tri_cards + tri_hull

    ensure_parent(args.output)
    export_glb(args.output)
    print(
        f"[done] tris trunk={tri_trunk}, cards={tri_cards}, hull={tri_hull}, total={tri_total}"
    )


if __name__ == "__main__":
    main()
