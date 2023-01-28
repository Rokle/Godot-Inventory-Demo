extends Control
var layers = []
var slots = []
var pos_to_give = 0

var storage_display

var hovered_slot = null
var selected_slot
var selected_slot_pos = 0
var inventory_id = "player_equipment"

func _ready():
	storage_display = get_parent().find_node("Storage")
# warning-ignore:return_value_discarded
	InventoryManager.connect("inventory_opened", self, "inventory_changer")
# warning-ignore:return_value_discarded
	InventoryManager.connect("find_display", self, "display_found")
	
	layers = get_children()
	for group in layers:
		for slot in group.get_children():
			slots.append(slot)
			slot.set_content(StorageData.storage_data[inventory_id][pos_to_give])
			slot.pos = pos_to_give
			pos_to_give += 1
	inventory_changer(InventoryManager.inventory_is_open)

#warning-ignore:unused_argument
func _in_slot_item_changed(pos):
	pass

func display_found(id):
	if id == inventory_id:
		InventoryManager.display = self

func hover_slot(slot_state,slot):
	if slot_state == "enter" and slot != null:
		hovered_slot = slot
		InventoryManager.mouse_slot.show_stats(slot_state, hovered_slot.content[0])  
	else:
		hovered_slot = null
		InventoryManager.mouse_slot.show_stats(slot_state, InventoryManager.empty_slot_preset[0])

func inventory_changer(opened):
	for layer in layers:
		layer.visible = opened
	CorrectedMouseEnter._check_visibility(get_global_mouse_position())
