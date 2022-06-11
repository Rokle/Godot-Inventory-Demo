extends Node

const default_storage_type = 0
const storage_type_sizes = [
	Vector2(3,3), #simple_bag
	Vector2(2,5)  #chest
]

var storage_data

var last_used_inventory_id: int = 0

func _ready() -> void:
	var storage_data_file = File.new()
	storage_data_file.open("res://data/Storages.json",File.READ)
	storage_data = JSON.parse(storage_data_file.get_as_text()).result
	storage_data_file.close()

func get_new_inventory_id() -> String:
	last_used_inventory_id+=1
	return str(last_used_inventory_id)

func change_storage_data(id: String, pos: int, content: Array) -> void:
	InventoryManager.emit_signal("find_display", id)
	
	InventoryManager.slots_display[pos].content = content

func create_new_storage(content: Array):
	var empty_inventory_preset = []
	content[2]["inventory_id"] = get_new_inventory_id()
	var storage_type:int = ItemData.item_data[content[0]]["properties"]["storage_type"]
	if storage_type > len(storage_type_sizes):
		print("Wrong inventory type")
		return
	var current_storage_size = storage_type_sizes[storage_type]
	var total_amount_of_slots = current_storage_size.x * current_storage_size.y
	match storage_type:
		0:
			# warning-ignore:unused_variable
			for i in range(total_amount_of_slots):
				empty_inventory_preset.append(InventoryManager.empty_slot_preset.duplicate(true))
			storage_data[content[2]["inventory_id"]] = empty_inventory_preset
