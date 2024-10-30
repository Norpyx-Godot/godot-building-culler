@tool
extends Node3D
class_name Building
## Building Culler allows you to manage the showing/hiding of upper levels of
## your 3D buildings when your character enters. This is useful for third-person
## games where the camera collisions make navigating interiors difficult.
## 
## Add a Building node to denote your building, and create BuildingLevel nodes
## inside of it for each level of your building. All objects inside on your
## BuildingLevel's will have their visibility, physics, and processing culled
## if the player enters a floor that is lower than the associated floor.
## [br][br]
## Don't forget to add a BuildingLevel for your roof, especially for
## single-story buildings, to cull the roof when the player enters.


## A unique name to identify this building. This is typically generated
## automatically using [ResourceUID], but it can be changed to something user
## friendly, as long as it remains completely unique.
@export var building_id: String

## When this target [Node3D] enters into a [BuildingLevel], levels above it will
## be hidden from the [Camera3D].
@export var player_target: Node3D

## Contains a list of all [BuildingLevel]s
var _building_levels: Array[BuildingLevel] = []

var _current_level = null
var _active_level_stack: Array = []

func _enter_tree() -> void:
	if !building_id:
		var uid = ResourceUID.create_id()
		building_id = ResourceUID.id_to_text(uid).substr(6)
	_discover_building_levels()
	_sort_levels()
	print("enter_tree ", building_id)

func _exit_tree() -> void:
	pass

func _ready():
	# Dynamically find all BuildingLevels
	_discover_building_levels()
	_sort_levels()

func _discover_building_levels():
	_building_levels.clear()
	for child in get_tree().get_nodes_in_group("BuildingLevel_" + building_id):
		if child is BuildingLevel:
			_building_levels.append(child)

# Sort levels by their Level property
func _sort_levels():
	_building_levels.sort_custom(func(a, b): return a.level - b.level)

func level_entered(target_level: BuildingLevel):
	if _active_level_stack.has(target_level):
		if _active_level_stack.front() == target_level: return
		var new_level_stack = _active_level_stack.filter(func(l): l != target_level)
		new_level_stack.push_front(target_level)
		_active_level_stack = new_level_stack
	else:
		_active_level_stack.push_front(target_level)
	
	_resolve_collision_stack()

func level_exited(target_level: BuildingLevel):
	if _active_level_stack.has(target_level):
		_active_level_stack = _active_level_stack.filter(func(l): return l != target_level)
	else: return
	
	_resolve_collision_stack()

func _resolve_collision_stack():
	if _active_level_stack.size() < 1:
		_restore_all_levels()
		return
	
	_active_level_stack.sort_custom(func(a, b): return a.level >= b.level)
	var _highest_level = _active_level_stack.front()
	_hide_levels_above_target(_highest_level.level)

## Hides, and disables physics and processing, or levels higher than the target
## level. This is used by BuildingLevel when the player walks into the building
## to make it easier for a 3rd person camera to view inside the building.
func _hide_levels_above_target(target: int):
	for level in _building_levels:
		if level.level > target:
			level.set_disabled(true)
		else:
			level.set_disabled(false)

func _restore_all_levels():
	if _active_level_stack.size() > 0: return
	
	for level in _building_levels:
		level.set_disabled(false)
