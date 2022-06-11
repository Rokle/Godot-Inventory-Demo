extends Node

var available_languages = ["en_US","en_GB"]
var current_language = 0

func _ready() -> void:
	change_language(current_language)

func change_language(change_to: int):
	
	if abs(change_to) >= len(available_languages):
		print("Error. Non-existent language is trying to be displayed")
		return
	
	current_language = change_to
	
	TranslationServer.set_locale(available_languages[current_language])
