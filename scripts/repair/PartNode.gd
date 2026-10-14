class_name PartNode
extends Area3D
## Interactive detachable part with snap home pose.

signal part_clicked(part: PartNode)
signal part_drag_ended(part: PartNode)

var part_id: String = ""
var tool_needed: String = "hand"
var requires: Array = []
var detach_sfx: String = "part_snap_out"
var assemble_sfx: String = "part_snap_in"
var detachable: bool = true
var attached: bool = true
var home_position: Vector3 = Vector3.ZERO
var home_rotation: Vector3 = Vector3.ZERO
var _dragging: bool = false
var _drag_depth: float = 1.2


func configure(def: Dictionary) -> void:
	part_id = str(def.get("id", ""))
	tool_needed = str(def.get("tool", "hand"))
	requires = def.get("requires", [])
	detach_sfx = str(def.get("detach_sfx", "part_snap_out"))
	assemble_sfx = str(def.get("assemble_sfx", "part_snap_in"))
	detachable = bool(def.get("detachable", true))
	var off: Variant = def.get("offset", [0, 0, 0])
	if off is Array and off.size() >= 3:
		position = Vector3(float(off[0]), float(off[1]), float(off[2]))
	home_position = position
	home_rotation = rotation_degrees
	monitoring = true
	monitorable = true
	input_ray_pickable = true
	collision_layer = 1
	collision_mask = 0
	# Collision from mesh bounds
	var mesh_child := _find_mesh()
	if mesh_child and mesh_child.mesh:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		var aabb := mesh_child.mesh.get_aabb()
		box.size = aabb.size * 1.15
		shape.shape = box
		shape.position = aabb.position + aabb.size * 0.5
		add_child(shape)


func _find_mesh() -> MeshInstance3D:
	for c in get_children():
		if c is MeshInstance3D:
			return c
	return null


func can_detach(attached_ids: Dictionary) -> bool:
	if not detachable or not attached:
		return false
	for r in requires:
		# required parts must already be detached
		if attached_ids.get(str(r), true):
			return false
	return true


func can_attach(attached_ids: Dictionary) -> bool:
	if attached:
		return false
	for r in requires:
		# parents/guards must be attached again? For simplicity: screws first freely; door needs screws attached? 
		# Demo rule: can attach if required parts are currently detached OR if requirements were for removal only.
		# Soft rule: allow attach anytime when detached.
		pass
	return true


func detach_to(world_pos: Vector3) -> void:
	attached = false
	global_position = world_pos
	AudioBus.play_sfx(detach_sfx)


func attach_home() -> void:
	attached = true
	position = home_position
	rotation_degrees = home_rotation
	AudioBus.play_sfx(assemble_sfx)


func _input_event(_camera: Camera3D, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		part_clicked.emit(self)
	elif event is InputEventScreenTouch and event.pressed:
		part_clicked.emit(self)
