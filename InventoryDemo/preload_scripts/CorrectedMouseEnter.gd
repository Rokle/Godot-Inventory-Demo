extends Node


var slots = [] setget set_slot #[slot, rect, visible]

var current_slot = null

func set_slot(slot_prop):
	slots.append(slot_prop)

func _check_visibility(mouse_pos):
	for i in range(len(slots)-1, -1, -1):
		if slots[i][0] == null:
			slots.remove(i)
			continue
		slots[i][2] = slots[i][0].get_parent().visible
		if slots[i][0].type == "disabled":
			slots[i][2] = false
		if slots[i][2] == false and slots[i][0] == current_slot:
			current_slot._mouse_exited()
			current_slot = null
	if current_slot != null:
		current_slot._mouse_entered()
		return
	is_mouse_enter_slot(mouse_pos)

func is_mouse_enter_slot(pos):
	for i in range(len(slots)-1, -1, -1):
		if slots[i][0] == null:
			slots.remove(i)
			continue
		if slots[i][2] == false:
			continue
		if slots[i][1].has_point(pos):
			if current_slot != slots[i][0]:
				if current_slot != null:
					current_slot._mouse_exited()
				current_slot = slots[i][0]
				current_slot._mouse_entered()
			return
	if current_slot != null:
		current_slot._mouse_exited()
	current_slot = null
