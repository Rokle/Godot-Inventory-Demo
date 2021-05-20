extends Node

var item_data
var current_language = "en"

func _ready():
	change_language(current_language)

#If you want to change language you need to change fonts
func change_language(change_to):
	current_language = change_to
	var language_all_data_files = File.new()
	language_all_data_files.open("res://data/language_data/%s/items/descriptions.json" % current_language,File.READ)
	item_data = JSON.parse(language_all_data_files.get_as_text()).result
	language_all_data_files.close()
