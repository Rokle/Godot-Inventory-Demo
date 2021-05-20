extends VBoxContainer

var inventory_id

var layers = []
var slots = []
var pos_to_give = 0
var storage_display

var hovered_slot

func _ready():
	storage_display = get_parent()
	storage_display.current_storage_display = self
	InventoryManager.connect("find_display", self, "display_found")
# warning-ignore:return_value_discarded
	layers = get_children()
	for group in layers:
		for slot in group.get_children():
			slots.append(slot)
			slot.connect("item_changed", self, "_in_slot_item_changed")
			slot.set_content(StorageData.storage_data[inventory_id][pos_to_give])
			pos_to_give+=1

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
		InventoryManager.mouse_slot.show_stats(slot_state, "nothing")
