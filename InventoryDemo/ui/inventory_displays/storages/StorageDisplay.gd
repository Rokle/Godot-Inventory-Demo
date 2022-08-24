extends VBoxContainer

var current_storage = null
var current_storage_type = "error"
var current_storage_size = Vector2(0,0)

var inventory_display

var inventory_id

var all_slots = []
var slots = []

var layers = []

var hovered_slot = null

func _ready():
	layers = get_children()
	for group in layers:
		for slot in group.get_children():
			slot.visible = false
			all_slots.append(slot)
			slot.connect("item_changed", self, "_in_slot_item_changed")
	_open_storage(false)
# warning-ignore:return_value_discarded
	InventoryManager.connect("storage_opened",self,"_open_storage")
# warning-ignore:return_value_discarded
	InventoryManager.connect("storage_set", self, "_set_storage")
# warning-ignore:return_value_discarded
	InventoryManager.connect("find_display", self, "display_found")
	inventory_display = get_parent().find_node("Inventory")

func _set_storage(storage, type):
	
	if storage.can_open == false:
		_delete_storage()
		return
	
	if storage != current_storage:
		_delete_storage()
		current_storage = storage
	
	current_storage_type = type
	current_storage_size = StorageData.storage_type_sizes[current_storage_type]
	inventory_id = storage.inventory_id
	update_storage()
	
	InventoryManager.current_storage = current_storage
	
	_open_storage(current_storage.opened)


func update_storage():
	slots = []
	var pos_to_give = 0 
	for column in range(len(layers)):
		for row in range(layers[column].get_child_count()):
			var slot = layers[column].get_child(row)
			if column > current_storage_size.x-1 or row > current_storage_size.y-1:
				slot.visible = false
				slot.type = InventoryManager.disabled_slot_type
				continue
			slot.visible = true
			slot.type = InventoryManager.default_slot_type
			slot.pos = pos_to_give
			slot.set_content(StorageData.storage_data[inventory_id][pos_to_give])
			InventoryManager.update_storage_slots_tags(slot,current_storage_type)
			pos_to_give +=1
			slots.append(slot)

func _delete_storage():
	_open_storage(false)
	if current_storage != null:
		current_storage.opened = false
	current_storage = null
	inventory_id = null

func _open_storage(opened):
	for layer in range(layers.size()):
		if layer < current_storage_size.y:
			layers[layer].visible = opened
		else:
			layers[layer].visible = false
	if current_storage != null:
		current_storage.opened = opened
	CorrectedMouseEnter._check_visibility(get_global_mouse_position())

func display_found(id):
	if id == inventory_id:
		InventoryManager.display = self

# warning-ignore:unused_argument
func _in_slot_item_changed(pos):
	pass

func hover_slot(slot_state,slot):
	if slot_state == "enter" and slot != null:
		if slot.get_parent().visible:
			hovered_slot = slot
			InventoryManager.mouse_slot.show_stats(slot_state, hovered_slot.content[0])  
			return
	hovered_slot = null
	InventoryManager.mouse_slot.show_stats(slot_state, InventoryManager.empty_slot_preset[0])

