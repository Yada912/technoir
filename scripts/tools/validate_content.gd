extends SceneTree
## Headless content sanity check: godot --headless -s res://scripts/tools/validate_content.gd


func _init() -> void:
	var chapters_dir := DirAccess.open("res://content/chapters")
	var objects_dir := DirAccess.open("res://content/objects")
	assert(chapters_dir != null, "missing chapters")
	assert(objects_dir != null, "missing objects")
	var locale := FileAccess.open("res://content/locale/id.json", FileAccess.READ)
	assert(locale != null, "missing id locale")
	var parsed: Variant = JSON.parse_string(locale.get_as_text())
	assert(typeof(parsed) == TYPE_DICTIONARY, "locale not dict")
	print("Technoir content OK: locale keys=", (parsed as Dictionary).size())
	quit(0)
