extends Control


@onready var _bar: ProgressBar = %ProgressBar
@onready var _label: Label = %StatusLabel
@onready var _title: Label = %TitleLabel


func _ready() -> void:
	TechnoirTheme.apply_root(self)
	_title.text = ContentDB.tr_key("app_title", "Memoirs of Technoir")
	_label.text = ContentDB.tr_key("loading", "Loading…")
	_bar.value = 0
	_run_load()


func _run_load() -> void:
	var steps := [
		"res://scenes/main/Main.tscn",
		"res://scenes/chapters/ChapterSelect.tscn",
		"res://scenes/settings/Settings.tscn",
		"res://scenes/story/StoryWebtoon.tscn",
		"res://scenes/workbench/Workbench.tscn",
	]
	for i in steps.size():
		ResourceLoader.load_threaded_request(steps[i])
		var t0 := Time.get_ticks_msec()
		while ResourceLoader.load_threaded_get_status(steps[i]) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
			if Time.get_ticks_msec() - t0 > 8000:
				break
		ResourceLoader.load_threaded_get(steps[i])
		_bar.value = float(i + 1) / float(steps.size()) * 100.0
		await get_tree().create_timer(0.12).timeout
	AudioBus.play_sfx("ui_tap")
	GameState.go_main()
