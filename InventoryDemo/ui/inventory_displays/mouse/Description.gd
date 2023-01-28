extends Container

onready var background = get_node("Panel/Background")
onready var description = get_node("Panel/VMargins/HMargins/VBoxContainer/Description")

var description_container
var item_name_preset = "item%s_name"
var item_description_preset = "item%s_description"

var window_height = ProjectSettings.get_setting("display/window/size/height")
var window_widht = ProjectSettings.get_setting("display/window/size/width")

func _ready():
	description_container = get_parent()

func update_position(mouse_pos):
	if not description_container.visible:
		return
	
	description_container.position.x = window_widht - mouse_pos.x - 6 - rect_size.x  if mouse_pos.x + rect_size.x + 6 > window_widht else 0
	description_container.position.y = window_height - mouse_pos.y - 6 - rect_size.y  if mouse_pos.y + rect_size.y + 6 > window_height else 0

func show_description(id):
	background.visible = true
	description.text = tr(item_name_preset%id)
	description.text += "\n"
	description.text += tr(item_description_preset%id)

func show_name(id):
	background.visible = false
	description.text = tr(item_name_preset%id)
