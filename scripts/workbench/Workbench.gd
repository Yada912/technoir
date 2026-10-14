extends Control
## 3D repair table + HUD tools, dialogue, blueprint.

var _orbit_yaw: float = 0.35
var _orbit_pitch: float = -0.35
var _orbit_dist: float = 1.55
var _dragging_orbit: bool = false
var _last_pos: Vector2 = Vector2.ZERO
var _chapter: Dictionary = {}
var _repaired: bool = false

@onready var _world: Node3D = %World
@onready var _pivot: Node3D = %Pivot
@onready var _camera: Camera3D = %Camera3D
@onready var _repair_root: Node3D = %RepairRoot
@onready var _env_root: Node3D = %EnvRoot
@onready var _hint: Label = %HintLabel
@onready var _dialogue: PanelContainer = %DialogueBubble
@onready var _dialogue_text: Label = %DialogueText
@onready var _blueprint: ColorRect = %BlueprintOverlay


func _ready() -> void:
	TechnoirTheme.apply_root(self)
	_chapter = ContentDB.get_chapter(GameState.current_chapter_id)
	if _chapter.is_empty():
		GameState.go_chapters()
		return
	%TitleLabel.text = ContentDB.tr_key(str(_chapter.get("title_key", "")))
	%BackBtn.text = ContentDB.tr_key("menu_back")
	%RunBtn.text = ContentDB.tr_key("run_object")
	%BlueprintBtn.text = ContentDB.tr_key("blueprint")
	%HandBtn.text = ContentDB.tr_key("tool_hand")
	%ScrewBtn.text = ContentDB.tr_key("tool_screwdriver")
	TechnoirTheme.style_button(%BackBtn, false)
	TechnoirTheme.style_button(%RunBtn, true)
	TechnoirTheme.style_button(%HandBtn, true)
	TechnoirTheme.style_button(%ScrewBtn, false)
	TechnoirTheme.style_button(%BlueprintBtn, false)
	%BackBtn.pressed.connect(func(): AudioBus.play_sfx("ui_tap"); GameState.go_chapters())
	%HandBtn.pressed.connect(func(): _set_tool(GameState.TOOL_HAND))
	%ScrewBtn.pressed.connect(func(): _set_tool(GameState.TOOL_SCREWDRIVER))
	%RunBtn.pressed.connect(_on_run)
	%BlueprintBtn.pressed.connect(_toggle_blueprint)
	_blueprint.visible = false
	%BlueprintBtn.visible = bool(_chapter.get("show_blueprint", false))
	_setup_environment()
	_setup_object()
	_setup_dialogue()
	_set_tool(GameState.TOOL_SCREWDRIVER)
	_update_camera()
	_hint.text = ContentDB.tr_key("repair_hint_screwdriver")
	var vpc: SubViewportContainer = $ViewportContainer
	vpc.gui_input.connect(_on_viewport_gui_input)
	# Let empty areas orbit; HUD buttons sit above with mouse_filter stop
	vpc.mouse_filter = Control.MOUSE_FILTER_STOP


func _setup_environment() -> void:
	for c in _env_root.get_children():
		c.queue_free()
	var night := GameState.current_environment == "night_desk"
	%WorldEnv.environment = _make_env(night)
	_env_root.add_child(MeshFactory.make_desk(night))
	var sun := DirectionalLight3D.new()
	sun.light_energy = 0.35 if night else 0.85
	sun.light_color = Color("8AA0C8") if night else Color("FFF2D8")
	sun.rotation_degrees = Vector3(-50, 30, 0)
	_env_root.add_child(sun)
	if not night:
		# Soft bright backdrop plane (Figma-like stage)
		var backdrop := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2(4, 3)
		backdrop.mesh = plane
		backdrop.position = Vector3(0, 0.6, -1.2)
		backdrop.rotation_degrees = Vector3(90, 0, 0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("F2E6D8")
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		backdrop.material_override = mat
		_env_root.add_child(backdrop)


func _make_env(night: bool) -> Environment:
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("0E1628") if night else Color("E8D8C4")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("1A2744") if night else Color("FFF8F0")
	e.ambient_light_energy = 0.55 if night else 0.8
	return e


func _setup_object() -> void:
	for c in _repair_root.get_children():
		c.queue_free()
	var obj := RepairObject.new()
	obj.name = "RepairObject"
	_repair_root.add_child(obj)
	obj.build_from_id(GameState.current_object_id)
	obj.status_message.connect(func(t): _hint.text = t)
	obj.object_repaired.connect(_on_repaired)


func _setup_dialogue() -> void:
	var lines: Array = _chapter.get("dialogue", [])
	if lines.is_empty():
		_dialogue.visible = false
		return
	var bubble := TechnoirTheme.make_panel_style(Color(1, 1, 1, 0.92), 14.0)
	bubble.content_margin_left = 12
	bubble.content_margin_right = 12
	bubble.content_margin_top = 10
	bubble.content_margin_bottom = 10
	_dialogue.add_theme_stylebox_override("panel", bubble)
	_dialogue_text.add_theme_color_override("font_color", TechnoirTheme.INK)
	_dialogue.visible = true
	var line: Dictionary = lines[0]
	var speaker := str(line.get("speaker", ""))
	var text := ContentDB.tr_key(str(line.get("text_key", "")))
	_dialogue_text.text = "%s: %s" % [speaker, text]
	get_tree().create_timer(6.0).timeout.connect(func(): _dialogue.visible = false)


func _set_tool(tool_id: String) -> void:
	AudioBus.play_sfx("ui_tap")
	GameState.set_tool(tool_id)
	TechnoirTheme.style_button(%HandBtn, tool_id == GameState.TOOL_HAND)
	TechnoirTheme.style_button(%ScrewBtn, tool_id == GameState.TOOL_SCREWDRIVER)
	if tool_id == GameState.TOOL_HAND:
		TechnoirTheme.style_button(%ScrewBtn, false)
		_hint.text = ContentDB.tr_key("repair_hint_hand")
	else:
		TechnoirTheme.style_button(%HandBtn, false)
		TechnoirTheme.style_button(%ScrewBtn, true)
		_hint.text = ContentDB.tr_key("repair_hint_screwdriver")


func _toggle_blueprint() -> void:
	AudioBus.play_sfx("ui_tap")
	GameState.toggle_blueprint()
	_blueprint.visible = GameState.blueprint_visible


func _on_run() -> void:
	var obj := _repair_root.get_node_or_null("RepairObject") as RepairObject
	if obj:
		obj.try_run()


func _on_repaired(_id: String) -> void:
	_repaired = true
	%RunBtn.text = ContentDB.tr_key("repair_success")


func _gui_input(event: InputEvent) -> void:
	# Orbit only when interacting with the 3D viewport area (SubViewportContainer)
	pass


func _on_viewport_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging_orbit = event.pressed
			_last_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_orbit_dist = maxf(0.9, _orbit_dist - 0.1)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_orbit_dist = minf(2.8, _orbit_dist + 0.1)
			_update_camera()
	elif event is InputEventMouseMotion and _dragging_orbit:
		var d: Vector2 = event.position - _last_pos
		_last_pos = event.position
		_orbit_yaw -= d.x * 0.01
		_orbit_pitch = clampf(_orbit_pitch - d.y * 0.01, -1.2, 0.2)
		_update_camera()
	elif event is InputEventScreenTouch:
		_dragging_orbit = event.pressed
		_last_pos = event.position
	elif event is InputEventScreenDrag:
		var d2: Vector2 = event.position - _last_pos
		_last_pos = event.position
		_orbit_yaw -= d2.x * 0.01
		_orbit_pitch = clampf(_orbit_pitch - d2.y * 0.01, -1.2, 0.2)
		_update_camera()


func _update_camera() -> void:
	var cp := Vector3(
		sin(_orbit_yaw) * cos(_orbit_pitch),
		sin(_orbit_pitch) * -1.0 + 0.25,
		cos(_orbit_yaw) * cos(_orbit_pitch)
	) * _orbit_dist
	_camera.position = cp
	_camera.look_at(Vector3(0, 0.1, 0), Vector3.UP)
