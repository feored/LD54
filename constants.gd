extends Node

const NULL_COORDS = Vector2i(-9999, -9999)
const NULL_POS = Vector2(-9999, -9999)
const TILE_SIZE = 24
const WORLD_CENTER = Vector2i(512 / 24 / 2, 288 / 24 / 2)
const WORLD_BOUNDS = Vector2i(15, 10)
const WORLD_CAMERA_BOUNDS = Vector2i(35, 25)

const TILE_GRASS = 1
const TILE_WATER = 0

const BLENDING_MODULATE_ALPHA = 0.6

enum Layer { WATER, GRASS, P1, P2, P3 }

const NO_TEAM = 0
const REGION_MAX_SIZE = 6
const TEAM_COLORS = [
	0xffffffff,  # no team
	0x180fbdff,  # blue
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

enum GameMode { Play, MapEditor, Scenario }

enum Highlight { Red, Green, None }

const TURN_TIME = 0.2
const MENU_WAIT_TIME = 1

const MIN_TEAMS = 2  ## including player
const MAX_TEAMS = 7

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

const FULL_BORDERS = {
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE: true,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE: true,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE: true,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE: true,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE: true,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE: true
}

const NO_REGION = -99

enum Action { NONE, MOVE, SACRIFICE }

const SINK_GRACE_PERIOD = 1

const scenarios = [
	{
		"title": "Humble Beginnings",
		"description": "Neptune means to teach you that you must sink or be sank.",
		"path": "cross.json"
	},
	{
		"title": "Stars Align",
		"description": "This land must have been shaped by the gods.",
		"path": "sort_of_a_star.json"
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
	}
]
