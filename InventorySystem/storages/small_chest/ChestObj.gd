extends AnimatedSprite

# warning-ignore:unused_class_variable
var sprite_type = 'test'
#for show can_open = true
var can_open = true
var opened = false setget open_chest
export(NodePath) var player
var storage_type = 'small_chest'
var ui_type = 'SmallChestDisplay'
var texture
var interaction_rect

export(String) var inventory_id

func _ready():
	player = get_node(player)
	set_sprite_frames(load('res://storages/%s/sprites/%sSprFrames.tres' % [storage_type,sprite_type]))
	play("Close")
	texture = load('res://storages/%s/sprites/%s_close.png' % [storage_type,sprite_type])
	interaction_rect = $MouseEnterZone.get_rect()
	#for show input = true
	#set_process_input(false)


func open_chest(state):
	opened = state
	if opened == true:
		play("Open")
	else:
		play("Close")

#add in player area
func _on_area_entered(area):
	if area.name == "InteractionZone":
		can_open = true
		player = area.get_parent()
		if interaction_rect.has_point(get_local_mouse_position()) == true:
			InventoryManager.mouse_slot.storage = self
			InventoryManager.mouse_slot.storage_texture(texture)
		set_process_input(true)

#add in player area
func _on_area_exited(area):
	if area.name == "InteractionZone":
		can_open = false
		open_chest(false)
		if InventoryManager.mouse_slot.storage == self:
			InventoryManager.mouse_slot.storage_texture(null)
		InventoryManager.emit_signal("storage_set",self)
		set_process_input(false)


func _input(event):
	#if player != null:
	if true == true:
		if interaction_rect.has_point(get_local_mouse_position()) == true:
			InventoryManager.mouse_slot.storage_texture(texture)
			InventoryManager.mouse_slot.storage = self
			if InventoryManager.mouse_slot.click_used == false:
				if InventoryManager.mouse_slot.button_pressed == "right":
					InventoryManager.mouse_slot.click_used = true
					open_chest(not opened)
					InventoryManager.emit_signal("storage_set",self)
					player.open_storage(opened)
			return
		if InventoryManager.mouse_slot.storage == self and InventoryManager.mouse_slot.storage_sprite.texture == texture:
			InventoryManager.mouse_slot.storage_texture(null)





