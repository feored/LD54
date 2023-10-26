extends Node

## World constants
const TILE_SIZE = 96
const WORLD_CENTER = Vector2i(2560 / TILE_SIZE / 2, 1440 / TILE_SIZE / 2)
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
const REGION_MAX_SIZE = 6
const SINK_GRACE_PERIOD = 1
const MIN_TEAMS = 2  ## including player
const MAX_TEAMS = 7
const BLENDING_MODULATE_ALPHA = 0.6
const CAMERA_SPEED = 5
const ISLAND_SIZE_DEFAULT = 0.25
const ISLAND_SIZE_MIN = 0.1
const ISLAND_SIZE_MAX = 0.5
const SHAPE_TICKER_NUM = 4

## Null values
const NULL_COORDS = Vector2i(-9999, -9999)
const NULL_POS = Vector2(-9999, -9999)
const NULL_REGION = -9999
const NULL_TEAM = 0

## Game enums
enum GameMode { Play, MapEditor, Scenario }
enum Action { None, Move, Sacrifice }

## Teams
const TEAM_COLORS = [
	0xffffffff,  # no team
	0x002ac2ff,  # blue
	0xf78000ff,  # orange
	0xfc03dbff,  # pink
	0xffea00ff,  # yellow
	0xff0000ff,  # red
	0x0bfc03ff,  # green
	0x393939ff,  # grey
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
