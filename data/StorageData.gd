extends Node

var storage_data

func _ready():
	var storage_data_file = File.new()
	storage_data_file.open("res://data/Storages.json",File.READ)
	storage_data = JSON.parse(storage_data_file.get_as_text()).result
	storage_data_file.close()

func change_storage_data(id:String, pos:int, content:Array):
	InventoryManager.emit_signal("find_display", id)
	InventoryManager.slots_display[pos].content = content
