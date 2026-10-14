extends Node
## Loads chapter/object/locale JSON from res://content.

var chapters: Dictionary = {} ## id -> Dictionary
var objects: Dictionary = {} ## id -> Dictionary
var strings: Dictionary = {} ## key -> text
var chapter_order: Array = []


func _ready() -> void:
	_load_locale("id")
	_load_dir("res://content/chapters", chapters, true)
	_load_dir("res://content/objects", objects, false)


func _load_locale(code: String) -> void:
	var path := "res://content/locale/%s.json" % code
	if not FileAccess.file_exists(path):
		push_warning("ContentDB: missing locale %s" % path)
		return
	var data: Variant = _read_json(path)
	if typeof(data) == TYPE_DICTIONARY:
		strings = data


func _load_dir(dir_path: String, into: Dictionary, track_order: bool) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("ContentDB: cannot open %s" % dir_path)
		return
	dir.list_dir_begin()
	var name := dir.get_next()
	var files: Array = []
	while name != "":
		if not dir.current_is_dir() and name.ends_with(".json"):
			files.append(name)
		name = dir.get_next()
	dir.list_dir_end()
	files.sort()
	for file_name in files:
		var path := "%s/%s" % [dir_path, file_name]
		var data: Variant = _read_json(path)
		if typeof(data) != TYPE_DICTIONARY:
			continue
		var id := str(data.get("id", file_name.get_basename()))
		data["id"] = id
		into[id] = data
		if track_order:
			chapter_order.append(id)


func _read_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())


func tr_key(key: String, fallback: String = "") -> String:
	if strings.has(key):
		return str(strings[key])
	if fallback != "":
		return fallback
	return key


func get_chapter(id: String) -> Dictionary:
	return chapters.get(id, {})


func get_object(id: String) -> Dictionary:
	return objects.get(id, {})


func get_chapters_ordered() -> Array:
	var out: Array = []
	for id in chapter_order:
		if chapters.has(id):
			out.append(chapters[id])
	return out
