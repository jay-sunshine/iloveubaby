extends SceneTree

var targets: Array[String] = [
	"res://素材/建模/建筑单位/luoyang.glb",
	"res://素材/建模/建筑单位/chengchi.glb",
	"res://素材/建模/建筑单位/guanai.glb",
	"res://素材/建模/建筑单位/wubao.glb",
	"res://素材/建模/建筑单位/jindu.glb",
	"res://素材/建模/军事设施/chengsai.glb",
	"res://素材/建模/军事设施/chengzhai.glb"
]

func _init() -> void:
	for path in targets:
		_measure(path)
	quit(0)

func _measure(path: String) -> void:
	var packed: PackedScene = load(path)
	if packed == null:
		print(path, " -> load failed")
		return
	var root: Node = packed.instantiate()
	if root == null:
		print(path, " -> instantiate failed")
		return

	var result: Array = _walk(root, Transform3D.IDENTITY, false, AABB())
	var has_aabb: bool = result[0]
	var merged: AABB = result[1]
	if has_aabb:
		var s: Vector3 = merged.size
		print(path, " | size(x,z,y)=", snappedf(s.x, 0.01), ",", snappedf(s.z, 0.01), ",", snappedf(s.y, 0.01))
	else:
		print(path, " -> no mesh")
	root.free()

func _walk(node: Node, parent: Transform3D, has_aabb: bool, merged: AABB) -> Array:
	var local_t: Transform3D = parent
	if node is Node3D:
		local_t = parent * (node as Node3D).transform

	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		if mi.mesh != null:
			var aabb: AABB = mi.mesh.get_aabb()
			var corners: Array[Vector3] = [
				aabb.position,
				aabb.position + Vector3(aabb.size.x, 0, 0),
				aabb.position + Vector3(0, aabb.size.y, 0),
				aabb.position + Vector3(0, 0, aabb.size.z),
				aabb.position + Vector3(aabb.size.x, aabb.size.y, 0),
				aabb.position + Vector3(aabb.size.x, 0, aabb.size.z),
				aabb.position + Vector3(0, aabb.size.y, aabb.size.z),
				aabb.position + aabb.size
			]
			for c in corners:
				var wc: Vector3 = local_t * c
				if not has_aabb:
					merged = AABB(wc, Vector3.ZERO)
					has_aabb = true
				else:
					merged = merged.expand(wc)

	for child_any in node.get_children():
		var child: Node = child_any
		var result: Array = _walk(child, local_t, has_aabb, merged)
		has_aabb = result[0]
		merged = result[1]
	return [has_aabb, merged]
