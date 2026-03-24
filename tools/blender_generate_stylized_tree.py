import argparse
import math
import os
import random
import sys

import bpy


def parse_args():
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1 :]
    else:
        argv = []

    parser = argparse.ArgumentParser(
        description="Generate a stylized low-poly tree and export GLB."
    )
    parser.add_argument("--output", required=True, help="Output .glb path")
    parser.add_argument("--target", type=int, default=450, help="Target total face count")
    parser.add_argument("--seed", type=int, default=7, help="Random seed")
    parser.add_argument("--height", type=float, default=2.2, help="Tree height in meters")
    parser.add_argument(
        "--leaf-rough", type=float, default=0.06, help="Canopy displacement strength"
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


def add_trunk(height):
    trunk_h = height * 0.95
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=10,
        radius=height * 0.095,
        depth=trunk_h,
        location=(0.0, 0.0, trunk_h * 0.5),
    )
    trunk = bpy.context.active_object
    trunk.name = "tree_trunk"

    # Slight taper for a less synthetic shape.
    select_only(trunk)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_mode(type="VERT")
    bpy.ops.mesh.select_all(action="DESELECT")
    bpy.ops.object.mode_set(mode="OBJECT")
    z_mid = trunk_h * 0.52
    for v in trunk.data.vertices:
        if v.co.z > z_mid:
            v.select = True
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.transform.resize(value=(0.72, 0.72, 1.0))
    bpy.ops.object.mode_set(mode="OBJECT")

    return trunk


def add_canopy_clumps(height, rng):
    clumps = []

    # Layered canopy similar to clustered hand-painted trees.
    layers = [
        (height * 1.15, 0.24, 6, height * 0.19),
        (height * 1.35, 0.19, 5, height * 0.17),
        (height * 1.55, 0.12, 4, height * 0.14),
    ]

    for z, ring_r, count, base_size in layers:
        for i in range(count):
            angle = (2.0 * math.pi * i / max(1, count)) + rng.uniform(-0.22, 0.22)
            jitter_r = ring_r + rng.uniform(-0.04, 0.04)
            x = math.cos(angle) * jitter_r
            y = math.sin(angle) * jitter_r
            radius = base_size * rng.uniform(0.84, 1.18)
            bpy.ops.mesh.primitive_ico_sphere_add(
                subdivisions=1, radius=radius, location=(x, y, z)
            )
            sph = bpy.context.active_object
            sph.name = f"leaf_{len(clumps):02d}"
            sph.scale = (
                rng.uniform(0.9, 1.15),
                rng.uniform(0.9, 1.15),
                rng.uniform(0.85, 1.1),
            )
            clumps.append(sph)

    # Central fill clumps to avoid hollow middle.
    for _ in range(3):
        bpy.ops.mesh.primitive_ico_sphere_add(
            subdivisions=1,
            radius=height * rng.uniform(0.14, 0.18),
            location=(
                rng.uniform(-0.06, 0.06),
                rng.uniform(-0.06, 0.06),
                rng.uniform(height * 1.25, height * 1.45),
            ),
        )
        clumps.append(bpy.context.active_object)

    select_only(clumps[0])
    for obj in clumps[1:]:
        obj.select_set(True)
    bpy.ops.object.join()
    canopy = bpy.context.active_object
    canopy.name = "tree_canopy"
    return canopy


def fuse_and_decimate_canopy(canopy, target_faces, rough_strength):
    # Keep clustered silhouette while reducing micro-noise.
    select_only(canopy)
    rem = canopy.modifiers.new(name="VoxelRemesh", type="REMESH")
    rem.mode = "VOXEL"
    rem.voxel_size = 0.06
    rem.use_smooth_shade = False
    rem.use_remove_disconnected = True
    bpy.ops.object.modifier_apply(modifier=rem.name)

    # Give canopy a leafy, uneven surface instead of a plastic smooth dome.
    noise_tex = bpy.data.textures.new(name="LeafNoise", type="CLOUDS")
    noise_tex.noise_scale = 0.28
    noise_tex.noise_depth = 2
    dis = canopy.modifiers.new(name="LeafDisplace", type="DISPLACE")
    dis.texture = noise_tex
    dis.mid_level = 0.5
    dis.strength = max(0.0, rough_strength)
    bpy.ops.object.modifier_apply(modifier=dis.name)

    tri = canopy.modifiers.new(name="Triangulate", type="TRIANGULATE")
    bpy.ops.object.modifier_apply(modifier=tri.name)

    now = len(canopy.data.polygons)
    if now <= target_faces:
        return now

    ratio = max(0.0001, min(1.0, float(target_faces) / float(now)))
    dec = canopy.modifiers.new(name="Decimate", type="DECIMATE")
    dec.decimate_type = "COLLAPSE"
    dec.ratio = ratio
    dec.use_collapse_triangulate = True
    bpy.ops.object.modifier_apply(modifier=dec.name)
    after = len(canopy.data.polygons)
    if after > target_faces * 1.08:
        ratio2 = max(0.0001, min(1.0, float(target_faces) / float(after)))
        dec2 = canopy.modifiers.new(name="Decimate2", type="DECIMATE")
        dec2.decimate_type = "COLLAPSE"
        dec2.ratio = ratio2
        dec2.use_collapse_triangulate = True
        bpy.ops.object.modifier_apply(modifier=dec2.name)
        after = len(canopy.data.polygons)
    return after


def smart_uv(obj, angle_deg=66.0, margin=0.01):
    select_only(obj)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(
        angle_limit=math.radians(angle_deg), island_margin=margin, area_weight=0.2
    )
    bpy.ops.object.mode_set(mode="OBJECT")


def make_leaf_texture(seed, size=256):
    rng = random.Random(seed)
    img = bpy.data.images.new("IMG_Leaf_Diffuse", width=size, height=size, alpha=False)

    blobs = []
    for _ in range(55):
        blobs.append(
            (
                rng.random(),
                rng.random(),
                rng.uniform(0.05, 0.18),
                rng.uniform(-0.20, 0.18),
            )
        )

    pixels = [0.0] * (size * size * 4)
    p = 0
    for y in range(size):
        ny = y / float(size - 1)
        for x in range(size):
            nx = x / float(size - 1)
            n = 0.0
            for bx, by, br, ba in blobs:
                dx = nx - bx
                dy = ny - by
                d = (dx * dx + dy * dy) / (br * br)
                if d < 1.0:
                    n += ba * (1.0 - d) * (1.0 - d)

            grain = 0.5 + 0.5 * math.sin(nx * 42.0 + ny * 31.0 + seed * 0.13)
            shade = min(1.0, max(0.0, 0.58 + 0.20 * ny + n + (grain - 0.5) * 0.16))

            r = min(1.0, max(0.0, 0.08 + 0.12 * shade))
            g = min(1.0, max(0.0, 0.22 + 0.55 * shade))
            b = min(1.0, max(0.0, 0.07 + 0.20 * shade))

            # Dark speckles to imitate leaf clumps/inked creases.
            spot = abs(math.sin(nx * 75.0 + ny * 51.0 + seed * 0.2))
            if spot > 0.94:
                r *= 0.72
                g *= 0.72
                b *= 0.72

            pixels[p + 0] = r
            pixels[p + 1] = g
            pixels[p + 2] = b
            pixels[p + 3] = 1.0
            p += 4

    img.pixels = pixels
    img.pack()
    return img


def make_bark_texture(seed, w=128, h=256):
    rng = random.Random(seed + 101)
    img = bpy.data.images.new("IMG_Bark_Diffuse", width=w, height=h, alpha=False)
    pixels = [0.0] * (w * h * 4)
    p = 0
    bands = [rng.uniform(0.8, 1.3) for _ in range(6)]
    for y in range(h):
        ny = y / float(h - 1)
        for x in range(w):
            nx = x / float(w - 1)
            stripe = 0.0
            for i, amp in enumerate(bands):
                stripe += math.sin(nx * (12.0 + i * 7.0) + ny * (1.4 + i * 0.6)) * amp
            stripe = stripe / (len(bands) * 1.3)
            shade = min(1.0, max(0.0, 0.55 + stripe * 0.25 + ny * 0.08))
            r = 0.11 + shade * 0.16
            g = 0.07 + shade * 0.11
            b = 0.05 + shade * 0.08
            pixels[p + 0] = min(1.0, max(0.0, r))
            pixels[p + 1] = min(1.0, max(0.0, g))
            pixels[p + 2] = min(1.0, max(0.0, b))
            pixels[p + 3] = 1.0
            p += 4
    img.pixels = pixels
    img.pack()
    return img


def add_materials(trunk, canopy, seed):
    trunk_img = make_bark_texture(seed)
    leaf_img = make_leaf_texture(seed)

    mat_trunk = bpy.data.materials.new(name="M_Tree_Trunk")
    mat_trunk.use_nodes = True
    nt_t = mat_trunk.node_tree
    nodes_t = nt_t.nodes
    links_t = nt_t.links
    bsdf_t = next((n for n in nodes_t if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf_t is None:
        bsdf_t = nodes_t.new("ShaderNodeBsdfPrincipled")
    tex_t = nodes_t.new("ShaderNodeTexImage")
    tex_t.image = trunk_img
    links_t.new(tex_t.outputs["Color"], bsdf_t.inputs["Base Color"])
    bsdf_t.inputs["Roughness"].default_value = 0.93
    bsdf_t.inputs["Specular IOR Level"].default_value = 0.15

    mat_leaf = bpy.data.materials.new(name="M_Tree_Leaf")
    mat_leaf.use_nodes = True
    nt_l = mat_leaf.node_tree
    nodes_l = nt_l.nodes
    links_l = nt_l.links
    bsdf_l = next((n for n in nodes_l if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf_l is None:
        bsdf_l = nodes_l.new("ShaderNodeBsdfPrincipled")
    tex_l = nodes_l.new("ShaderNodeTexImage")
    tex_l.image = leaf_img
    links_l.new(tex_l.outputs["Color"], bsdf_l.inputs["Base Color"])
    bsdf_l.inputs["Roughness"].default_value = 0.90
    bsdf_l.inputs["Metallic"].default_value = 0.0
    bsdf_l.inputs["Specular IOR Level"].default_value = 0.10

    trunk.data.materials.clear()
    trunk.data.materials.append(mat_trunk)

    canopy.data.materials.clear()
    canopy.data.materials.append(mat_leaf)


def smooth_trunk(obj, angle_deg):
    select_only(obj)
    bpy.ops.object.shade_smooth_by_angle(
        angle=math.radians(angle_deg), keep_sharp_edges=True
    )
    wn = obj.modifiers.new(name="WeightedNormal", type="WEIGHTED_NORMAL")
    wn.keep_sharp = True
    wn.weight = 50
    bpy.ops.object.modifier_apply(modifier=wn.name)


def shade_canopy(obj):
    # Keep facets visible so canopy reads as leaves, not plastic.
    select_only(obj)
    bpy.ops.object.shade_flat()


def decimate_trunk_if_needed(trunk, max_faces):
    faces = len(trunk.data.polygons)
    if faces <= max_faces:
        return faces
    ratio = max(0.0001, min(1.0, float(max_faces) / float(faces)))
    dec = trunk.modifiers.new(name="DecimateTrunk", type="DECIMATE")
    dec.decimate_type = "COLLAPSE"
    dec.ratio = ratio
    select_only(trunk)
    bpy.ops.object.modifier_apply(modifier=dec.name)
    return len(trunk.data.polygons)


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
    if args.target <= 120:
        raise ValueError("--target too low, use >= 120")

    rng = random.Random(args.seed)

    clear_scene()
    trunk = add_trunk(args.height)
    canopy = add_canopy_clumps(args.height, rng)

    target_trunk = max(28, int(args.target * 0.12))
    target_canopy = max(80, args.target - target_trunk)

    canopy_faces = fuse_and_decimate_canopy(canopy, target_canopy, args.leaf_rough)
    trunk_faces = decimate_trunk_if_needed(trunk, target_trunk)

    smart_uv(trunk, angle_deg=66.0, margin=0.02)
    smart_uv(canopy, angle_deg=60.0, margin=0.01)
    add_materials(trunk, canopy, args.seed)
    smooth_trunk(trunk, 34.0)
    shade_canopy(canopy)

    total_faces = len(trunk.data.polygons) + len(canopy.data.polygons)

    ensure_parent(args.output)
    export_glb(args.output)
    print(
        f"[done] faces trunk={trunk_faces}, canopy={canopy_faces}, total={total_faces}, target={args.target}"
    )


if __name__ == "__main__":
    main()
