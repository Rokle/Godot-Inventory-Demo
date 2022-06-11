extends Node

var item_info
var can_open = true
var opened = false
var inventory_id = "error"

func handle_bags(slot):
	item_info = ItemData.item_data[slot.content[0]] 
	if not "inventory_id" in slot.content[2]:
		StorageData.create_new_storage(slot.content)
	if inventory_id == slot.content[2]["inventory_id"] and InventoryManager.current_storage == self:
		open_bag(not opened)
		get_parent().open_storage(opened)
		return
	inventory_id = slot.content[2]["inventory_id"]
	opened = true
	InventoryManager.emit_signal("storage_set",self,item_info["properties"]["storage_type"])
	open_bag(true)
	get_parent().open_storage(opened)

func open_bag(open):
	opened = open
