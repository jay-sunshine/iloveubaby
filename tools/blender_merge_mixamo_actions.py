import argparse
import os
import re
import sys

import bpy
from mathutils import Matrix, Vector, kdtree

# Weapon placement tweak knobs (fast iteration without touching core logic).
SHIELD_SIDE_OFFSET = 0.12
SHIELD_UP_OFFSET = 0.02
SHIELD_FORWARD_OFFSET = 0.00
SHIELD_ROT_UP_DEG = 90.0
SHIELD_EXTRA_DOWN_AFTER_FLIP = 0.00
SWORD_SIDE_OFFSET = 0.00
SWORD_DOWN_OFFSET = 0.30
SWORD_FORWARD_OFFSET = 0.06
SWORD_ROT_SIDE_DEG = 0.0
SWORD_ROT_UP_DEG = 0.0

# Whole-character rig fit fine-tune (mesh vs skeleton overlap).
# Applied to the FINAL bound mesh only, after automatic/reference alignment.
CHARACTER_EXTRA_SCALE = 1.0
CHARACTER_EXTRA_OFFSET_X = 0.0
CHARACTER_EXTRA_OFFSET_Y = 0.0
CHARACTER_EXTRA_OFFSET_Z = 0.0

# Material stylize: this troop source uses grayscale palette, which looks too dark in Godot.
# Recolor body texture into a readable steel-like ramp while keeping UV detail.
FORCE_STYLIZE_BODY_TEXTURE = True
# Add simple armor shell meshes to hide body joint seams.
ENABLE_ARMOR_SHELLS = True


def is_helper_mesh_name(name):
    n = (name or "").lower()
    return ("\u68f1\u89d2\u7403" in n) or ("icosphere" in n)


def parse_args():
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1 :]
    else:
        argv = []

    parser = argparse.ArgumentParser(
        description="Merge Mixamo FBX actions into one animated GLB for Godot."
    )
    parser.add_argument("--base-fbx", default="", help="Mixamo character FBX (with skin)")
    parser.add_argument(
        "--base-glb",
        default="",
        help="Existing game model GLB to bind on Mixamo skeleton (no Mixamo skin needed).",
    )
    parser.add_argument(
        "--bind-fbx",
        default="",
        help="Optional Mixamo FBX(with skin) used as rig+weight reference for --base-glb.",
    )
    parser.add_argument(
        "--anim-dir",
        required=True,
        help="Directory of Mixamo animation FBX files (prefer without skin)",
    )
    parser.add_argument("--out-glb", required=True, help="Output animated GLB path")
    parser.add_argument(
        "--name-prefix",
        default="",
        help="Optional clip name prefix, e.g. infantry_",
    )
    parser.add_argument(
        "--disable-weapon-split",
        action="store_true",
        help="Keep original mesh as one skinned body and do not split/rigid-bind sword/shield.",
    )
    args = parser.parse_args(argv)

    if not args.base_fbx and not args.base_glb:
        parser.error("One of --base-fbx or --base-glb is required.")
    return args


def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def import_fbx(path):
    before_objs = set(bpy.data.objects)
    before_actions = set(bpy.data.actions)
    bpy.ops.import_scene.fbx(filepath=path)
    after_objs = set(bpy.data.objects)
    after_actions = set(bpy.data.actions)
    return list(after_objs - before_objs), list(after_actions - before_actions)


def import_glb(path):
    before_objs = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    after_objs = set(bpy.data.objects)
    return list(after_objs - before_objs)


def list_anim_files(anim_dir):
    files = [
        os.path.join(anim_dir, f)
        for f in os.listdir(anim_dir)
        if f.lower().endswith(".fbx")
    ]
    files.sort()
    return files


def find_main_armature(objects):
    arms = [o for o in objects if o.type == "ARMATURE"]
    if not arms:
        return None
    arms.sort(key=lambda a: len(a.data.bones), reverse=True)
    return arms[0]


def find_scene_armature():
    arms = [o for o in bpy.data.objects if o.type == "ARMATURE"]
    if not arms:
        return None
    arms.sort(key=lambda a: len(a.data.bones), reverse=True)
    return arms[0]


def find_largest_mesh(objects):
    meshes = [o for o in objects if o.type == "MESH"]
    if not meshes:
        return None
    meshes.sort(key=lambda m: len(m.data.vertices), reverse=True)
    return meshes[0]


def join_mesh_objects(meshes, out_name):
    if not meshes:
        return None
    if len(meshes) == 1:
        meshes[0].name = out_name
        return meshes[0]

    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
    out = bpy.context.active_object
    out.name = out_name
    return out


def count_nonzero_weight_vertices(mesh_obj):
    c = 0
    for v in mesh_obj.data.vertices:
        has_weight = False
        for g in v.groups:
            if g.weight > 1e-6:
                has_weight = True
                break
        if has_weight:
            c += 1
    return c


def transfer_weights_by_nearest_vertex(src_mesh_obj, dst_mesh_obj):
    # Rebuild vertex groups from source weights.
    for vg in list(dst_mesh_obj.vertex_groups):
        dst_mesh_obj.vertex_groups.remove(vg)

    src_groups = [g.name for g in src_mesh_obj.vertex_groups]
    if not src_groups:
        return
    dst_group_by_name = {}
    for name in src_groups:
        dst_group_by_name[name] = dst_mesh_obj.vertex_groups.new(name=name)

    kd = kdtree.KDTree(len(src_mesh_obj.data.vertices))
    for v in src_mesh_obj.data.vertices:
        world_p = src_mesh_obj.matrix_world @ v.co
        kd.insert(world_p, v.index)
    kd.balance()

    for dst_v in dst_mesh_obj.data.vertices:
        dst_world = dst_mesh_obj.matrix_world @ dst_v.co
        _co, src_idx, _dist = kd.find(dst_world)
        src_v = src_mesh_obj.data.vertices[src_idx]
        for g in src_v.groups:
            if g.weight <= 1e-6:
                continue
            src_name = src_mesh_obj.vertex_groups[g.group].name
            dst_group_by_name[src_name].add([dst_v.index], g.weight, "REPLACE")


def collect_nonweapon_vertex_indices(mesh_obj):
    weapon_tokens = ("weapon", "sword", "shield")
    mesh = mesh_obj.data
    keep = set()
    for poly in mesh.polygons:
        mat_name = ""
        if poly.material_index < len(mesh.materials):
            mat = mesh.materials[poly.material_index]
            if mat is not None:
                mat_name = mat.name.lower()
        is_weapon = any(t in mat_name for t in weapon_tokens)
        if is_weapon:
            continue
        for vid in poly.vertices:
            keep.add(vid)
    if not keep:
        keep = set(v.index for v in mesh.vertices)
    return keep


def compute_pelvis_centroid(mesh_obj, arm_obj, radius=0.25):
    hips = arm_obj.data.bones.get("mixamorig:Hips")
    if hips is None:
        hips = arm_obj.data.bones.get("Hips")
    if hips is None:
        return None
    hips_world = arm_obj.matrix_world @ hips.head_local

    keep_vids = collect_nonweapon_vertex_indices(mesh_obj)
    pts = []
    for v in mesh_obj.data.vertices:
        if v.index not in keep_vids:
            continue
        p = mesh_obj.matrix_world @ v.co
        if (p - hips_world).length <= radius:
            pts.append(p)
    if not pts:
        return None
    c = Vector((0.0, 0.0, 0.0))
    for p in pts:
        c += p
    return c / len(pts)


def align_mesh_pelvis_to_reference(base_mesh_obj, ref_mesh_obj, arm_obj):
    base_c = compute_pelvis_centroid(base_mesh_obj, arm_obj, radius=0.26)
    ref_c = compute_pelvis_centroid(ref_mesh_obj, arm_obj, radius=0.26)
    if base_c is None or ref_c is None:
        return
    delta = ref_c - base_c
    if delta.length <= 1e-6:
        return
    base_mesh_obj.location += delta
    bpy.context.view_layer.update()
    print(
        "[pelvis-align] delta=(%.4f, %.4f, %.4f)"
        % (delta.x, delta.y, delta.z)
    )


def ensure_armature_modifier(mesh_obj, arm_obj):
    arm_mod = None
    for md in mesh_obj.modifiers:
        if md.type == "ARMATURE":
            arm_mod = md
            break
    if arm_mod is None:
        arm_mod = mesh_obj.modifiers.new(name="Armature", type="ARMATURE")
    arm_mod.object = arm_obj
    mesh_obj.parent = arm_obj
    mesh_obj.matrix_parent_inverse = arm_obj.matrix_world.inverted()


def _lerp_rgb(a, b, t):
    return (
        a[0] + (b[0] - a[0]) * t,
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
    )


def recolor_image_to_armor_steel(image):
    if image is None or image.size[0] <= 0 or image.size[1] <= 0:
        return False

    px = list(image.pixels[:])
    if not px:
        return False

    # Dark->mid->light steel tones. Keep alpha unchanged.
    c0 = (0.11, 0.12, 0.14)
    c1 = (0.30, 0.32, 0.36)
    c2 = (0.54, 0.57, 0.62)
    c3 = (0.84, 0.86, 0.90)

    changed = False
    for i in range(0, len(px), 4):
        r = px[i + 0]
        g = px[i + 1]
        b = px[i + 2]
        # Convert to luminance then remap to avoid crushed blacks.
        gray = 0.2126 * r + 0.7152 * g + 0.0722 * b
        gray = max(0.0, min(1.0, (gray - 0.05) / 0.95))

        if gray < 0.33:
            col = _lerp_rgb(c0, c1, gray / 0.33)
        elif gray < 0.70:
            col = _lerp_rgb(c1, c2, (gray - 0.33) / 0.37)
        else:
            col = _lerp_rgb(c2, c3, (gray - 0.70) / 0.30)

        px[i + 0] = col[0]
        px[i + 1] = col[1]
        px[i + 2] = col[2]
        changed = True

    if not changed:
        return False

    image.pixels[:] = px
    image.update()
    return True


def stylize_body_material_textures(mesh_objs):
    if not FORCE_STYLIZE_BODY_TEXTURE:
        return
    done = set()
    for obj in mesh_objs:
        if obj is None or obj.type != "MESH" or obj.name not in bpy.data.objects:
            continue
        for mat in obj.data.materials:
            if mat is None or not mat.use_nodes or mat.node_tree is None:
                continue
            low_name = mat.name.lower()
            if any(k in low_name for k in ("weapon", "sword", "shield")):
                continue
            for n in mat.node_tree.nodes:
                if n.type != "TEX_IMAGE" or n.image is None:
                    continue
                img = n.image
                if img.name in done:
                    continue
                if recolor_image_to_armor_steel(img):
                    done.add(img.name)
                    print(f"[stylize] recolored body texture: {img.name}")


def mesh_world_centroid(mesh_obj):
    verts = mesh_obj.data.vertices
    if not verts:
        return mesh_obj.matrix_world.translation.copy()
    acc = Vector((0.0, 0.0, 0.0))
    for v in verts:
        acc += mesh_obj.matrix_world @ v.co
    return acc / max(1, len(verts))


def split_mesh_by_material(mesh_obj):
    bpy.ops.object.select_all(action="DESELECT")
    mesh_obj.select_set(True)
    bpy.context.view_layer.objects.active = mesh_obj
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.separate(type="MATERIAL")
    bpy.ops.object.mode_set(mode="OBJECT")

    parts = [o for o in bpy.context.selected_objects if o.type == "MESH"]
    if mesh_obj.name in bpy.data.objects:
        src = bpy.data.objects[mesh_obj.name]
        if src not in parts:
            parts.append(src)
    return parts


def pick_bone_name(names, exact_candidates, token):
    lowered = {n.lower(): n for n in names}
    for key in exact_candidates:
        if key in lowered:
            return lowered[key]
    cands = [n for n in names if token in n.lower() and "finger" not in n.lower()]
    if cands:
        cands.sort(key=len)
        return cands[0]
    return ""


def find_hand_bones(arm_obj):
    names = [b.name for b in arm_obj.data.bones]
    left = pick_bone_name(
        names,
        ["mixamorig:lefthand", "lefthand", "hand_l", "l_hand", "left_hand"],
        "lefthand",
    )
    right = pick_bone_name(
        names,
        ["mixamorig:righthand", "righthand", "hand_r", "r_hand", "right_hand"],
        "righthand",
    )
    return left, right


def find_forearm_bones(arm_obj):
    names = [b.name for b in arm_obj.data.bones]
    left = pick_bone_name(
        names,
        ["mixamorig:leftforearm", "leftforearm", "forearm_l", "l_forearm", "left_lowerarm"],
        "leftforearm",
    )
    right = pick_bone_name(
        names,
        ["mixamorig:rightforearm", "rightforearm", "forearm_r", "r_forearm", "right_lowerarm"],
        "rightforearm",
    )
    return left, right


def rigid_bind_to_bone(mesh_obj, arm_obj, bone_name):
    if not bone_name:
        return
    for vg in list(mesh_obj.vertex_groups):
        mesh_obj.vertex_groups.remove(vg)
    vg = mesh_obj.vertex_groups.new(name=bone_name)
    all_indices = [v.index for v in mesh_obj.data.vertices]
    if all_indices:
        vg.add(all_indices, 1.0, "REPLACE")
    ensure_armature_modifier(mesh_obj, arm_obj)


def find_bone_name(arm_obj, exact_candidates, token=""):
    names = [b.name for b in arm_obj.data.bones]
    lowered = {n.lower(): n for n in names}
    for key in exact_candidates:
        if key.lower() in lowered:
            return lowered[key.lower()]
    if token:
        hits = [n for n in names if token in n.lower()]
        if hits:
            hits.sort(key=len)
            return hits[0]
    return ""


def get_or_create_armor_shell_material():
    mat = bpy.data.materials.get("ArmorShellMat")
    if mat is None:
        mat = bpy.data.materials.new(name="ArmorShellMat")
    mat.use_nodes = True
    if mat.node_tree is not None:
        bsdf = None
        for n in mat.node_tree.nodes:
            if n.type == "BSDF_PRINCIPLED":
                bsdf = n
                break
        if bsdf is not None:
            bsdf.inputs["Base Color"].default_value = (0.28, 0.31, 0.36, 1.0)
            bsdf.inputs["Metallic"].default_value = 0.05
            bsdf.inputs["Roughness"].default_value = 0.62
    return mat


def create_box_shell(name, center_world, size_xyz, material=None, rotation_euler=None):
    if rotation_euler is None:
        rotation_euler = (0.0, 0.0, 0.0)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=center_world, rotation=rotation_euler)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = Vector((size_xyz.x * 0.5, size_xyz.y * 0.5, size_xyz.z * 0.5))
    bpy.context.view_layer.update()
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    if material is not None:
        if len(obj.data.materials) <= 0:
            obj.data.materials.append(material)
        else:
            obj.data.materials[0] = material
    return obj


def create_limb_shell_piece(
    arm_obj,
    bone_name,
    piece_name,
    width,
    depth,
    length_scale,
    offset_forward=0.0,
    offset_side=0.0,
    material=None,
):
    head, tail = get_bone_rest_head_tail_world(arm_obj, bone_name)
    if head is None or tail is None:
        return None
    axis = tail - head
    blen = axis.length
    if blen <= 1e-6:
        return None

    left_hand, right_hand = find_hand_bones(arm_obj)
    side = get_side_world_dir(arm_obj, left_hand, right_hand)
    forward = Vector((0.0, 1.0, 0.0))

    center = (head + tail) * 0.5 + forward * offset_forward + side * offset_side
    rot = axis.normalized().to_track_quat("Z", "Y").to_euler()
    piece = create_box_shell(
        piece_name,
        center,
        Vector((width, depth, max(0.06, blen * length_scale))),
        material=material,
        rotation_euler=rot,
    )
    rigid_bind_to_bone(piece, arm_obj, bone_name)
    return piece


def add_armor_shell_pieces(arm_obj):
    if not ENABLE_ARMOR_SHELLS or arm_obj is None:
        return []
    mat = get_or_create_armor_shell_material()
    pieces = []

    left_hand, right_hand = find_hand_bones(arm_obj)
    side = get_side_world_dir(arm_obj, left_hand, right_hand)
    forward = Vector((0.0, 1.0, 0.0))

    spine2 = find_bone_name(
        arm_obj,
        ["mixamorig:Spine2", "Spine2", "mixamorig:Spine1", "Spine1"],
        token="spine2",
    )
    hips = find_bone_name(arm_obj, ["mixamorig:Hips", "Hips"], token="hips")

    l_arm = find_bone_name(arm_obj, ["mixamorig:LeftArm", "LeftArm"], token="leftarm")
    r_arm = find_bone_name(arm_obj, ["mixamorig:RightArm", "RightArm"], token="rightarm")
    l_forearm = find_bone_name(
        arm_obj,
        ["mixamorig:LeftForeArm", "LeftForeArm", "mixamorig:LeftForearm", "LeftForearm"],
        token="leftforearm",
    )
    r_forearm = find_bone_name(
        arm_obj,
        ["mixamorig:RightForeArm", "RightForeArm", "mixamorig:RightForearm", "RightForearm"],
        token="rightforearm",
    )
    l_thigh = find_bone_name(arm_obj, ["mixamorig:LeftUpLeg", "LeftUpLeg"], token="leftupleg")
    r_thigh = find_bone_name(
        arm_obj, ["mixamorig:RightUpLeg", "RightUpLeg"], token="rightupleg"
    )
    l_leg = find_bone_name(arm_obj, ["mixamorig:LeftLeg", "LeftLeg"], token="leftleg")
    r_leg = find_bone_name(arm_obj, ["mixamorig:RightLeg", "RightLeg"], token="rightleg")

    if spine2:
        s_head, s_tail = get_bone_rest_head_tail_world(arm_obj, spine2)
        if s_head is not None and s_tail is not None:
            chest_c = (s_head + s_tail) * 0.5 + forward * 0.10
            back_c = (s_head + s_tail) * 0.5 + forward * -0.08
            chest = create_box_shell(
                "ArmorChestFront", chest_c, Vector((0.42, 0.08, 0.30)), material=mat
            )
            back = create_box_shell(
                "ArmorBack", back_c, Vector((0.40, 0.07, 0.28)), material=mat
            )
            rigid_bind_to_bone(chest, arm_obj, spine2)
            rigid_bind_to_bone(back, arm_obj, spine2)
            pieces.extend([chest, back])

    if hips:
        h_head, _h_tail = get_bone_rest_head_tail_world(arm_obj, hips)
        if h_head is not None:
            skirt_f = create_box_shell(
                "ArmorSkirtFront",
                h_head + forward * 0.11 + Vector((0.0, 0.0, -0.11)),
                Vector((0.36, 0.03, 0.20)),
                material=mat,
            )
            skirt_b = create_box_shell(
                "ArmorSkirtBack",
                h_head + forward * -0.08 + Vector((0.0, 0.0, -0.10)),
                Vector((0.34, 0.03, 0.16)),
                material=mat,
            )
            rigid_bind_to_bone(skirt_f, arm_obj, hips)
            rigid_bind_to_bone(skirt_b, arm_obj, hips)
            pieces.extend([skirt_f, skirt_b])

    for bn, nm, osign in (
        (l_arm, "ArmorShoulderL", 1.0),
        (r_arm, "ArmorShoulderR", -1.0),
    ):
        if not bn:
            continue
        head, _tail = get_bone_rest_head_tail_world(arm_obj, bn)
        if head is None:
            continue
        piece = create_box_shell(
            nm,
            head + side * (0.06 * osign) + forward * 0.02 + Vector((0.0, 0.0, 0.03)),
            Vector((0.14, 0.16, 0.10)),
            material=mat,
        )
        rigid_bind_to_bone(piece, arm_obj, bn)
        pieces.append(piece)

    for bn, nm, osign in (
        (l_forearm, "ArmorForearmL", 1.0),
        (r_forearm, "ArmorForearmR", -1.0),
    ):
        if bn:
            p = create_limb_shell_piece(
                arm_obj,
                bn,
                nm,
                width=0.11,
                depth=0.12,
                length_scale=0.72,
                offset_forward=0.03,
                offset_side=0.02 * osign,
                material=mat,
            )
            if p is not None:
                pieces.append(p)

    for bn, nm, osign in (
        (l_thigh, "ArmorThighL", 1.0),
        (r_thigh, "ArmorThighR", -1.0),
    ):
        if bn:
            p = create_limb_shell_piece(
                arm_obj,
                bn,
                nm,
                width=0.14,
                depth=0.13,
                length_scale=0.70,
                offset_forward=0.03,
                offset_side=0.02 * osign,
                material=mat,
            )
            if p is not None:
                pieces.append(p)

    for bn, nm, osign in (
        (l_leg, "ArmorShinL", 1.0),
        (r_leg, "ArmorShinR", -1.0),
    ):
        if bn:
            p = create_limb_shell_piece(
                arm_obj,
                bn,
                nm,
                width=0.13,
                depth=0.12,
                length_scale=0.85,
                offset_forward=0.04,
                offset_side=0.01 * osign,
                material=mat,
            )
            if p is not None:
                pieces.append(p)

    print(f"[armor-shell] pieces={len(pieces)}")
    return pieces


def get_bone_rest_head_tail_world(arm_obj, bone_name):
    if not bone_name:
        return None, None
    bone = arm_obj.data.bones.get(bone_name)
    if bone is None:
        return None, None
    head = arm_obj.matrix_world @ bone.head_local
    tail = arm_obj.matrix_world @ bone.tail_local
    return head, tail


def get_side_world_dir(arm_obj, left_bone, right_bone):
    lh, _lt = get_bone_rest_head_tail_world(arm_obj, left_bone)
    rh, _rt = get_bone_rest_head_tail_world(arm_obj, right_bone)
    if lh is None or rh is None:
        return Vector((1.0, 0.0, 0.0))
    side = lh - rh
    if side.length <= 1e-8:
        return Vector((1.0, 0.0, 0.0))
    side.normalize()
    return side


def snap_mesh_nearest_vertex_to_world_point(mesh_obj, target_world):
    if mesh_obj is None or target_world is None or len(mesh_obj.data.vertices) <= 0:
        return
    nearest = None
    best_d2 = 1e30
    for v in mesh_obj.data.vertices:
        world_v = mesh_obj.matrix_world @ v.co
        d2 = (world_v - target_world).length_squared
        if d2 < best_d2:
            best_d2 = d2
            nearest = world_v
    if nearest is None:
        return
    delta = target_world - nearest
    mesh_obj.location += delta
    bpy.context.view_layer.update()


def snap_mesh_centroid_to_world_point(mesh_obj, target_world):
    if mesh_obj is None or target_world is None or len(mesh_obj.data.vertices) <= 0:
        return
    center = mesh_world_centroid(mesh_obj)
    delta = target_world - center
    mesh_obj.location += delta
    bpy.context.view_layer.update()


def place_weapon_to_bone(mesh_obj, arm_obj, bone_name, extra_offset_world=None, use_centroid=False):
    head, _tail = get_bone_rest_head_tail_world(arm_obj, bone_name)
    if head is None:
        return
    offset = extra_offset_world if extra_offset_world is not None else Vector((0.0, 0.0, 0.0))
    target = head + offset
    if use_centroid:
        snap_mesh_centroid_to_world_point(mesh_obj, target)
    else:
        snap_mesh_nearest_vertex_to_world_point(mesh_obj, target)


def rotate_obj_about_axis_world(mesh_obj, pivot_world, axis_world, angle_rad):
    if mesh_obj is None or pivot_world is None or axis_world is None:
        return
    axis = axis_world.copy()
    if axis.length <= 1e-8:
        return
    axis.normalize()
    rot = Matrix.Rotation(angle_rad, 4, axis)
    t_pos = Matrix.Translation(pivot_world)
    t_neg = Matrix.Translation(-pivot_world)
    mesh_obj.matrix_world = t_pos @ rot @ t_neg @ mesh_obj.matrix_world
    bpy.context.view_layer.update()


def split_and_rigid_bind_weapons(mesh_obj, arm_obj):
    parts = split_mesh_by_material(mesh_obj)
    if not parts:
        return [mesh_obj]

    body_parts = []
    weapon_parts = []
    for obj in parts:
        mat_names = [
            (m.name.lower() if m is not None else "")
            for m in obj.data.materials
        ]
        is_weapon = any(("weapon" in n) or ("sword" in n) or ("shield" in n) for n in mat_names)
        if is_weapon:
            weapon_parts.append(obj)
        else:
            body_parts.append(obj)

    if not body_parts:
        largest = find_largest_mesh(parts)
        if largest is not None:
            body_parts = [largest]
            weapon_parts = [p for p in parts if p != largest]

    body_obj = join_mesh_objects(body_parts, "MixamoBodyMesh")
    if body_obj is not None:
        ensure_armature_modifier(body_obj, arm_obj)

    left_hand, right_hand = find_hand_bones(arm_obj)
    left_forearm, right_forearm = find_forearm_bones(arm_obj)

    left_part = None
    right_part = None
    if len(weapon_parts) >= 2 and left_hand and right_hand:
        left_h, _lt = get_bone_rest_head_tail_world(arm_obj, left_hand)
        right_h, _rt = get_bone_rest_head_tail_world(arm_obj, right_hand)
        if left_h is None or right_h is None:
            left_h = mesh_world_centroid(weapon_parts[0])
            right_h = mesh_world_centroid(weapon_parts[-1])
        center = (left_h + right_h) * 0.5
        side = left_h - right_h
        if side.length > 1e-8:
            side.normalize()
            scored = []
            for obj in weapon_parts:
                c = mesh_world_centroid(obj)
                score = (c - center).dot(side)
                scored.append((score, obj))
            scored.sort(key=lambda t: t[0], reverse=True)
            left_part = scored[0][1]
            right_part = scored[-1][1]

    for i, weapon_obj in enumerate(weapon_parts):
        weapon_obj.name = f"MixamoWeapon_{i + 1:02d}"

    if left_part is not None:
        left_part.name = "MixamoShield"
        target_left = left_forearm or left_hand
        side = get_side_world_dir(arm_obj, left_hand, right_hand)
        up = Vector((0.0, 0.0, 1.0))
        forward = Vector((0.0, 1.0, 0.0))
        place_weapon_to_bone(
            left_part,
            arm_obj,
            target_left,
            extra_offset_world=(
                side * SHIELD_SIDE_OFFSET
                + up * SHIELD_UP_OFFSET
                + forward * SHIELD_FORWARD_OFFSET
            ),
            use_centroid=True,
        )
        lh, _lt = get_bone_rest_head_tail_world(arm_obj, target_left)
        if lh is not None:
            # Keep shield close to forearm mount; avoid extra flips that throw it away.
            rotate_obj_about_axis_world(
                left_part,
                lh,
                up,
                SHIELD_ROT_UP_DEG * 3.141592653589793 / 180.0,
            )
            left_part.location += (-up) * SHIELD_EXTRA_DOWN_AFTER_FLIP
            bpy.context.view_layer.update()
        rigid_bind_to_bone(left_part, arm_obj, target_left)
    if right_part is not None:
        right_part.name = "MixamoSword"
        side = get_side_world_dir(arm_obj, left_hand, right_hand)
        target_right = right_hand or right_forearm
        up = Vector((0.0, 0.0, 1.0))
        forward = Vector((0.0, 1.0, 0.0))
        # User request: place sword under right hand.
        place_weapon_to_bone(
            right_part,
            arm_obj,
            target_right,
            extra_offset_world=(
                (-side) * SWORD_SIDE_OFFSET
                + (-up) * SWORD_DOWN_OFFSET
                + forward * SWORD_FORWARD_OFFSET
            ),
        )
        rh, _rt = get_bone_rest_head_tail_world(arm_obj, target_right)
        if rh is not None:
            rotate_obj_about_axis_world(
                right_part,
                rh,
                side,
                SWORD_ROT_SIDE_DEG * 3.141592653589793 / 180.0,
            )
            if abs(SWORD_ROT_UP_DEG) > 1e-6:
                rotate_obj_about_axis_world(
                    right_part,
                    rh,
                    up,
                    SWORD_ROT_UP_DEG * 3.141592653589793 / 180.0,
                )
        rigid_bind_to_bone(right_part, arm_obj, target_right)

    for weapon_obj in weapon_parts:
        if weapon_obj in (left_part, right_part):
            continue
        # Fallback for extra parts: attach to right hand.
        rigid_bind_to_bone(weapon_obj, arm_obj, right_hand or left_hand)

    export_meshes = []
    if body_obj is not None:
        export_meshes.append(body_obj)
    export_meshes.extend(weapon_parts)
    if not export_meshes:
        export_meshes = [mesh_obj]
    return export_meshes


def sanitize_action_name(raw_name):
    name = os.path.splitext(os.path.basename(raw_name))[0]
    name = re.sub(r"[^A-Za-z0-9_]+", "_", name).strip("_")
    if not name:
        name = "anim"
    return name


def pick_imported_action(imported_arm, new_actions):
    if imported_arm is not None:
        ad = imported_arm.animation_data
        if ad is not None and ad.action is not None:
            return ad.action
    if new_actions:
        ranked = sorted(new_actions, key=lambda a: len(a.fcurves), reverse=True)
        return ranked[0]
    return None


def remove_imported_objects(imported_objects):
    for obj in imported_objects:
        try:
            name = obj.name
        except ReferenceError:
            continue
        if name in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)


def bbox_world(obj):
    corners = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    min_v = Vector(
        (
            min(v.x for v in corners),
            min(v.y for v in corners),
            min(v.z for v in corners),
        )
    )
    max_v = Vector(
        (
            max(v.x for v in corners),
            max(v.y for v in corners),
            max(v.z for v in corners),
        )
    )
    return min_v, max_v


def align_mesh_to_armature(mesh_obj, arm_obj):
    mesh_min, mesh_max = bbox_world(mesh_obj)
    arm_min, arm_max = bbox_world(arm_obj)

    mesh_h = max(0.001, mesh_max.z - mesh_min.z)
    arm_h = max(0.001, arm_max.z - arm_min.z)
    s = arm_h / mesh_h
    mesh_obj.scale *= s
    bpy.context.view_layer.update()

    mesh_min, mesh_max = bbox_world(mesh_obj)
    mesh_center_xy = Vector(
        ((mesh_min.x + mesh_max.x) * 0.5, (mesh_min.y + mesh_max.y) * 0.5, 0.0)
    )
    arm_center_xy = Vector(
        ((arm_min.x + arm_max.x) * 0.5, (arm_min.y + arm_max.y) * 0.5, 0.0)
    )
    delta_xy = arm_center_xy - mesh_center_xy
    mesh_obj.location.x += delta_xy.x
    mesh_obj.location.y += delta_xy.y
    mesh_obj.location.z += arm_min.z - mesh_min.z
    bpy.context.view_layer.update()


def apply_character_extra_transform(mesh_obj):
    if abs(CHARACTER_EXTRA_SCALE - 1.0) > 1e-6:
        min_before, _ = bbox_world(mesh_obj)
        mesh_obj.scale *= CHARACTER_EXTRA_SCALE
        bpy.context.view_layer.update()
        min_after, _ = bbox_world(mesh_obj)
        # Keep feet contact after scale tweak.
        mesh_obj.location.z += min_before.z - min_after.z

    mesh_obj.location.x += CHARACTER_EXTRA_OFFSET_X
    mesh_obj.location.y += CHARACTER_EXTRA_OFFSET_Y
    mesh_obj.location.z += CHARACTER_EXTRA_OFFSET_Z
    bpy.context.view_layer.update()


def bind_mesh_to_armature(mesh_obj, arm_obj):
    def distance_point_to_segment(point, seg_a, seg_b):
        ab = seg_b - seg_a
        ab_len2 = ab.length_squared
        if ab_len2 <= 1e-12:
            return (point - seg_a).length
        t = max(0.0, min(1.0, (point - seg_a).dot(ab) / ab_len2))
        closest = seg_a + ab * t
        return (point - closest).length

    def bind_by_nearest_bone():
        # Clear previous empty groups.
        for vg in list(mesh_obj.vertex_groups):
            mesh_obj.vertex_groups.remove(vg)

        deform_bones = [b for b in arm_obj.data.bones if b.use_deform]
        if not deform_bones:
            deform_bones = list(arm_obj.data.bones)
        if not deform_bones:
            return

        group_by_bone = {}
        segments = []
        for bone in deform_bones:
            group_by_bone[bone.name] = mesh_obj.vertex_groups.new(name=bone.name)
            segments.append((bone.name, bone.head_local.copy(), bone.tail_local.copy()))

        arm_inv = arm_obj.matrix_world.inverted()
        for v in mesh_obj.data.vertices:
            world_p = mesh_obj.matrix_world @ v.co
            p = arm_inv @ world_p
            best_name = None
            best_d = 1e30
            for bone_name, a, b in segments:
                d = distance_point_to_segment(p, a, b)
                if d < best_d:
                    best_d = d
                    best_name = bone_name
            if best_name is not None:
                group_by_bone[best_name].add([v.index], 1.0, "REPLACE")

        # Ensure armature modifier exists.
        ensure_armature_modifier(mesh_obj, arm_obj)

    bpy.ops.object.select_all(action="DESELECT")
    mesh_obj.select_set(True)
    arm_obj.select_set(True)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.parent_set(type="ARMATURE_AUTO")

    # If heat bind fails (common on merged lowpoly meshes), fallback to envelopes.
    if count_nonzero_weight_vertices(mesh_obj) <= 0:
        bpy.ops.object.select_all(action="DESELECT")
        mesh_obj.select_set(True)
        arm_obj.select_set(True)
        bpy.context.view_layer.objects.active = arm_obj
        bpy.ops.object.parent_set(type="ARMATURE_ENVELOPE")

    # If still no effective weights, force nearest-bone rigid weights.
    if count_nonzero_weight_vertices(mesh_obj) <= 0:
        bind_by_nearest_bone()


def append_action_copy(merged, src_action, src_path, clip_prefix):
    act = src_action.copy()
    clip_name = sanitize_action_name(src_path)
    act.name = f"{clip_prefix}{clip_name}" if clip_prefix else clip_name
    # Convert Mixamo root translation to in-place to avoid jump/float on retargeted troops.
    stabilize_action_in_place(act)
    lower_name = act.name.lower()
    if "walk" in lower_name or "jog" in lower_name or "run" in lower_name:
        retime_action(act, 1.25)
    act.use_fake_user = True
    merged.append(act)
    print(f"[clip] {act.name}")


def stabilize_action_in_place(action):
    hips_paths = (
        'pose.bones["mixamorig:Hips"].location',
        'pose.bones["Hips"].location',
        "location",
    )
    removed_axes = 0
    for fc in list(action.fcurves):
        if fc.data_path not in hips_paths:
            continue
        if fc.array_index not in (0, 1, 2):
            continue
        action.fcurves.remove(fc)
        removed_axes += 1
    if removed_axes > 0:
        print(f"[inplace] {action.name} removed_loc_axes={removed_axes}")


def retime_action(action, factor):
    if factor <= 0.0 or abs(factor - 1.0) < 1e-6:
        return
    for fc in action.fcurves:
        points = fc.keyframe_points
        if not points:
            continue
        pivot = points[0].co[0]
        for kp in points:
            t = kp.co[0]
            l = kp.handle_left[0]
            r = kp.handle_right[0]
            kp.co[0] = pivot + (t - pivot) * factor
            kp.handle_left[0] = pivot + (l - pivot) * factor
            kp.handle_right[0] = pivot + (r - pivot) * factor
        fc.update()
    print(f"[retime] {action.name} x{factor:.2f}")


def merge_actions(base_armature, anim_files, clip_prefix, preloaded=None, preloaded_path=""):
    merged = []

    start_idx = 0
    if preloaded is not None and preloaded_path:
        append_action_copy(merged, preloaded, preloaded_path, clip_prefix)
        if anim_files and os.path.abspath(anim_files[0]) == os.path.abspath(preloaded_path):
            start_idx = 1

    for path in anim_files[start_idx:]:
        if preloaded_path and os.path.abspath(path) == os.path.abspath(preloaded_path):
            continue
        imported_objs, new_actions = import_fbx(path)
        imported_arm = find_main_armature(imported_objs)
        src_action = pick_imported_action(imported_arm, new_actions)
        if src_action is None:
            print(f"[warn] no action found in {path}, skip")
            remove_imported_objects(imported_objs)
            continue

        append_action_copy(merged, src_action, path, clip_prefix)
        remove_imported_objects(imported_objs)

    if not merged:
        raise RuntimeError("No animation clips merged. Check Mixamo FBX files.")

    base_armature.animation_data_create()
    base_armature.animation_data.action = merged[0]
    return merged


def keep_only_actions(keep_actions):
    keep_set = {a for a in keep_actions if a is not None}
    for obj in bpy.data.objects:
        ad = obj.animation_data
        if ad is not None and ad.action is not None and ad.action not in keep_set:
            ad.action = None
    for action in list(bpy.data.actions):
        if action not in keep_set:
            bpy.data.actions.remove(action)


def normalize_armature_scale_rotation(arm_obj, mesh_objs):
    if arm_obj is None or arm_obj.name not in bpy.data.objects:
        return
    valid_meshes = []
    for m in mesh_objs:
        if m is not None and m.name in bpy.data.objects:
            valid_meshes.append(bpy.data.objects[m.name])

    bpy.ops.object.select_all(action="DESELECT")
    bpy.data.objects[arm_obj.name].select_set(True)
    for m in valid_meshes:
        m.select_set(True)
    bpy.context.view_layer.objects.active = bpy.data.objects[arm_obj.name]

    # Bake FBX import scale/rotation (commonly 0.01 + 90deg) into rest transforms.
    # This avoids Armature scale mismatch in Godot editor/runtime.
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)


def get_first_bone_world_head(arm_obj, candidates):
    for name in candidates:
        bone = arm_obj.data.bones.get(name)
        if bone is not None:
            return arm_obj.matrix_world @ bone.head_local
    return None


def get_all_bone_world_heads(arm_obj, candidates):
    pts = []
    for name in candidates:
        bone = arm_obj.data.bones.get(name)
        if bone is not None:
            pts.append(arm_obj.matrix_world @ bone.head_local)
    return pts


def normalize_character_origin_to_feet(arm_obj, mesh_objs):
    if arm_obj is None or arm_obj.name not in bpy.data.objects:
        return
    meshes = []
    for m in mesh_objs:
        if m is not None and m.name in bpy.data.objects:
            meshes.append(bpy.data.objects[m.name])
    if not meshes:
        return

    left_names = [
        "mixamorig:LeftFoot",
        "mixamorig:LeftToeBase",
        "mixamorig:LeftToe_End",
        "LeftFoot",
        "LeftToeBase",
        "LeftToe_End",
    ]
    right_names = [
        "mixamorig:RightFoot",
        "mixamorig:RightToeBase",
        "mixamorig:RightToe_End",
        "RightFoot",
        "RightToeBase",
        "RightToe_End",
    ]

    left = get_first_bone_world_head(
        arm_obj,
        left_names,
    )
    right = get_first_bone_world_head(
        arm_obj,
        right_names,
    )
    foot_points = get_all_bone_world_heads(arm_obj, left_names) + get_all_bone_world_heads(
        arm_obj, right_names
    )

    if left is not None and right is not None:
        center_xy = (left + right) * 0.5
    elif foot_points:
        avg = Vector((0.0, 0.0, 0.0))
        for p in foot_points:
            avg += p
        avg /= max(1, len(foot_points))
        center_xy = Vector((avg.x, avg.y, 0.0))
    else:
        # Fallback to mesh bounds center on ground plane.
        all_min = Vector((1e20, 1e20, 1e20))
        all_max = Vector((-1e20, -1e20, -1e20))
        for m in meshes:
            mn, mx = bbox_world(m)
            all_min = Vector(
                (min(all_min.x, mn.x), min(all_min.y, mn.y), min(all_min.z, mn.z))
            )
            all_max = Vector(
                (max(all_max.x, mx.x), max(all_max.y, mx.y), max(all_max.z, mx.z))
            )
        center_xy = Vector(((all_min.x + all_max.x) * 0.5, (all_min.y + all_max.y) * 0.5, 0.0))

    if foot_points:
        # Use foot/toe bones to define ground. Mesh bound boxes are unreliable before armature deformation.
        ground_z = min(p.z for p in foot_points)
        source_tag = "bones"
    else:
        ground_z = 1e20
        for m in meshes:
            mn, _mx = bbox_world(m)
            ground_z = min(ground_z, mn.z)
        if ground_z > 1e19:
            ground_z = 0.0
        source_tag = "mesh"

    delta = Vector((-center_xy.x, -center_xy.y, -ground_z))
    if delta.length <= 1e-7:
        return

    bpy.data.objects[arm_obj.name].location += delta
    bpy.context.view_layer.update()
    print(
        "[origin-feet] source=%s center=(%.4f, %.4f) ground_z=%.4f delta=(%.4f, %.4f, %.4f)"
        % (source_tag, center_xy.x, center_xy.y, ground_z, delta.x, delta.y, delta.z)
    )


def export_glb(out_path, selected_objects=None):
    out_dir = os.path.dirname(out_path)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    # Strip helper gizmo meshes sometimes carried by imported FBX rigs.
    for arm_obj in [o for o in bpy.data.objects if o.type == "ARMATURE"]:
        for pb in arm_obj.pose.bones:
            pb.custom_shape = None
            pb.custom_shape_transform = None
    for obj in list(bpy.data.objects):
        if obj.type != "MESH":
            continue
        name_lower = obj.name.lower()
        has_helper_name = is_helper_mesh_name(name_lower)
        # Robust cleanup for tiny helper gizmos occasionally imported from FBX.
        if len(obj.data.vertices) <= 64 and not name_lower.startswith(
            ("mixamobodymesh", "mixamoboundmesh", "mixamoshield", "mixamosword", "armor")
        ):
            bpy.data.objects.remove(obj, do_unlink=True)
            continue
        has_material = any(m is not None for m in obj.data.materials)
        has_weights = len(obj.vertex_groups) > 0
        has_armature_mod = any(
            md.type == "ARMATURE" and md.object is not None for md in obj.modifiers
        )
        likely_gizmo = (
            (not has_material)
            and (not has_weights)
            and (not has_armature_mod)
            and len(obj.data.vertices) <= 128
        )
        if has_helper_name or likely_gizmo:
            bpy.data.objects.remove(obj, do_unlink=True)
    for mesh in list(bpy.data.meshes):
        if is_helper_mesh_name(mesh.name) and mesh.users == 0:
            bpy.data.meshes.remove(mesh)

    use_selection = bool(selected_objects)
    if use_selection:
        keep_names = set()
        for obj in selected_objects:
            if obj is None:
                continue
            try:
                name = obj.name
            except ReferenceError:
                continue
            if name in bpy.data.objects:
                keep_names.add(name)

        for obj in list(bpy.data.objects):
            if obj.name not in keep_names:
                bpy.data.objects.remove(obj, do_unlink=True)

        bpy.ops.object.select_all(action="DESELECT")
        first_active = None
        for name in keep_names:
            obj = bpy.data.objects.get(name)
            if obj is not None:
                obj.select_set(True)
                if first_active is None:
                    first_active = obj
        if first_active is not None:
            bpy.context.view_layer.objects.active = first_active

    bpy.ops.export_scene.gltf(
        filepath=out_path,
        export_format="GLB",
        use_selection=use_selection,
        export_apply=False,
        export_materials="EXPORT",
        export_animations=True,
        export_animation_mode="ACTIONS",
        export_nla_strips=False,
        export_anim_single_armature=True,
    )


def build_from_base_fbx(base_fbx, anim_files, out_glb, clip_prefix):
    imported_objs, _ = import_fbx(base_fbx)
    base_armature = find_main_armature(imported_objs)
    if base_armature is None:
        base_armature = find_scene_armature()
    if base_armature is None:
        raise RuntimeError("No armature found in base FBX.")

    clips = merge_actions(base_armature, anim_files, clip_prefix)
    keep_only_actions(clips)
    meshes = [o for o in bpy.data.objects if o.type == "MESH" and o.parent == base_armature]
    normalize_armature_scale_rotation(base_armature, meshes)
    normalize_character_origin_to_feet(base_armature, meshes)
    export_glb(out_glb)
    print(f"[done] clips={len(clips)} -> {out_glb}")


def build_from_base_glb(
    base_glb,
    anim_files,
    out_glb,
    clip_prefix,
    bind_fbx="",
    disable_weapon_split=False,
):
    base_objs = import_glb(base_glb)
    for o in base_objs:
        if o.type == "MESH" and is_helper_mesh_name(o.name) and o.name in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[o.name], do_unlink=True)
    base_meshes = [o for o in base_objs if o.type == "MESH" and not is_helper_mesh_name(o.name)]
    if not base_meshes:
        raise RuntimeError("No mesh found in --base-glb model.")
    base_mesh = join_mesh_objects(base_meshes, "MixamoBoundMesh")
    if base_mesh is None:
        raise RuntimeError("Failed to prepare mesh from --base-glb.")

    base_armature = None
    preloaded_action = None
    preloaded_path = ""

    if bind_fbx and os.path.isfile(bind_fbx):
        bind_objs, bind_new_actions = import_fbx(bind_fbx)
        base_armature = find_main_armature(bind_objs)
        if base_armature is None:
            base_armature = find_scene_armature()
        if base_armature is None:
            raise RuntimeError("No armature found in --bind-fbx.")

        ref_meshes = [o for o in bind_objs if o.type == "MESH" and not is_helper_mesh_name(o.name)]
        ref_mesh = join_mesh_objects(ref_meshes, "MixamoRefMesh")
        if ref_mesh is not None:
            align_mesh_to_armature(ref_mesh, base_armature)
            align_mesh_to_armature(base_mesh, base_armature)
            align_mesh_pelvis_to_reference(base_mesh, ref_mesh, base_armature)
            transfer_weights_by_nearest_vertex(ref_mesh, base_mesh)
            ensure_armature_modifier(base_mesh, base_armature)
            apply_character_extra_transform(base_mesh)
            # Keep only rig + target mesh for export.
            if ref_mesh.name in bpy.data.objects:
                bpy.data.objects.remove(bpy.data.objects[ref_mesh.name], do_unlink=True)
        else:
            align_mesh_to_armature(base_mesh, base_armature)
            bind_mesh_to_armature(base_mesh, base_armature)
            apply_character_extra_transform(base_mesh)

        # Do not include bind pose/action from rig reference file as an exported clip.
        preloaded_action = None
        preloaded_path = ""
    else:
        # Fallback: use first animation file as skeleton source.
        first_path = anim_files[0]
        imported_objs, new_actions = import_fbx(first_path)
        base_armature = find_main_armature(imported_objs)
        if base_armature is None:
            base_armature = find_scene_armature()
        if base_armature is None:
            raise RuntimeError("No armature found in first animation FBX.")
        preloaded_action = pick_imported_action(base_armature, new_actions)
        preloaded_path = first_path
        align_mesh_to_armature(base_mesh, base_armature)
        bind_mesh_to_armature(base_mesh, base_armature)
        apply_character_extra_transform(base_mesh)

    if disable_weapon_split:
        ensure_armature_modifier(base_mesh, base_armature)
        export_meshes = [base_mesh]
    else:
        export_meshes = split_and_rigid_bind_weapons(base_mesh, base_armature)
    export_meshes.extend(add_armor_shell_pieces(base_armature))
    stylize_body_material_textures(export_meshes)

    clips = merge_actions(
        base_armature,
        anim_files,
        clip_prefix,
        preloaded=preloaded_action,
        preloaded_path=preloaded_path,
    )
    keep_only_actions(clips)
    normalize_armature_scale_rotation(base_armature, export_meshes)
    normalize_character_origin_to_feet(base_armature, export_meshes)
    export_glb(out_glb, selected_objects=[base_armature] + export_meshes)
    print(f"[done] clips={len(clips)} (bound from GLB) -> {out_glb}")


def main():
    args = parse_args()
    base_fbx = os.path.abspath(args.base_fbx) if args.base_fbx else ""
    base_glb = os.path.abspath(args.base_glb) if args.base_glb else ""
    bind_fbx = os.path.abspath(args.bind_fbx) if args.bind_fbx else ""
    anim_dir = os.path.abspath(args.anim_dir)
    out_glb = os.path.abspath(args.out_glb)

    if base_fbx and not os.path.isfile(base_fbx):
        raise FileNotFoundError(base_fbx)
    if base_glb and not os.path.isfile(base_glb):
        raise FileNotFoundError(base_glb)
    if bind_fbx and not os.path.isfile(bind_fbx):
        raise FileNotFoundError(bind_fbx)
    if not os.path.isdir(anim_dir):
        raise NotADirectoryError(anim_dir)

    anim_files = list_anim_files(anim_dir)
    if not anim_files:
        raise RuntimeError(f"No FBX animation files found in: {anim_dir}")

    clear_scene()
    if base_fbx:
        build_from_base_fbx(base_fbx, anim_files, out_glb, args.name_prefix)
    else:
        build_from_base_glb(
            base_glb,
            anim_files,
            out_glb,
            args.name_prefix,
            bind_fbx=bind_fbx,
            disable_weapon_split=args.disable_weapon_split,
        )


if __name__ == "__main__":
    main()
