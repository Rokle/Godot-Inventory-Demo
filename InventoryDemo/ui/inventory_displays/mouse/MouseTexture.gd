extends Node2D
# make cursor texture

var content setget slot_update
var hovered_object = null
var button_pressed = 0 setget ,get_pressed_button
var button_released = 0 setget ,get_released_button

var texture
var texture_text

var item_name
var stats_id

var description
var description_container

var combine_items = false
var click_used = true

var hovered_object_sprite
var type = "mouse"
var inventory_id = "mouse"
var pos = 0
var slots = [self]

var distribute_content
var distributing = false
var distribution_by_one_item = false

# [[slot,content],[slot,content]...]
var distribute_items_to = [] setget distribute_items

var double_clicked = false

var took_item = false

var last_hovered_slot

onready var timer = get_node("Timer")

func _ready():
	stats_id = InventoryManager.empty_slot_preset[0]
	texture = $ItemInventorySprite
	texture_text = $ItemInventorySprite/Label
	description = $DescriptionContainer/Description
	description_container = $DescriptionContainer
	hovered_object_sprite = $HoveredObjectSprite
	
	InventoryManager.mouse_slot = self
	
	content = StorageData.storage_data[inventory_id][0]
	slot_update(content)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
# warning-ignore:return_value_discarded
	InventoryManager.connect("inventory_opened", self, "inventory_changer")
# warning-ignore:return_value_discarded
	InventoryManager.connect("find_display",self,"display_found")
	
	$AnimationPlayer.play("Cursor")

func display_found(id):
	if id == inventory_id:
		InventoryManager.display = self

func distribute_items(slot):
	
	if distribute_content == null:
		return
	
	if distribute_content[0] == InventoryManager.empty_slot_preset[0]:
		return
	
	if slot.content[0] != InventoryManager.empty_slot_preset[0] and (slot.content[0] != distribute_content[0] or slot.content[2] != distribute_content[2]):
		return
	
	if slot.can_swap_items(distribute_content) == false:
		return
	
	for i in range(distribute_items_to.size()):
		if distribute_items_to[i][0] == slot:
			return
	
# warning-ignore:incompatible_ternary
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
		
		description.update_position(position)
	
	if not event is InputEventMouseButton:
		return
	
	button_pressed = int(Input.is_action_just_pressed("RightClick"))-int(Input.is_action_just_pressed("LeftClick"))
	click_used = true if button_pressed == 0 else false
	
	if double_clicked:
		double_clicked = false
		return
	
	if can_collect_items(event):
		
		double_clicked = true
		
		click_used = true
		
		InventoryManager.collect_items(self, CorrectedMouseEnter.current_slot.display.inventory_id)
		
		if CorrectedMouseEnter.current_slot.display.inventory_id in Links.player_inventories_ids:
			
			if InventoryManager.current_storage == null:
				return
			
			if InventoryManager.current_storage.opened == false:
				return
			
			InventoryManager.collect_items(self, InventoryManager.current_storage.inventory_id)
			return
		
		InventoryManager.collect_items(self, CorrectedMouseEnter.current_slot.display.inventory_display.inventory_id)
		return
	
	if took_item:
		took_item = false
		return
	
	button_released = int(Input.is_action_just_released("RightClick"))-int(Input.is_action_just_released("LeftClick"))
	
	if click_used == false and content[0] == InventoryManager.empty_slot_preset[0] and CorrectedMouseEnter.current_slot != null:
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
				if combine_items == false:
					CorrectedMouseEnter.current_slot._on_button_up()
				combine_items = false
		else:
			for i in range(distribute_items_to.size()):
				distribute_items_to[i][0].selected("none")
			InventoryManager.selected_slot.selected("selected")
		last_hovered_slot = null
		distribute_items_to = []
		distributing = false
	
	if CorrectedMouseEnter.current_slot != null and click_used == false:
		distribute_content = content.duplicate()
		click_used = true
		last_hovered_slot = CorrectedMouseEnter.current_slot
		distribution_by_one_item = true if button_pressed == 1 else false
		distribute_items(last_hovered_slot)

func can_collect_items(event):
	if event.doubleclick == false:
		return false
	
	if button_pressed != -1:
		return false
	
	if CorrectedMouseEnter.current_slot == null:
		return false
	
	if content[0] == InventoryManager.empty_slot_preset[0]:
		return false 
	
	if CorrectedMouseEnter.current_slot.content[0] != InventoryManager.empty_slot_preset[0]:
		return false
	
	if ItemData.item_data[content[0]]["max_amount"] <= 1:
		return false
	
	return true

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
	
	if slot_state == "exit" or stats_id == InventoryManager.empty_slot_preset[0] or content[0] != InventoryManager.empty_slot_preset[0] or distributing == true:
		description.visible = false
		return
	
	description.visible = true
	
	
	if InventoryManager.inventory_is_open == false:
		description.show_name(stats_id)
		return
	
	description.show_description(stats_id)

func hovered_object_texture(object_texture):
	if object_texture == null:
		hovered_object = null
	if hash(content) == hash(InventoryManager.empty_slot_preset):
		hovered_object_sprite.texture = object_texture

func slot_update(new_content):
	content[0] = new_content[0]
	content[1] = new_content[1]
	content[2] = new_content[2]
	if content[0] == InventoryManager.empty_slot_preset[0] or content[1] == InventoryManager.empty_slot_preset[1]:
		texture.texture = null
		texture_text.text = ""
		content[0] = InventoryManager.empty_slot_preset[0]
		content[1] = InventoryManager.empty_slot_preset[1]
		content[2] = InventoryManager.empty_slot_preset[2]
	else:
		texture.texture = load(Links.item_texture_path_preset % content[0])
		texture_text.text = str(content[1]) if content[1] > 1 else ""
	show_stats("enter" if content[1] == 0 else "exit", stats_id)

func _on_Timer_timeout():
	pass
