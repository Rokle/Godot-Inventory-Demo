extends CenterContainer

signal item_changed(pos)

var pos

var texture
var text
var button
var content setget content_update

onready var display = get_parent().get_parent()

export(String) var type = "standart"
export(bool) var can_inventory_add = true
# Allow inventory add item when function "add_item" call in InventoryManager.gd
export(Array) var item_tags_to_place = InventoryManager.default_item_tags_to_place # item_tags_to_place[0] items that can be placed, item_tags_to_place[1] cant
export(Array) var item_tags_to_take = InventoryManager.default_item_tags_to_take # item_tags_to_take[0] items that can be taked, item_tags_to_take[1] cant

func _ready():
	call_deferred("add_slot_prop_to_mouse_enter")
	texture = $Control/ItemInventorySprite
	text = $Control/ItemInventorySprite/Label
	button = $TextureButton

func add_slot_prop_to_mouse_enter():
	var rect = get_rect()
	rect.position.x = rect_global_position.x
	rect.position.y = get_slot_y_pos()
	CorrectedMouseEnter.slots = [self, rect, get_parent().visible]

func get_slot_y_pos() -> float:
	var group = get_parent()
	var y_pos = display.layers[0].rect_global_position.y
	var separation = display.get("custom_constants/separation")
	
	for layer in display.layers:
		if layer == group:
			break
		
		y_pos+=separation+layer.rect_size.y
	
	return y_pos

func set_content(new_content):
	content = new_content
	content_update(content)

func content_update(new_content):
	content[0] = new_content[0]
	content[1] = new_content[1]
	content[2] = new_content[2]
	if content[0] == 0 or content[1] == 0:
		texture.texture = null
		text.text = ""
		content[0] = InventoryManager.empty_slot_preset[0]
		content[1] = InventoryManager.empty_slot_preset[1]
		content[2] = InventoryManager.empty_slot_preset[2]
	else:
		texture.texture = load(Links.item_texture_path_preset % content[0])
		text.text = str(content[1]) if content[1] > 1 else ""
	if display.hovered_slot == self:
		InventoryManager.mouse_slot.show_stats("exit" if content[1] == 0 else "enter",content[0])
	emit_signal("item_changed",pos)

func selected(state):
	if state == "selected":
		button.self_modulate = "78805f"
		text.set("custom_colors/font_color","ffffff")
		return
	if state == "dividing":
		button.self_modulate = "4c4c4c"
		text.set("custom_colors/font_color","ffdd44" if content[1] == ItemData.item_data[content[0]]["max_amount"] else "ffffff")
		return
	button.self_modulate = "737373"
	text.set("custom_colors/font_color","ffffff")


func content_manipulation(button_pressed):
	match type:
		"standart":
			InventoryManager.swap_items(self,InventoryManager.mouse_slot,button_pressed)
		"trash":
			if InventoryManager.mouse_slot.content[0] != InventoryManager.empty_slot_preset[0]:
				content[0] = 0
				content_update(content)
			InventoryManager.swap_items(self,InventoryManager.mouse_slot,button_pressed)
			
		"disabled":
			return
		_:
			if can_swap_items(InventoryManager.mouse_slot.content) == true:
				InventoryManager.swap_items(self,InventoryManager.mouse_slot,button_pressed)

# content_to_swap = mouse_slot_content in most cases, but for custom adding (dividing etc) needs to be like that
func can_swap_items(content_to_swap):
	var slot_content_tags = ItemData.item_data[content_to_swap[0]]["tags"]
	var self_content_tags = ItemData.item_data[content[0]]["tags"]
	if InventoryManager.mouse_slot.content[0] != InventoryManager.empty_slot_preset[0]:
		if !(is_array_has(InventoryManager.default_item_tags_to_place[0],item_tags_to_place[0]) or is_array_has(item_tags_to_place[0],slot_content_tags)) or !(is_array_has(InventoryManager.default_item_tags_to_place[1],item_tags_to_place[1]) or (is_array_has(item_tags_to_place[1],slot_content_tags) == false)):
			return false
	if content[0] != InventoryManager.empty_slot_preset[0]:
		if !(is_array_has(InventoryManager.default_item_tags_to_take[0],item_tags_to_take[0]) or is_array_has(item_tags_to_take[0],self_content_tags)) or !(is_array_has(InventoryManager.default_item_tags_to_take[1],item_tags_to_take[1]) or (is_array_has(item_tags_to_take[1],self_content_tags) == false)):
			return false
	return true

func is_array_has(what_has, where_search):
	for items in what_has:
		if items in where_search:
			return true
	return false

func _on_button_up():
	if InventoryManager.inventory_is_open == false:
		if InventoryManager.selected_slot != self:
			display.select_slot(self)
			return
		return
	if Input.is_action_pressed("Shift"):
		match display.inventory_id:
			"player_inventory":
				if display.storage_display.current_storage != null:
					if display.storage_display.current_storage.opened == true:
						content_update([content[0], InventoryManager.add_item(display.storage_display.current_storage.inventory_id, content), content[2]])
						if content[0] == InventoryManager.empty_slot_preset[0]:
							return
				if "armor" in ItemData.item_data[content[0]]["tags"]:
					content_update([content[0],InventoryManager.add_item(display.equipment_display.inventory_id, content), content[2]])
					if content[0] == InventoryManager.empty_slot_preset[0]:
						return
				if pos < 10:
					content_update([content[0],InventoryManager.add_item(display.inventory_id, content,[-1,10]), content[2]])
					return
				content_update([content[0],InventoryManager.add_item(display.inventory_id, content,[0,10]), content[2]])
			_:
				content_update([content[0],InventoryManager.add_item("player_inventory", content, [-1,-1]), content[2]])
		return
	content_manipulation(InventoryManager.mouse_slot.button_released)

func _mouse_entered():
	display.hover_slot("enter",self)
	if Input.is_action_pressed("LeftClick") or Input.is_action_pressed("RightClick"):
		InventoryManager.mouse_slot.distribute_items_to = self

func _mouse_exited():
	display.hover_slot("exit",self)
