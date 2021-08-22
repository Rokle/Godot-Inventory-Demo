extends Node2D
# make cursor texture

var window_height = ProjectSettings.get_setting("display/window/size/height")
var window_widht = ProjectSettings.get_setting("display/window/size/width")

var content setget slot_update
var storage = null
var button_pressed = 0 setget ,get_pressed_button
var button_released = 0 setget ,get_released_button

var texture
var texture_text

var item_name
var stats_id = "nothing"

var description
var description_container

var click_used = true

var storage_sprite
var type = "mouse"
var inventory_id = "mouse"

var distribute_content
var distributing = false
var distribution_by_one_item = false
var distribute_items_to = [] setget distribute_items

var double_clicked = false

var took_item = false

var last_hovered_slot

onready var timer = get_node("Timer")

func _ready():
	texture = $ItemInventorySprite
	texture_text = $ItemInventorySprite/Label
	description = $DescriptionContainer/Description
	description_container = $DescriptionContainer
	storage_sprite = $StorageSprite
	
	InventoryManager.mouse_slot = self
	
	content = StorageData.storage_data[inventory_id][0]
	slot_update(content)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	InventoryManager.connect("inventory_opened", self, "inventory_changer")
	
	$AnimationPlayer.play("Cursor")

func distribute_items(slot):
	
	if distribute_content == null:
		return
	
	if distribute_content[0] == "nothing":
		return
	
	if slot.content[0] != "nothing" and (slot.content[0] != distribute_content[0] or slot.content[2] != distribute_content[2]):
		return
	
	if slot.can_swap_items(distribute_content) == false:
		return
	
	for i in range(distribute_items_to.size()):
		if distribute_items_to[i][0] == slot:
			return
	
	var distribute_amount = int(distribute_content[1] / (distribute_items_to.size()+1)) if distribution_by_one_item == false else min(1,int(distribute_content[1] / (distribute_items_to.size()+1)))
	
	if distribute_amount < 1:
		return
	
	distribute_items_to.append([slot,slot.content.duplicate()])
	
	if distribute_items_to.size() == 1:
		return
	
	distributing = true
	
	var max_amount = ItemData.item_data[distribute_content[0]]["max_amount"]
	var amount_left = distribute_content[1]
	
	for i in range (distribute_items_to.size()):
		distribute_items_to[i][0].content = [distribute_content[0],min(distribute_items_to[i][1][1]+distribute_amount,max_amount), distribute_content[2]]
		distribute_items_to[i][0].selected("dividing")
		amount_left -= distribute_items_to[i][0].content[1] - distribute_items_to[i][1][1]
	
	slot_update([distribute_content[0],amount_left, distribute_content[2]])

func inventory_changer(_state):
	show_stats("enter", stats_id)

func _input(event):
	
	if event is InputEventMouseMotion:
		position = event.position
		CorrectedMouseEnter.is_mouse_enter_slot(position)
		
	if description.visible == true:
		description_container.position.x = window_widht - position.x - 6 - description.background.rect_size.x  if position.x + description.background.rect_size.x + 6 > window_widht else 0
		description_container.position.y = window_height - position.y - 6 - description.background.rect_size.y  if position.y + description.background.rect_size.y + 6 > window_height else 0
	
	if not event is InputEventMouseButton:
		return
	
	button_pressed = int(Input.is_action_just_pressed("RightClick"))-int(Input.is_action_just_pressed("LeftClick"))
	
	click_used = true if button_pressed == 0 else false
	
	if double_clicked:
		double_clicked = false
		return
	
	if event.doubleclick == true and button_pressed == -1 and CorrectedMouseEnter.current_slot != null:
		
		double_clicked = true
		
		click_used = true
		
		InventoryManager.collect_items(CorrectedMouseEnter.current_slot.display.inventory_id, self)
		
		if CorrectedMouseEnter.current_slot.display.inventory_id in Links.player_inventories_ids:
			
			if CorrectedMouseEnter.current_slot.display.storage_display.current_storage_display == null:
				return
			
			if CorrectedMouseEnter.current_slot.display.storage_display.current_storage.opened == false:
				return
			
			InventoryManager.collect_items(CorrectedMouseEnter.current_slot.display.storage_display.current_storage_display.inventory_id, self)
			return
		
		InventoryManager.collect_items(CorrectedMouseEnter.current_slot.display.storage_display.inventory_display.inventory_id, self)
		return
	
	if took_item:
		took_item = false
		return
	
	button_released = int(Input.is_action_just_released("RightClick"))-int(Input.is_action_just_released("LeftClick"))
	
	if click_used == false and content[0] == "nothing" and CorrectedMouseEnter.current_slot != null:
		button_released = button_pressed
		click_used = true
		took_item = true
		distribute_content = null
	
	if button_released:
		if distributing == false:
			if CorrectedMouseEnter.current_slot == null:
				if last_hovered_slot != null:
					last_hovered_slot._on_button_up()
			else:
				CorrectedMouseEnter.current_slot._on_button_up()
		else:
			for i in range(distribute_items_to.size()):
				distribute_items_to[i][0].selected("none")
		last_hovered_slot = null
		distribute_items_to = []
		distributing = false
	
	if CorrectedMouseEnter.current_slot != null and click_used == false:
		distribute_content = content.duplicate()
		click_used = true
		last_hovered_slot = CorrectedMouseEnter.current_slot
		distribution_by_one_item = true if button_pressed == 1 else false
		distribute_items(last_hovered_slot)

func get_pressed_button():
	if button_pressed == 1:
		return "right"
	if button_pressed == -1:
		return "left"
	return "none"

func get_released_button():
	if button_released == 1:
		return "right"
	if button_released == -1:
		return "left"
	return "none"

func show_stats(slot_state, id):
	
	stats_id = id
	
	if slot_state == "exit" or stats_id == "nothing" or content[0] != "nothing" or distributing == true:
		description.visible = false
		return
	
	description.visible = true
	
	if InventoryManager.inventory_is_open == false:
		description.show_name(stats_id)
		return
	
	description.show_description(stats_id)

func storage_texture(tex):
	if content == ["nothing",0,[]]:
		storage_sprite.texture = tex

func slot_update(con):
	content[0] = con[0]
	content[1] = con[1]
	content[2] = con[2]
	if content[0] == "nothing" or content[1] == 0:
		texture.texture = null
		texture_text.text = ""
		content[0] = "nothing"
		content[1] = 0
		content[2] = []
	else:
		texture.texture = load(ItemData.item_data[content[0]]["texture"])
		texture_text.text = str(content[1]) if content[1] > 1 else ""
	show_stats("enter" if content[1] == 0 else "exit", stats_id)


func _on_Timer_timeout():
	pass
