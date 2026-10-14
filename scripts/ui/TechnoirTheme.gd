class_name TechnoirTheme
extends RefCounted
## Cream / brass soft UI tokens from Figma Memoirs of Technoir.

const CREAM := Color("F7F1E8")
const CREAM_DEEP := Color("EDE4D6")
const BRASS := Color("C4A35A")
const BRASS_DARK := Color("8B7340")
const INK := Color("2C2416")
const INK_SOFT := Color("5C5346")
const NIGHT := Color("1A2744")
const NIGHT_DEEP := Color("0E1628")
const WARM_LAMP := Color("E8B86D")
const ACCENT_ORANGE := Color("E8A87C")
const WHITE := Color("FFFFFF")
const PILL := Color("2A2A2A")


static func apply_root(control: Control) -> void:
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


static func make_panel_style(bg: Color = CREAM, radius: float = 18.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = int(radius)
	s.corner_radius_top_right = int(radius)
	s.corner_radius_bottom_left = int(radius)
	s.corner_radius_bottom_right = int(radius)
	return s


static func style_button(btn: Button, filled: bool = true) -> void:
	btn.focus_mode = Control.FOCUS_NONE
	var normal := StyleBoxFlat.new()
	var hover := StyleBoxFlat.new()
	var pressed := StyleBoxFlat.new()
	for s in [normal, hover, pressed]:
		s.corner_radius_top_left = 28
		s.corner_radius_top_right = 28
		s.corner_radius_bottom_left = 28
		s.corner_radius_bottom_right = 28
		s.content_margin_left = 22
		s.content_margin_right = 22
		s.content_margin_top = 14
		s.content_margin_bottom = 14
	if filled:
		normal.bg_color = PILL
		hover.bg_color = Color("3A3A3A")
		pressed.bg_color = Color("1A1A1A")
		btn.add_theme_color_override("font_color", WHITE)
		btn.add_theme_color_override("font_hover_color", WHITE)
		btn.add_theme_color_override("font_pressed_color", CREAM)
	else:
		normal.bg_color = Color(1, 1, 1, 0.0)
		normal.border_width_bottom = 0
		hover.bg_color = Color(BRASS.r, BRASS.g, BRASS.b, 0.15)
		pressed.bg_color = Color(BRASS.r, BRASS.g, BRASS.b, 0.25)
		btn.add_theme_color_override("font_color", INK)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_font_size_override("font_size", 18)


static func style_label_title(label: Label, night: bool = false) -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", WHITE if night else INK)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


static func style_label_body(label: Label, night: bool = false) -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95) if night else INK_SOFT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
