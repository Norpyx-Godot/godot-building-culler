@tool
extends Area3D
class_name BuildingLevel

var BuildingLevelCollider = preload("./building_level_collider.gd")

## Denotes what level of the building this [BuildingLevel] represents. This
## property determines the order in which the floors are shown/hidden.
@export var level: int = 0  # Denotes what level of the building this is

## A useful property for tracking the colliders associated with the level.
@export var level_colliders: Array[BuildingLevelCollider] = []

## A useful property for associating the collider with the parent building
@export var parent_building: Building

## A useful property for tracking the interior of the level
@export var level_interior: BuildingLevelInterior

var prev_visibility: bool
var prev_phys_interp: PhysicsInterpolationMode
var prev_proc_mode: ProcessMode

var disabled = false

func _ready():
	# Automatically add to BuildingLevel group for dynamic discovery
	add_to_group("BuildingLevel_" + get_parent_building().building_id)
	connect("body_entered", _on_player_entered)
	connect("body_exited", _on_player_exited)

## Returns whether or not the [BuildingLevel] is currently disabled
func is_disabled() -> bool:
	return disabled

## Hides and disables the physics interpolation and process mode for this
## [BuildingLevel] and its children.
func set_disabled(newval: bool) -> void:
	if disabled == newval:
		return
	
	disabled = newval
	
	var interior = get_level_interior()
	
	if disabled:
		prev_visibility = interior.visible
		prev_phys_interp = interior.physics_interpolation_mode
		prev_proc_mode = interior.process_mode
		interior.visible = false
		interior.physics_interpolation_mode = PHYSICS_INTERPOLATION_MODE_OFF
		interior.process_mode = PROCESS_MODE_DISABLED
	else:
		interior.visible = prev_visibility
		interior.physics_interpolation_mode = prev_phys_interp
		interior.process_mode = prev_proc_mode

func _enter_tree() -> void:
	parent_building = _find_parent_building()
	level_colliders = _find_level_colliders()
	level = _assume_level_number()
func _exit_tree() -> void:
	pass

func _assume_level_number() -> float:
	if level > 0: return level;
	
	var parent = get_parent_building()
	var levels = parent.find_children("*", "BuildingLevel", true, false) as Array[BuildingLevel]
	
	var highest_level = 0
	for current in levels:
		if current.level > highest_level:
			highest_level = current.level
	
	return highest_level + 1

# Called when the player enters the collider
func _on_player_entered(body: Node3D):
	var building = get_parent_building()
	if !building: return
	if body != building.player_target: return
	building.level_entered(self)

# Called when the player exits the collider
func _on_player_exited(body: Node3D):
	var building = get_parent_building()
	if !building: return
	if body != building.player_target: return
	building.level_exited(self)

## Returns the parent Building of this BuildingLevel
func get_parent_building() -> Building:
	if parent_building: return parent_building
	parent_building = _find_parent_building()
	return parent_building

# Helper function to find the parent Building node
func _find_parent_building() -> Building:
	var current = self
	while current:
		current = current.get_parent()
		if current is Building:
			return current
	return null

## Returns all [BuildingLevelCollider]s associated with this [BuildingLevel]
func get_level_colliders() -> Array[BuildingLevelCollider]:
	if level_colliders: return level_colliders
	level_colliders = _find_level_colliders()
	return level_colliders

func _find_level_colliders() -> Array[BuildingLevelCollider]:
	var children = find_children("*", "BuildingLevelCollider", true, false)
	var ret: Array[BuildingLevelCollider]
	for child in children:
		if child is BuildingLevelCollider:
			ret.append(child)
	return ret

## Returns the [BuildingLevelInterior]s associated with this [BuildingLevel]
func get_level_interior() -> BuildingLevelInterior:
	if level_interior: return level_interior
	level_interior = _find_level_interior()
	return level_interior

func _find_level_interior() -> BuildingLevelInterior:
	return find_children("*", "BuildingLevelInterior", true, false)[0]
