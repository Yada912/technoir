extends Control


func _ready() -> void:
	TechnoirTheme.apply_root(self)
	%Title.text = ContentDB.tr_key("app_title")
	%Subtitle.text = ContentDB.tr_key("app_subtitle")
	%PlayBtn.text = ContentDB.tr_key("menu_play")
	%ChaptersBtn.text = ContentDB.tr_key("menu_chapters")
	%SettingsBtn.text = ContentDB.tr_key("menu_settings")
	TechnoirTheme.style_button(%PlayBtn, true)
	TechnoirTheme.style_button(%ChaptersBtn, false)
	TechnoirTheme.style_button(%SettingsBtn, false)
	%PlayBtn.pressed.connect(_on_play)
	%ChaptersBtn.pressed.connect(func(): AudioBus.play_sfx("ui_tap"); GameState.go_chapters())
	%SettingsBtn.pressed.connect(func(): AudioBus.play_sfx("ui_tap"); GameState.go_settings())


func _on_play() -> void:
	AudioBus.play_sfx("ui_tap")
	# Resume first incomplete unlocked chapter
	for ch in ContentDB.get_chapters_ordered():
		var id := str(ch.get("id", ""))
		if Save.is_unlocked(id) and not Save.is_completed(id):
			GameState.go_story(id)
			return
	GameState.go_story("ch01_prologue")
