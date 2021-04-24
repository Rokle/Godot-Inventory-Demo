extends Container

var description
var background

func _ready():
	description = $Description
	background = $NinePatchRect
	set_process(false)

func _process(_delta):
	description.rect_size = Vector2.ZERO
	background.rect_size = description.rect_size
	background.rect_size.x += 8
	background.rect_size.y += 3
	set_process(false)

func show_description(id):
	background.visible = true
	description.text = LanguageData.item_data[id]["name"]
	description.text += "\n"
#	description.text += LanguageData.item_data[id]["type"]
#	description.text += "\n"
	id = str(id)
	description.text += (LanguageData.item_data[id]["description"])
	set_process(true)

func show_name(id):
	background.visible = false
	description.text = LanguageData.item_data[id]["name"]
	id = str(id)
