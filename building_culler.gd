@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("Building", "Node3D", preload("./nodes/building.gd"), preload("./assets/icon-building.svg"))
	add_custom_type("BuildingLevel", "Area3D", preload("./nodes/building_level.gd"), preload("./assets/icon-building-level.svg"))
	add_custom_type("BuildingLevelCollider", "CollisionShape3D", preload("./nodes/building_level_collider.gd"), preload("./assets/icon-building-level-collider.svg"))
	add_custom_type("BuildingLevelInterior", "Node3D", preload("./nodes/building_level_interior.gd"), preload("./assets/icon-building-level.svg"))

func _exit_tree() -> void:
	remove_custom_type("Building")
	remove_custom_type("BuildingLevel")
	remove_custom_type("BuildingLevelCollider")
	remove_custom_type("BuildingLevelInterior")
