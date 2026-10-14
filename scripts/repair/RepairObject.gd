extends Node3D
class_name RepairObject
## Builds a repairable object from content JSON and handles part graph.

signal object_repaired(object_id: String)
signal status_message(text: String)

var object_id: String = ""
var def: Dictionary = {}
var parts: Dictionary = {} ## id -> PartNode
var running: bool = false
var _spin_part: Node3D
var _spin_speed: float = 0.0
var _tray_index: int = 0


func build_from_id(id: String) -> void:
	object_id = id
	def = ContentDB.get_object(id)
	for c in get_children():
		c.queue_free()
	parts.clear()
	running = false
	_spin_part = null
	_tray_index = 0
	if def.is_empty():
		status_message.emit("Object missing: %s" % id)
		return
	for part_def in def.get("parts", []):
		var pn := PartNode.new()
		pn.name = str(part_def.get("id", "part"))
		var mesh_id := str(part_def.get("mesh", "screw"))
		var mesh := MeshFactory.make_part(mesh_id)
		pn.add_child(mesh)
		pn.configure(part_def)
		pn.part_clicked.connect(_on_part_clicked)
		add_child(pn)
		parts[pn.part_id] = pn
	# Visual root offset
	position = Vector3(0, 0.05, 0)


func _process(delta: float) -> void:
	if running and _spin_part:
		_spin_part.rotate_z(_spin_speed * delta)


func attached_map() -> Dictionary:
	var m := {}
	for id in parts:
		m[id] = parts[id].attached
	return m


func all_win_parts_attached() -> bool:
	var need: Array = def.get("win_requires_attached", [])
	for id in need:
		var p: PartNode = parts.get(str(id))
		if p == null or not p.attached:
			return false
	return true


func try_interact(part: PartNode) -> void:
	if running:
		return
	var tool := GameState.active_tool
	var am := attached_map()
	if part.attached:
		if part.tool_needed != tool:
			status_message.emit(ContentDB.tr_key("repair_hint_" + part.tool_needed, "Wrong tool"))
			return
		if not part.can_detach(am):
			status_message.emit("Belum bisa — buka sekrupnya dulu.")
			return
		_detach_part(part)
	else:
		# Reattach if close enough handled by workbench; here force snap
		_attach_part(part)


func _detach_part(part: PartNode) -> void:
	var tray := Vector3(-0.55 + _tray_index * 0.18, -0.05, 0.35)
	_tray_index = mini(_tray_index + 1, 6)
	part.detach_to(to_global(tray))
	# Keep as child but moved
	part.reparent(self)
	part.position = tray
	part.attached = false
	status_message.emit("Lepas: %s" % part.part_id)


func _attach_part(part: PartNode) -> void:
	part.reparent(self)
	part.attach_home()
	status_message.emit("Terpasang: %s" % part.part_id)


func try_run() -> bool:
	if not all_win_parts_attached():
		status_message.emit("Rakit dulu semua bagiannya.")
		return false
	var fn: Dictionary = def.get("function", {})
	var ftype := str(fn.get("type", ""))
	running = true
	match ftype:
		"spin":
			var pid := str(fn.get("part_id", "blades"))
			_spin_part = parts.get(pid)
			_spin_speed = float(fn.get("speed", 6.0))
			AudioBus.play_sfx("success_chime")
		"audio_loop":
			AudioBus.play_sfx(str(fn.get("sfx", "cassette_loop")))
			AudioBus.play_sfx("success_chime")
		_:
			AudioBus.play_sfx("success_chime")
	status_message.emit(ContentDB.tr_key("repair_success"))
	object_repaired.emit(object_id)
	GameState.notify_repair_completed(object_id)
	return true


func _on_part_clicked(part: PartNode) -> void:
	try_interact(part)
