extends Node
## Global flow: current chapter, tool mode, repair session flags.

signal chapter_changed(chapter_id: String)
signal tool_changed(tool_id: String)
signal repair_completed(object_id: String)

const TOOL_HAND := "hand"
const TOOL_SCREWDRIVER := "screwdriver"

var current_chapter_id: String = ""
var current_object_id: String = ""
var current_environment: String = "night_desk"
var active_tool: String = TOOL_HAND
var blueprint_visible: bool = false
var dialogue_queue: Array = []


func select_chapter(chapter_id: String) -> void:
	current_chapter_id = chapter_id
	var chapter: Dictionary = ContentDB.get_chapter(chapter_id)
	if not chapter.is_empty():
		current_object_id = str(chapter.get("object_id", ""))
		current_environment = str(chapter.get("environment", "night_desk"))
	chapter_changed.emit(chapter_id)


func set_tool(tool_id: String) -> void:
	active_tool = tool_id
	tool_changed.emit(tool_id)


func toggle_blueprint() -> void:
	blueprint_visible = not blueprint_visible


func notify_repair_completed(object_id: String) -> void:
	Save.mark_chapter_completed(current_chapter_id)
	Save.unlock_next_after(current_chapter_id)
	repair_completed.emit(object_id)


func go_boot() -> void:
	get_tree().change_scene_to_file("res://scenes/boot/Boot.tscn")


func go_main() -> void:
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")


func go_chapters() -> void:
	get_tree().change_scene_to_file("res://scenes/chapters/ChapterSelect.tscn")


func go_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/settings/Settings.tscn")


func go_story(chapter_id: String = "") -> void:
	if chapter_id != "":
		select_chapter(chapter_id)
	get_tree().change_scene_to_file("res://scenes/story/StoryWebtoon.tscn")


func go_workbench(chapter_id: String = "") -> void:
	if chapter_id != "":
		select_chapter(chapter_id)
	get_tree().change_scene_to_file("res://scenes/workbench/Workbench.tscn")
