@tool
extends CollisionShape3D
class_name BuildingLevelCollider

## Denotes the [BuildingLevel] associated with this [BuildingLevelCollider]
@export var parent_level: BuildingLevel
## Denotes the [Building] associated with this [BuildingLevelCollider]
@export var parent_building: Building

func _enter_tree() -> void:
	parent_level = _find_parent_level()
	parent_building = _find_parent_building()
func _exit_tree() -> void:
	pass
func _ready() -> void:
	pass
func _process(delta: float) -> void:
	pass

## Returns the [BuildingLevel] node associated with this [BuildingLevelCollider]
func get_parent_level() -> BuildingLevel:
	if parent_level: return parent_level
	parent_level = _find_parent_level()
	return parent_level

# Helper function to find the parent BuildingLevel node
func _find_parent_level() -> BuildingLevel:
	var current = self
	while current:
		current = current.get_parent()
		if current is BuildingLevel:
			return current
	return null

## Returns the [Building] node associated with this [BuildingLevelCollider]
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
