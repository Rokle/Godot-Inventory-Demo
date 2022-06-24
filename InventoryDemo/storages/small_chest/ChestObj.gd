extends AnimatedSprite

# warning-ignore:unused_class_variable
var sprite_type = 'test'
var can_open = false
var opened = false setget open_chest
var player
var storage_type = 1
var mouse_interaction_tag = "storage"
var texture
var interaction_rect

export(String) var inventory_id

func _ready():
	interaction_rect = $MouseEnterZone.get_rect()
	_area_entered(Links.player)
	set_sprite_frames(load('res://storages/small_chest/sprites/%sSprFrames.tres' % sprite_type))
	play("Close")
	texture = load('res://storages/small_chest/sprites/%s_close.png' % sprite_type)
	#set_process_input(false)


func open_chest(state):
	if InventoryManager.current_storage == self:
		opened = state
		play("Open" if opened else "Close")

func _area_entered(_player):
	can_open = true
	player = _player
	
	if interaction_rect.has_point(get_local_mouse_position()) == true:
		InventoryManager.mouse_slot.hovered_object = self
		InventoryManager.mouse_slot.hovered_object_texture(texture)
	
	set_process_input(true)

func _area_exited():
	can_open = false
	if InventoryManager.current_storage == self:
		InventoryManager.emit_signal("storage_set",self,storage_type)
	
	if InventoryManager.mouse_slot.hovered_object == self:
		InventoryManager.mouse_slot.hovered_object_texture(null)
	
	set_process_input(false)


func _input(_event):
	if player == null:
		return
	
	if interaction_rect.has_point(get_local_mouse_position()) == true and CorrectedMouseEnter.current_slot == null:
		InventoryManager.mouse_slot.hovered_object = self
		InventoryManager.mouse_slot.hovered_object_texture(texture)
		if InventoryManager.mouse_slot.button_pressed == "right" and Input.is_action_just_pressed("RightClick"):
			if InventoryManager.mouse_slot.click_used == false:
				InventoryManager.mouse_slot.click_used = true
				InventoryManager.emit_signal("storage_set",self,storage_type)
				player.open_storage(not opened)
		return
	
	if InventoryManager.mouse_slot.hovered_object == self:
		InventoryManager.mouse_slot.hovered_object_texture(null)





