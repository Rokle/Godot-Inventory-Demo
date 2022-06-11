extends Node

var item_data

func _ready() -> void:
	var item_data_file = File.new()
	item_data_file.open("res://data/Items.json",File.READ)
	item_data = JSON.parse(item_data_file.get_as_text()).result
	item_data_file.close()
