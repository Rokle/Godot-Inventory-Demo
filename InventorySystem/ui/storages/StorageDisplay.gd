extends Control

var current_storage = null
var current_storage_display

var inventory_display

func _ready():
	InventoryManager.connect("storage_opened",self,"_open_storage")
	InventoryManager.connect("storage_set", self, "_set_storage")
	inventory_display = get_parent().find_node("InventorySlotsDisplay")

func _set_storage(storage):
	if current_storage == null and storage.can_open == true:
		current_storage = storage
		if get_child_count() > 0:
			_open_storage(false)
			get_child(0).queue_free()
		var storage_display = load("res://ui/storages/%s/%s.tscn" % [current_storage.storage_type,current_storage.ui_type]).instance()
		storage_display.inventory_id = current_storage.inventory_id
		call_deferred("add_child",storage_display)
	elif current_storage == storage and storage.can_open == false:
		if get_child_count() > 0:
			_open_storage(false)
			get_child(0).queue_free()
		current_storage = null
	elif current_storage != storage and storage.can_open == true:
		current_storage.opened = false
		if get_child_count() > 0:
			_open_storage(false)
			get_child(0).queue_free()
		current_storage = storage
		var storage_display = load("res://ui/storages/%s/%s.tscn" % [current_storage.storage_type,current_storage.ui_type]).instance()
		storage_display.inventory_id = current_storage.inventory_id
		call_deferred("add_child",storage_display)
	elif storage == current_storage:
		if get_child_count() > 0:
			_open_storage(current_storage.opened)
	else:
		if get_child_count() > 0:
			_open_storage(false)
			get_child(0).queue_free()
		current_storage = null

func _open_storage(state):
	if get_child_count() > 0:
		for layer in get_child(0).get_children():
			layer.visible = state
		if current_storage != null:
			current_storage.opened = state
		if state == false:
			InventoryManager.mouse_slot.show_stats("exit", "nothing")
		CorrectedMouseEnter._check_visibility(get_global_mouse_position())
