extends Node

# warning-ignore:unused_signal
signal inventory_opened(opened)
# warning-ignore:unused_signal
signal storage_set(storage,type)
# warning-ignore:unused_signal
signal invisible_storage_set(storage,type)
# warning-ignore:unused_signal
signal storage_opened(state)
# warning-ignore:unused_signal
signal selection_changed(dir)

signal find_display(display_inventory_id)

const empty_slot_preset = [0,0,{}]

const default_item_tags_to_place = [["all"],["none"]]
const default_item_tags_to_take = [["all"],["none"]]

const default_slot_type = "default"
const disabled_slot_type = "disabled"

var display

var mouse_slot
var selected_slot

var current_storage

var inventory_is_open = false setget open_inventory

func add_item(receiver_inventory_id: String, content: Array, var adding_interval: Array = [0,0]) -> int:

	var add_place = StorageData.storage_data[receiver_inventory_id]
	emit_signal("find_display", receiver_inventory_id)
	
	var adding_range = get_adding_range(add_place,adding_interval)
	
	var item_id = content[0]
	var remaining_amount = content[1]
	var max_amount = ItemData.item_data[item_id]["max_amount"]
	
	# Add items to existing stack
	if max_amount != 1:
		for slot_pos in adding_range:
			if display.slots[slot_pos].can_swap_items(content) == true:
				if item_id == add_place[slot_pos][0] and hash(content[2]) == hash(add_place[slot_pos][2]):
					var content_buffer = display.slots[slot_pos].content[1]
					display.slots[slot_pos].content = [display.slots[slot_pos].content[0],min(max_amount,display.slots[slot_pos].content[1] + remaining_amount), content[2]]
					remaining_amount = max(0, remaining_amount - max_amount + content_buffer) 
				
				if remaining_amount == 0:
					return 0
	
	# Create new stack if can
	if remaining_amount > 0:
		for slot_pos in adding_range:
			if display.slots[slot_pos].can_swap_items(content) == true:
				if display.slots[slot_pos].content[0] == InventoryManager.empty_slot_preset[0]:
					display.slots[slot_pos].content = [item_id, min(remaining_amount,max_amount), content[2]]
					remaining_amount -= min(remaining_amount,max_amount)
				
				if remaining_amount == 0:
					return 0
	
	return remaining_amount

# content = [item_id, remove amount, properties]
func remove_item(inventory_id: String, content: Array, var remove_completely = false, var remove_interval = [0,0]) -> void:
	var remove_place = StorageData.storage_data[inventory_id]
	emit_signal("find_display", inventory_id)
	var item_id = content[0]
	
	var max_amount = ItemData.item_data[item_id]["max_amount"]
	var remaining_amount = max_amount if remove_completely else content[1]
	
	var remove_range = get_adding_range(remove_place,remove_interval)
	for slot_pos in remove_range:
		if item_id == remove_place[slot_pos][0] and hash(content[2]) == hash(remove_place[slot_pos][2]):
			var content_buffer = display.slots[slot_pos].content[1]
			display.slots[slot_pos].content[1] = max(0,display.slots[slot_pos].content[1] - remaining_amount)
			if not remove_completely:
				remaining_amount = max(0, remaining_amount - content_buffer) 
			
		if remaining_amount == 0 and not remove_completely:
			break

func get_adding_range(add_place: Array, adding_interval: Array) -> Array:
	var adding_step = 1
	
	if adding_interval[0] == -1:
		adding_interval[0] = len(add_place)-1
	elif adding_interval[1] == -1 or adding_interval[1] == 0:
		adding_interval[1] = len(add_place)
	
	if adding_interval[1] < adding_interval[0]:
		adding_step = -1
	
	return range(adding_interval[0],adding_interval[1],adding_step)

func collect_items(receiver: Node, receiver_inventory_id: String) -> void:
	
	emit_signal("find_display", receiver_inventory_id)
	
	var max_amount = ItemData.item_data[receiver.content[0]]["max_amount"]
	
	for slot in display.slots:
		if slot.content[0] == receiver.content[0] and hash(slot.content[2]) == hash(receiver.content[2]):
			swap_items(receiver, slot, "left")
			
			if receiver.content[1] == max_amount:
				break

func set_item(new_item_id: String, receiver_position_in_inventory: int, new_content: Array) -> void:
	emit_signal("find_display", new_item_id)
	
	display.slots[receiver_position_in_inventory].content = new_content.duplicate()

#receiver_1 in most cases is mouse slot
func swap_items(receiver_1: Node, receiver_2: Node,var button_pressed: String = "none"):
	var content_buffer
	
	match button_pressed:
		"left":
			if receiver_1.content[0] == receiver_2.content[0] and hash(receiver_1.content[2]) == hash(receiver_2.content[2]):
				var max_amount = ItemData.item_data[receiver_1.content[0]]["max_amount"]
				content_buffer = receiver_1.content[1]
				
				receiver_1.content[1] = min(max_amount,receiver_1.content[1] + receiver_2.content[1])
				receiver_2.content[1] = max(0, receiver_2.content[1] - max_amount + content_buffer)
				return
			
			return swap_items(receiver_1,receiver_2)
		"right":
			if receiver_1.content[0] == empty_slot_preset[0] and receiver_2.content[1] != 0:
				receiver_1.content = [receiver_2.content[0], 1, receiver_2.content[2]]
				receiver_2.content[1] -= 1
				return
			
			if receiver_2.content[0] == empty_slot_preset[0] and receiver_1.content[1] != 0:
				content_buffer = receiver_1.content.duplicate()
				receiver_1.content = [receiver_1.content[0],int(receiver_1.content[1]/2), receiver_1.content[2]]
				receiver_2.content = [content_buffer[0],content_buffer[1] - receiver_1.content[1], content_buffer[2]]
				return
			
			if receiver_1.content[0] == receiver_2.content[0] and hash(receiver_1.content[2]) == hash(receiver_2.content[2]):
				var max_amount = ItemData.item_data[receiver_1.content[0]]["max_amount"]
				if receiver_1.content[1] < max_amount:
					receiver_1.content[1] +=1
					receiver_2.content[1] -=1
				return
			
			return swap_items(receiver_1,receiver_2)
		_:
			if receiver_1.content[0] == empty_slot_preset[0]:
				var max_amount = ItemData.item_data[receiver_2.content[0]]["max_amount"]
				receiver_1.content = [receiver_2.content[0],min(max_amount,receiver_2.content[1]),receiver_2.content[2]]
				receiver_2.content[1] = max(0, receiver_2.content[1] - max_amount)
				return
			
			if receiver_2.content[0] == empty_slot_preset[0]:
				var max_amount = ItemData.item_data[receiver_1.content[0]]["max_amount"]
				receiver_2.content = [receiver_1.content[0],min(max_amount,receiver_1.content[1]),receiver_1.content[2]]
				receiver_1.content[1] = max(0, receiver_1.content[1] - max_amount)
				return
			
			content_buffer = receiver_1.content.duplicate()
			receiver_1.content = receiver_2.content
			receiver_2.content = content_buffer
			return

func open_inventory(opened: bool) -> void:
	inventory_is_open = opened
	
	emit_signal("inventory_opened", inventory_is_open)

func update_storage_slots_tags(slot: Node, type: int) -> void:
	match type:
		0:
			slot.item_tags_to_place = [default_item_tags_to_place[0].duplicate(),["storage"]]
			set_default_item_tags_to_take(slot)
		_:
			set_default_item_tags_to_place(slot)
			set_default_item_tags_to_take(slot)

func set_default_item_tags_to_place(slot: Node) -> void:
	slot.item_tags_to_place = default_item_tags_to_place.duplicate()

func set_default_item_tags_to_take(slot: Node) -> void:
	slot.item_tags_to_take = default_item_tags_to_take.duplicate()
