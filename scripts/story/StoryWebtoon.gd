extends Control

var _chapter: Dictionary = {}


func _ready() -> void:
	TechnoirTheme.apply_root(self)
	_chapter = ContentDB.get_chapter(GameState.current_chapter_id)
	if _chapter.is_empty():
		GameState.go_chapters()
		return
	var night := str(_chapter.get("environment", "")) == "night_desk"
	%Bg.color = TechnoirTheme.NIGHT_DEEP if night else TechnoirTheme.CREAM
	%Title.text = ContentDB.tr_key(str(_chapter.get("title_key", "")))
	%Subtitle.text = ContentDB.tr_key(str(_chapter.get("subtitle_key", "")))
	TechnoirTheme.style_label_title(%Title, night)
	TechnoirTheme.style_label_body(%Subtitle, night)
	%ContinueBtn.text = ContentDB.tr_key("story_continue")
	TechnoirTheme.style_button(%ContinueBtn, true)
	%BackBtn.text = ContentDB.tr_key("menu_back")
	TechnoirTheme.style_button(%BackBtn, false)
	if night:
		%BackBtn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	%ContinueBtn.pressed.connect(_continue)
	%BackBtn.pressed.connect(func(): AudioBus.play_sfx("ui_tap"); GameState.go_chapters())
	_build_panels(night)


func _build_panels(night: bool) -> void:
	for child in %PanelList.get_children():
		child.queue_free()
	var panels: Array = _chapter.get("story_panels", [])
	for p in panels:
		var card := PanelContainer.new()
		var style := TechnoirTheme.make_panel_style(
			Color(0.12, 0.16, 0.28, 0.95) if night else TechnoirTheme.CREAM_DEEP,
			16.0
		)
		card.add_theme_stylebox_override("panel", style)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_right", 14)
		margin.add_theme_constant_override("margin_top", 14)
		margin.add_theme_constant_override("margin_bottom", 14)
		card.add_child(margin)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 10)
		margin.add_child(vb)

		var img_path := str(p.get("image", ""))
		if ResourceLoader.exists(img_path):
			var tr := TextureRect.new()
			tr.custom_minimum_size = Vector2(0, 180)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			tr.texture = load(img_path)
			vb.add_child(tr)
		else:
			var placeholder := ColorRect.new()
			placeholder.custom_minimum_size = Vector2(0, 160)
			placeholder.color = TechnoirTheme.NIGHT if night else TechnoirTheme.ACCENT_ORANGE
			vb.add_child(placeholder)

		var body := Label.new()
		body.text = ContentDB.tr_key(str(p.get("text_key", "")))
		TechnoirTheme.style_label_body(body, night)
		body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		vb.add_child(body)
		%PanelList.add_child(card)


func _continue() -> void:
	AudioBus.play_sfx("ui_tap")
	GameState.go_workbench(GameState.current_chapter_id)
