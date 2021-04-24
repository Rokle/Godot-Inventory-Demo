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
export(Array) var types_to_place = [["any"],["none"]] # types_to_place[0] items that can be placed, types_to_place[1] cant
export(Array) var types_to_take = [["any"],["none"]] # types_to_take[0] items that can be taked, types_to_take[1] cant

func _ready():
	var rect = get_rect()
	rect.position.x = rect_global_position.x
	rect.position.y = rect_global_position.y
	CorrectedMouseEnter.slots = [self, rect, get_parent().visible]
	texture = $Control/ItemInventorySprite
	text = $Control/ItemInventorySprite/Label
	button = $TextureButton

func set_content(con):
	content = con
	content_update(content)

func content_update(con):
	content[0] = con[0]
	content[1] = con[1]
	content[2] = con[2]
	if content[0] == 0 or content[1] == 0:
		texture.texture = null
		text.text = ""
		content[0] = 0
		content[1] = 0
		content[2] = []
	else:
		texture.texture = load(ItemData.item_data[str(content[0])]["texture"])
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
		text.set("custom_colors/font_color","ffdd44" if content[1] == ItemData.item_data[str(content[0])]["max_amount"] else "ffffff")
		return
	button.self_modulate = "737373"
	text.set("custom_colors/font_color","ffffff")


func content_manipulation(button_pressed):
	match type:
		"standart":
			InventoryManager.swap_items(self,InventoryManager.mouse_slot,button_pressed)
		"trash":
			if InventoryManager.mouse_slot.content[0] == 0:
				InventoryManager.add_item(InventoryManager.mouse_slot,content)
		_:
			if can_swap_items(InventoryManager.mouse_slot.content) == true:
				InventoryManager.swap_items(self,InventoryManager.mouse_slot,button_pressed)

# content_to_swap = mouse_slot_content in most cases, but for custom adding (dividing etc) needs to be like that
func can_swap_items(content_to_swap):
	var slot_content_tags = ItemData.item_data[str(content_to_swap[0])]["tags"]
	var self_content_tags = ItemData.item_data[str(content[0])]["tags"]
	if InventoryManager.mouse_slot.content[0] !=0:
		if !("any" in types_to_place[0] or is_array_has(types_to_place[0],slot_content_tags)) or !("none" in types_to_place[1] or (is_array_has(types_to_place[1],slot_content_tags) == false)):
			return false
	if content[0] != 0:
		if !("any" in types_to_take[0] or is_array_has(types_to_take[0],self_content_tags)) or !("none" in types_to_take[1] or (is_array_has(types_to_take[1],self_content_tags) == false)):
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
						if content[0] == 0:
							return
				if "armor" in ItemData.item_data[str(content[0])]["tags"]:
					content_update([content[0],InventoryManager.add_item(display.equipment_display.inventory_id, content,true), content[2]])
					if content[0] == 0:
						return
				if pos < 10:
					content_update([content[0],InventoryManager.add_item(display.inventory_id, content, true,[-1,10]), content[2]])
					return
				content_update([content[0],InventoryManager.add_item(display.inventory_id, content, true,[0,10]), content[2]])
			_:
				content_update([content[0],InventoryManager.add_item("player_inventory", content, true, [-1,-1]), content[2]])
		return
	content_manipulation(InventoryManager.mouse_slot.button_released)

func _mouse_entered():
	display.hover_slot("enter",self)
	if Input.is_action_pressed("LeftClick") or Input.is_action_pressed("RightClick"):
		InventoryManager.mouse_slot.distribute_items_to = self

func _mouse_exited():
	display.hover_slot("exit",self)
