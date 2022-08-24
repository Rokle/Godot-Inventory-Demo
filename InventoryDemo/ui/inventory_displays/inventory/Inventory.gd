extends Control

var layers = []
var slots = []
var pos_to_give = 0

var storage_display

var equipment_display

var hovered_slot = null
var selected_slot
var selected_slot_pos = 0
var inventory_id = "player_inventory"

func _ready():
	storage_display = get_parent().find_node("Storage")
	equipment_display = get_parent().find_node("Equipment")
# warning-ignore:return_value_discarded
	InventoryManager.connect("inventory_opened", self, "inventory_changer")
# warning-ignore:return_value_discarded
	InventoryManager.connect("selection_changed", self, "selection_changer")
# warning-ignore:return_value_discarded
	InventoryManager.connect("find_display", self, "display_found")
	
	layers = get_children()
	for group in layers:
		for slot in group.get_children():
			slots.append(slot)
			slot.connect("item_changed", self, "_in_slot_item_changed")
			slot.set_content(StorageData.storage_data[inventory_id][pos_to_give])
			slot.pos = pos_to_give
			pos_to_give += 1
	inventory_changer(InventoryManager.inventory_is_open)
	selected_slot = slots[0]
	selected_slot.selected("selected")
	InventoryManager.selected_slot = selected_slot

#warning-ignore:unused_argument
func _in_slot_item_changed(pos):
	pass

func display_found(id):
	if id == inventory_id:
		InventoryManager.display = self

func hover_slot(slot_state,slot):
	if slot_state == "enter" and slot != null:
		if slot.get_parent().visible:
			hovered_slot = slot
			InventoryManager.mouse_slot.show_stats(slot_state, hovered_slot.content[0])  
			return
	hovered_slot = null
	InventoryManager.mouse_slot.show_stats(slot_state, InventoryManager.empty_slot_preset[0])

func select_slot(slot_to_select):
	selected_slot.selected("none")
	selected_slot = slot_to_select
	selected_slot.selected("selected")
	
	InventoryManager.selected_slot = selected_slot

func inventory_changer(opened):
	for layer in layers:
		layer.visible = opened
	get_child(0).visible = true
	
	if hovered_slot != null:
		if hovered_slot.get_parent().visible == false:
			hover_slot("exit", null)
	CorrectedMouseEnter._check_visibility(get_global_mouse_position())

func selection_changer(dir):
	selected_slot_pos = max(0,(selected_slot_pos + dir+10)%10)
	select_slot(slots[selected_slot_pos])
