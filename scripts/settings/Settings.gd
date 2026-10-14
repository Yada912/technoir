extends Control


func _ready() -> void:
	TechnoirTheme.apply_root(self)
	%Title.text = ContentDB.tr_key("menu_settings")
	%BgmLabel.text = ContentDB.tr_key("settings_bgm")
	%SfxLabel.text = ContentDB.tr_key("settings_sfx")
	%CreditsTitle.text = ContentDB.tr_key("settings_credits")
	%CreditsBody.text = ContentDB.tr_key("settings_credits_body")
	%BackBtn.text = ContentDB.tr_key("menu_back")
	TechnoirTheme.style_button(%BackBtn, false)
	%BgmSlider.min_value = 0.0
	%BgmSlider.max_value = 1.0
	%BgmSlider.step = 0.01
	%BgmSlider.value = Save.bgm_volume
	%SfxSlider.min_value = 0.0
	%SfxSlider.max_value = 1.0
	%SfxSlider.step = 0.01
	%SfxSlider.value = Save.sfx_volume
	%BgmSlider.value_changed.connect(_on_bgm)
	%SfxSlider.value_changed.connect(_on_sfx)
	%BackBtn.pressed.connect(func(): AudioBus.play_sfx("ui_tap"); GameState.go_main())


func _on_bgm(v: float) -> void:
	Save.set_volumes(v, Save.sfx_volume)


func _on_sfx(v: float) -> void:
	Save.set_volumes(Save.bgm_volume, v)
	AudioBus.play_sfx("ui_tap")
