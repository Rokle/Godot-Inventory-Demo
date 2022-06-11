extends VBoxContainer

var inventory_id
var current_storage_type = "error"
var current_storage_size = Vector2(0,0)

var all_slots = []
var slots = []

var layers = []

var hovered_slot = null

func _ready():
	layers = get_children()
	for group in layers:
		for slot in group.get_children():
			all_slots.append(slot)
	#warning-ignore:RETURN_VALUE_DISCARDED
	InventoryManager.connect("invisible_storage_set", self, "_set_storage")
	#warning-ignore:RETURN_VALUE_DISCARDED
	InventoryManager.connect("find_display", self, "display_found")

func _set_storage(storage_inventory_id, type):
	if type == "disabled":
		inventory_id = "error"
		return
	current_storage_type = type
	current_storage_size = StorageData.storage_type_sizes[current_storage_type]
	inventory_id = storage_inventory_id
	update_storage()


func update_storage():
	slots = []
	var pos_to_give = 0 
	for column in range(len(layers)):
		for row in range(layers[column].get_child_count()):
			var slot = layers[column].get_child(row)
			if column > current_storage_size.x-1 or row > current_storage_size.y-1:
				slot.type = InventoryManager.disabled_slot_type
				continue
			slot.type = InventoryManager.default_slot_type
			slot.pos = pos_to_give
			slot.set_content(StorageData.storage_data[inventory_id][pos_to_give])
			InventoryManager.update_storage_slot_tags(slot,current_storage_type)
			pos_to_give +=1
			slots.append(slot)

func display_found(id):
	if id == inventory_id:
		InventoryManager.display = self
