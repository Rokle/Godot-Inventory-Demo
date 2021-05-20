extends Node2D

var inventory_id = "player_inventory"

func _physics_process(delta):
	ui_manager()

func drop_item(id):
	#something
	pass

func ui_manager():
	if Input.is_action_just_pressed("E"):
		InventoryManager.inventory_is_open = not InventoryManager.inventory_is_open
		open_inventory(InventoryManager.inventory_is_open)
	if Input.is_action_just_pressed("Exit"):
		if InventoryManager.inventory_is_open == true:
			InventoryManager.inventory_is_open = not InventoryManager.inventory_is_open
			open_inventory(InventoryManager.inventory_is_open)
	if Input.is_action_just_pressed("DropItem"):
		if InventoryManager.selected_slot.content[0] != "nothing":
			drop_item([InventoryManager.selected_slot.content[0],1])
			InventoryManager.selected_slot.content = [InventoryManager.selected_slot.content[0],InventoryManager.selected_slot.content[1]-1, []]
	if InventoryManager.inventory_is_open == false:
		if int(Input.is_action_just_released("WheelDown")) - int(Input.is_action_just_released("WheelUp")) != 0:
			InventoryManager.emit_signal("selection_changed",int(Input.is_action_just_released("WheelDown")) - int(Input.is_action_just_released("WheelUp")))

func open_inventory(opened):
	InventoryManager.inventory_is_open = opened
	if opened == false:
		if InventoryManager.mouse_slot.content[0] != "nothing":
			if InventoryManager.add_item(inventory_id,InventoryManager.mouse_slot.content) != 0:
				drop_item(InventoryManager.mouse_slot.content)
			InventoryManager.mouse_slot.content = ["nothing",0,[]]
		InventoryManager.emit_signal("storage_opened",opened)

func open_storage(opened):
	if opened == true:
		open_inventory(opened)
	InventoryManager.emit_signal("storage_opened",opened)
