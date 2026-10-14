extends Node
## Local save: unlocks, volumes, completed chapters.

const SAVE_PATH := "user://technoir_save.json"

var unlocked_chapters: Array = ["ch01_prologue"]
var completed_chapters: Array = []
var bgm_volume: float = 0.7
var sfx_volume: float = 0.85
var locale: String = "id"


func _ready() -> void:
	load_save()


func is_unlocked(chapter_id: String) -> bool:
	return chapter_id in unlocked_chapters


func is_completed(chapter_id: String) -> bool:
	return chapter_id in completed_chapters


func mark_chapter_completed(chapter_id: String) -> void:
	if chapter_id == "":
		return
	if chapter_id not in completed_chapters:
		completed_chapters.append(chapter_id)
	persist()


func unlock_chapter(chapter_id: String) -> void:
	if chapter_id == "":
		return
	if chapter_id not in unlocked_chapters:
		unlocked_chapters.append(chapter_id)
	persist()


func unlock_next_after(chapter_id: String) -> void:
	var chapter: Dictionary = ContentDB.get_chapter(chapter_id)
	var unlocks: Variant = chapter.get("unlocks", null)
	if unlocks is String:
		unlock_chapter(str(unlocks))
	elif unlocks is Array:
		for id in unlocks:
			unlock_chapter(str(id))


func set_volumes(bgm: float, sfx: float) -> void:
	bgm_volume = clampf(bgm, 0.0, 1.0)
	sfx_volume = clampf(sfx, 0.0, 1.0)
	AudioBus.apply_volumes()
	persist()


func persist() -> void:
	var data := {
		"unlocked_chapters": unlocked_chapters,
		"completed_chapters": completed_chapters,
		"bgm_volume": bgm_volume,
		"sfx_volume": sfx_volume,
		"locale": locale,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Save: could not write %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data, "\t"))


func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	unlocked_chapters = data.get("unlocked_chapters", unlocked_chapters)
	completed_chapters = data.get("completed_chapters", completed_chapters)
	bgm_volume = float(data.get("bgm_volume", bgm_volume))
	sfx_volume = float(data.get("sfx_volume", sfx_volume))
	locale = str(data.get("locale", locale))
