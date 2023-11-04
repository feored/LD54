extends Node

## World constants
const TILE_SIZE = 24
const WORLD_CENTER = Vector2i(512 / 24 / 2, 288 / 24 / 2)
const WORLD_BOUNDS = Vector2i(15, 15)
const WORLD_CAMERA_BOUNDS = Vector2i(40, 25)
const NEIGHBORS = [
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE
]

const NO_BORDERS = {
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE: false,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE: false,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE: false,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE: false,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE: false,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE: false
}

## Game constants
const PLAYER_ID = 1
const REGION_MAX_SIZE = 6
const SINK_GRACE_PERIOD = 1
const MIN_TEAMS = 2  ## including player
const MAX_TEAMS = 7
const BLENDING_MODULATE_ALPHA = 0.6
const CAMERA_SPEED = 5
const ISLAND_SIZE_DEFAULT = 0.25
const ISLAND_SIZE_MIN = 0.1
const ISLAND_SIZE_MAX = 0.5
const GOLD_PER_TURN_PER_REGION = 1
const SACRIFICE_SHAPES = 3
const SHAPE_REROLL_COST = 1

## Null values
const NULL_COORDS = Vector2i(-9999, -9999)
const NULL_POS = Vector2(-9999, -9999)
const NULL_REGION = -9999
const NULL_TEAM = 0

## Game enums
enum GameMode { Play, MapEditor, Scenario }
enum Action { None, Move, Sacrifice }
enum Item { Production, ShapeCost, ShapeReroll, ShapeCapacity }

## Teams
const TEAM_COLORS = [
	0xffffffff,  # no team
	0x4768fdff,  # blue
	0xf78000ff,  # orange
	0xed79b0ff,  # pink
	0xffea00ff,  # yellow
	0xff0000ff,  # red
	0x0bfc03ff,  # green
	0x393939ff,  # grey
]

const TEAM_BORDER_COLORS = [
	0x000000ff,  # no team
	0x0000ffff,  # blue
	0xffa500ff,  # orange
	0xff69b4ff,  # pink
	0xffff00ff,  # yellow
	0xff0000ff,  # red
	0x00ff00ff,  # green
	0x808080ff,  # grey
]

const TEAM_NAMES = [
	"Neutral",
	"Blue Country",
	"Orange Kingdom",
	"Pink Empire",
	"Yellow Protectorate",
	"Red Republic",
	"Green Federation",
	"Grey Coalition"
]

## Timers
const TURN_TIME = 0.3
const MENU_WAIT_TIME = 1

## Items:
const ITEMS = {
	Item.Production:
	{
		"id": Item.Production,
		"cost": 5,
		"texture": preload("res://assets/icons/person.png"),
		"tooltip":
		"Increases the unit generation of the territory this item was placed on by 1 per turn.",
	},
	Item.ShapeCost:
	{
		"id": Item.ShapeCost,
		"cost": 5,
		"texture": preload("res://assets/icons/down_arrow.png"),
		"tooltip": "Reduces the cost of every shape in the fervor tab by 1.",
	},
	Item.ShapeReroll:
	{
		"id": Item.ShapeReroll,
		"cost": 5,
		"texture": preload("res://assets/icons/redo.png"),
		"tooltip": "Reroll all the shapes in the fervor tab.",
	},
	Item.ShapeCapacity:
	{
		"id": Item.ShapeCapacity,
		"cost": 5,
		"texture": preload("res://assets/icons/plus.png"),
		"tooltip": "Increases the number of available shapes by 1.",
	},
}

const DEFAULT_ITEMS = [Item.Production, Item.ShapeCost, Item.ShapeReroll, Item.ShapeCapacity]

## Scenarios
const scenarios = [
	{
		"title": "Humble Beginnings",
		"description": "Neptune means to teach you that you must sink or be sunk.",
		"path": "cross.json"
	},
	{
		"title": "The Trident",
		"description":
		"Neptune wants to test your ability to conquer an island with a single chokepoint.",
		"path": "trident.json"
	},
	{
		"title": "Not Poseidon",
		"description": "Neptune wants you to conquer a land dear to him.",
		"path": "italy.json"
	},
	{"title": "The Loop", "description": "All paths lead to Rome.", "path": "loop.json"},
	{
		"title": "A Tale of Two Cities",
		"description": "A fragile bridge connects two prosperous lands.",
		"path": "two_halves.json"
	},
	{
		"title": "Stars Align",
		"description": "This land must have been shaped by the gods.",
		"path": "sort_of_a_star.json"
	},
	{"title": "Pacman", "description": "Uh...Neptune's favorite game?", "path": "pacman.json"},
	{
		"title": "4 Islands",
		"description": "An isolated empire is doomed to decay",
		"path": "4_islands.json"
	}
]
