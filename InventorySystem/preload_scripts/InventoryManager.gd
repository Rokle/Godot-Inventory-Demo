extends Node

# warning-ignore:unused_signal
signal inventory_opened(opened)
# warning-ignore:unused_signal
signal storage_set(storage)
# warning-ignore:unused_signal
signal storage_opened(state)
# warning-ignore:unused_signal
signal selection_changed(dir)

signal find_display(display_inventory_id)

var display

var mouse_slot
var selected_slot

var inventory_is_open = false setget open_inventory

# items_props contain [[obj who add, obj where added,[id, amount]]...]
func add_items(items_props:Array):
	for h in range(len(items_props)):
		items_props[h][0].adding_result(add_item(items_props[h][1],items_props[h][2]))

func add_item(inventory_id_of_place_where_add:String, content: Array, var use_hot_key : bool = false, var adding_interval: Array = [0,0]):
	var remaining_amount = content[1]
	var item_id = content[0]
	var add_place = StorageData.storage_data[inventory_id_of_place_where_add]
	var adding_step = 1
	if adding_interval[0] == -1:
		adding_interval[0] = len(add_place)-1
	elif adding_interval[1] == -1 or adding_interval[1] == 0:
		adding_interval[1] = len(add_place)
	if adding_interval[1] < adding_interval[0]:
		adding_step = -1
	emit_signal("find_display", inventory_id_of_place_where_add)
	var max_amount = ItemData.item_data[str(item_id)]["max_amount"]
	if max_amount != 1:
		for slot_pos in range (adding_interval[0],adding_interval[1],adding_step):
			if item_id == add_place[slot_pos][0] and content[2] == add_place[slot_pos][2] and (display.slots[slot_pos].can_inventory_add == true or use_hot_key == true):
				var con_holder = display.slots[slot_pos].content[1]
				display.slots[slot_pos].content = [display.slots[slot_pos].content[0],min(max_amount,display.slots[slot_pos].content[1] + remaining_amount), content[2]]
				remaining_amount = max(0, remaining_amount - max_amount + con_holder) 
			if remaining_amount == 0:
				return 0
	if remaining_amount > 0:
		for slot_pos in range (adding_interval[0],adding_interval[1],adding_step):
			if display.slots[slot_pos].content[0] == 0 and (display.slots[slot_pos].can_inventory_add == true or use_hot_key == true):
				display.slots[slot_pos].content = [item_id, min(remaining_amount,max_amount), content[2]]
				remaining_amount -= display.slots[slot_pos].content[1]
			if remaining_amount == 0:
				return 0
	return remaining_amount

func collect_items(inventory_id, collect_to):
	emit_signal("find_display", inventory_id)
	var max_amount = ItemData.item_data[str(collect_to.content[0])]["max_amount"]
	for slot in display.slots:
		if slot.content[0] == collect_to.content[0] and slot.content[2] == collect_to.content[2]:
			swap_items(collect_to, slot, "left")
			if collect_to.content[1] == max_amount:
				break

func set_item(where_add:Node,content:Array):
	if where_add != mouse_slot:
		return
	mouse_slot.content = content

#slot_1 in most cases is mouse slot
func swap_items(slot_1:Node, slot_2:Node,var button_pressed = "none"):
	var con_holder
	if button_pressed == "none":
		if slot_1.content[0] == 0:
			var max_amount = ItemData.item_data[str(slot_2.content[0])]["max_amount"]
			slot_1.content = [slot_2.content[0],min(max_amount,slot_2.content[1]),slot_2.content[2]]
			slot_2.content[1] = max(0, slot_2.content[1] - max_amount)
		elif slot_2.content[0] == 0:
			var max_amount = ItemData.item_data[str(slot_1.content[0])]["max_amount"]
			slot_2.content = [slot_1.content[0],min(max_amount,slot_1.content[1]),slot_1.content[2]]
			slot_1.content[1] = max(0, slot_1.content[1] - max_amount)
		else:
			con_holder = slot_1.content.duplicate()
			slot_1.content = slot_2.content
			slot_2.content = con_holder
	elif button_pressed == "left":
		if slot_1.content[0] == slot_2.content[0] and slot_1.content[2] == slot_2.content[2]:
			var max_amount = ItemData.item_data[str(slot_1.content[0])]["max_amount"]
			con_holder = slot_1.content[1]
			slot_1.content[1] = min(max_amount,slot_1.content[1] + slot_2.content[1])
			slot_2.content[1] = max(0, slot_2.content[1] - max_amount + con_holder)
		else:
			return swap_items(slot_1,slot_2)
	elif button_pressed == "right":
		if slot_1.content[0] == 0 and slot_2.content[1] != 0:
			slot_1.content = [slot_2.content[0], 1, slot_2.content[2]]
			slot_2.content[1] -= 1
		elif slot_2.content[0] == 0 and slot_1.content[1] != 0:
			con_holder = slot_1.content.duplicate()
			slot_1.content = [slot_1.content[0],int(slot_1.content[1]/2), slot_1.content[2]]
			slot_2.content = [con_holder[0],con_holder[1] - slot_1.content[1], con_holder[2]]
		elif slot_1.content[0] == slot_2.content[0] and slot_1.content[2] == slot_2.content[2]:
			var max_amount = ItemData.item_data[str(slot_1.content[0])]["max_amount"]
			if slot_1.content[1] < max_amount:
				slot_1.content[1] +=1
				slot_2.content[1] -=1
		else:
			return swap_items(slot_1,slot_2)
	achievements_handler(slot_1, slot_2)

func achievements_handler(slot1,slot2):
	if slot1.type == "equipment_slot":
		if slot1.content[0] == 106:
			AllThingMatterForDialogs.has_lucky_rune_equip = true
	elif slot2.type == "equipment_slot":
		if slot1.content[0] == 106:
			AllThingMatterForDialogs.has_lucky_rune_equip = true

func open_inventory(opened):
	inventory_is_open = opened
	emit_signal("inventory_opened", inventory_is_open)



