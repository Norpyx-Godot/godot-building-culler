# Building Culler Godot Addon

Building Culler allows you to manage the showing/hiding of upper levels of
your 3D buildings when your character enters. This is useful for third-person
games where the camera collisions make navigating interiors difficult.

Add a Building node to denote your building, and create BuildingLevel nodes
inside of it for each level of your building. All objects inside on your
BuildingLevel's will have their visibility, physics, and processing culled
if the player enters a floor that is lower than the associated floor.

Don't forget to add a BuildingLevel for your roof, especially for
single-story buildings, to cull the roof when the player enters.

## Installation

Download the release zip file from the releases page and extract it into your
Godot project's addons folder. Enable the plugin in your project settings.

## Getting Started

### Nodes

There are four different nodes that you can use to manage your building:

1. **Building**: The root node for your building. This node should be placed
   at the origin of your building and should contain all of the BuildingLevel
   nodes.
2. **BuildingLevel**: A node that represents a level of your building. This
   keeps track of the objects that should be culled when the player enters a
   different level.
3. **BuildingLevelCollider**: A node that represents the collision shape of your
   building level. This is used to determine when the player has entered the
   building level.
4. **BuildingLevelInterior**: A node that represents the interior of your
   building. This node should contain all of the objects on this level of the
   building. Everything inside of this node will be culled when the player
   enters a lower level.

#### Building `Node3D`

The Building node is the root node for your building. This node should be
placed at the origin of your building and should contain all of the BuildingLevel
nodes.

##### Properties

- **building_id** `String`: The unique identifier for this building. This is used to
  determine which building the player is currently inside of.

- **player_target** `Node3D`: The player node that will be used to determine if
  the player has entered the building.

#### BuildingLevel `Area3D`

The BuildingLevel node represents a level of your building. This node should
contain all of the objects that should be culled when the player enters a
different level.

> [!TIP]
> A Building can have as many BuildingLevel nodes as you need to represent the
  different levels of your building.

> [!TIP]
> `BuildingLevel`s can have multiple BuildingLevelColliders to
  represent different areas of the level.

> [!WARNING]
> A `BuildingLevel` can have only one `BuildingLevelInterior` node.

##### Properties

- **level** `float`: The level of the building that this node represents. This
  property determines the order in which the levels are culled. If the player
  is on a level that is lower than this level, the objects inside of this node
  will be culled.

- **parent_building** `Building`: The Building node that this BuildingLevel
  belongs to. If this property is not set, the plugin will attempt to find the
  parent building node.

- **level_interior** `BuildingLevelInterior`: The BuildingInterior node that
  represents the interior of this level. If this property is not set, the
  plugin will attempt to find the child BuildingInterior node.


#### BuildingLevelCollider `CollisionShape3D`

The BuildingLevelCollider node represents the collision shape of your building
level. This is used to determine when the player has entered the building level.

> [!TIP]
> A BuildingLevel can have multiple BuildingLevelColliders to represent different
areas of the level.

##### Properties

- **parent_level** `BuildingLevel`: The BuildingLevel node that this BuildingLevelCollider
  belongs to. If this property is not set, the plugin will attempt to find the
  parent BuildingLevel node.

- **parent_building** `Building`: The Building node that this BuildingLevelCollider
  belongs to. If this property is not set, the plugin will attempt to find the
  parent building node.

#### BuildingLevelInterior `Node3D`

The BuildingLevelInterior node represents the interior of your building. This
node should contain all of the objects on this level of the building. Everything
inside of this node will be culled when the player enters a lower level.

> [!TIP]
> Make sure to include the floor and walls of the building in the
> BuildingLevelInterior node to ensure that they're culled properly.

> [!TIP]
> If the ceiling of the level below is a unique node, make sure to include
> it in the BuildingLevelInterior node of the level above.

> [!WARNING]
> A BuildingLevel can have only one BuildingLevelInterior node.

### Example

Let's explore an example of how you might set up a building with two levels.
Don't forget to add a BuildingLevel for your roof, especially for single-story
buildings, to cull the roof when the player enters.

```
Building
├── BuildingLevel (level: 0)
│   ├── BuildingLevelCollider
│   ├── BuildingLevelCollider (optional)
│   └── BuildingLevelInterior
│       ├── MeshInstance (likely the ground)
│       ├── MeshInstance (likely a wall)
│       ├── MeshInstance (likely some stairs)
│       └── MeshInstance (maybe a door)
├── BuildingLevel (level: 1)
│   ├── BuildingLevelCollider
│   └── BuildingLevelInterior
│       ├── MeshInstance
│       ├── MeshInstance
│       └── MeshInstance
└── BuildingLevel (level: 2) (roof)
    ├── BuildingLevelCollider
    └── BuildingLevelInterior
        └── MeshInstance
```

In this example, we have a Building node that contains three BuildingLevel
nodes. The first BuildingLevel node represents the ground floor of the building,
the second BuildingLevel node represents the first floor, and the third
BuildingLevel node represents the roof.

Each BuildingLevel node contains a BuildingLevelCollider node that represents
the collision shape of the level. The BuildingLevel node also contains a
BuildingLevelInterior node that represents the interior of the level.

The BuildingLevelInterior node contains the objects that should be culled when
the player enters a lower level. In this example, the ground floor contains
four MeshInstance nodes, the first floor contains three MeshInstance nodes,
and the roof contains one MeshInstance node.


