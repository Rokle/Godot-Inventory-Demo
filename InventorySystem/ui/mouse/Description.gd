extends Container

var description
var background
var description_container

var window_height = ProjectSettings.get_setting("display/window/size/height")
var window_widht = ProjectSettings.get_setting("display/window/size/width")

func _ready():
	description = $Description
	background = $NinePatchRect
	description_container = get_parent()
	set_process(false)

func _process(_delta):
	description.rect_size = Vector2.ZERO
	background.rect_size = description.rect_size
	background.rect_size.x += 8
	background.rect_size.y += 3
	set_process(false)

func update_position(mouse_pos):
	if not description_container.visible:
		return
	
	description_container.position.x = window_widht - mouse_pos.x - 6 - background.rect_size.x  if mouse_pos.x + background.rect_size.x + 6 > window_widht else 0
	description_container.position.y = window_height - mouse_pos.y - 6 - background.rect_size.y  if mouse_pos.y + background.rect_size.y + 6 > window_height else 0

func show_description(id):
	background.visible = true
	description.text = LanguageData.item_data[id]["name"]
	description.text += "\n"
#	description.text += LanguageData.item_data[id]["type"]
#	description.text += "\n"
	description.text += (LanguageData.item_data[id]["description"])
	set_process(true)

func show_name(id):
	background.visible = false
	description.text = LanguageData.item_data[id]["name"]
