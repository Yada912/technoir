extends Control

var _index: int = 0
var _chapters: Array = []


func _ready() -> void:
	TechnoirTheme.apply_root(self)
	_chapters = ContentDB.get_chapters_ordered()
	%BackBtn.text = ContentDB.tr_key("menu_back")
	TechnoirTheme.style_button(%BackBtn, false)
	TechnoirTheme.style_button(%PlayBtn, true)
	%BackBtn.pressed.connect(func(): AudioBus.play_sfx("ui_tap"); GameState.go_main())
	%PrevBtn.pressed.connect(_prev)
	%NextBtn.pressed.connect(_next)
	%PlayBtn.pressed.connect(_play)
	# Jump to current if set
	if GameState.current_chapter_id != "":
		for i in _chapters.size():
			if str(_chapters[i].get("id")) == GameState.current_chapter_id:
				_index = i
				break
	_refresh()


func _prev() -> void:
	AudioBus.play_sfx("ui_tap")
	_index = (_index - 1 + _chapters.size()) % _chapters.size()
	_refresh()


func _next() -> void:
	AudioBus.play_sfx("ui_tap")
	_index = (_index + 1) % _chapters.size()
	_refresh()


func _play() -> void:
	if _chapters.is_empty():
		return
	var ch: Dictionary = _chapters[_index]
	var id := str(ch.get("id"))
	if not Save.is_unlocked(id):
		AudioBus.play_sfx("part_snap_out")
		return
	AudioBus.play_sfx("ui_tap")
	GameState.go_story(id)


func _refresh() -> void:
	if _chapters.is_empty():
		return
	var ch: Dictionary = _chapters[_index]
	var id := str(ch.get("id"))
	var unlocked := Save.is_unlocked(id)
	%Title.text = ContentDB.tr_key(str(ch.get("title_key", id)))
	%Subtitle.text = ContentDB.tr_key(str(ch.get("subtitle_key", "")))
	var hero := str(ch.get("hero", "cassette"))
	%Hero.texture = _hero_texture(hero)
	%PlayBtn.disabled = not unlocked
	if unlocked:
		%PlayBtn.text = "%s  ·  %s" % [ContentDB.tr_key("chapter_play"), ContentDB.tr_key(str(ch.get("title_key", id)))]
	else:
		%PlayBtn.text = ContentDB.tr_key("chapter_locked")
	_paint_dots()
	# Soft bg tint per chapter
	if str(ch.get("environment")) == "night_desk":
		%Accent.color = Color("E8A87C")
	else:
		%Accent.color = Color("F0C9A0")


func _paint_dots() -> void:
	for c in %Dots.get_children():
		c.queue_free()
	for i in _chapters.size():
		var d := ColorRect.new()
		d.custom_minimum_size = Vector2(10 if i == _index else 8, 8)
		d.color = TechnoirTheme.INK if i == _index else Color(0.7, 0.65, 0.58)
		%Dots.add_child(d)


func _hero_texture(hero: String) -> Texture2D:
	var path := "res://assets/ui/hero_cassette.svg"
	if hero == "fan":
		path = "res://assets/ui/hero_fan.svg"
	if ResourceLoader.exists(path):
		return load(path)
	return null
