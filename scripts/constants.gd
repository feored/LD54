extends Node

## World constants
const VIEWPORT_SIZE = Vector2(960, 540)
const TILE_SIZE = 24
const WORLD_CENTER = Vector2i(0, 0)  #Vector2i(VIEWPORT_SIZE.x / TILE_SIZE / 2, VIEWPORT_SIZE.y / TILE_SIZE / 2)
const CAMERA_CENTER = -VIEWPORT_SIZE / 2
const WORLD_BOUNDS = Vector2i(15, 15)
const WORLD_CAMERA_BOUNDS = Vector2i(80, 45)
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

const USER_MAPS_PATH = "user://maps/"

## Game constants
const PLAYER_ID = 1
const REGION_MAX_SIZE = 6
const SINK_GRACE_PERIOD = 1
const MIN_TEAMS = 2  ## including player
const MAX_TEAMS = 10
const BLENDING_MODULATE_ALPHA = 0.6
const CAMERA_SPEED = 5
const ISLAND_SIZE_DEFAULT = 0.25
const ISLAND_SIZE_MIN = 0.1
const ISLAND_SIZE_MAX = 0.5
const SACRIFICE_SHAPES = 3
const SHAPE_REROLL_COST = 1
const HOVER_TIME_BEFORE_POPUP = 0.5
const TEMPLE_FAITH_PER_TURN = 5
const MINE_GOLD_PER_TURN = 2
const CASTLE_UNITS_REMOVED = 10
const BARRACKS_UNITS_PER_TURN = 3
const DEFAULT_FAITH = 0
const DEFAULT_DECK_SIZE = 5

## Null values
const NULL_COORDS = Vector2i(-9999, -9999)
const NULL_POS = Vector2(-9999, -9999)
const NULL_REGION = -9999
const NULL_TEAM = 0
const NULL_BUILDING = -9999
const NULL_PATH_LENGTH = 9999

## Debug utilities
const DEBUG_POSITION = false
const DEBUG_REGION = false

## Game enums
enum GameMode { Play, MapEditor, Scenario }
enum Event { None, Move, Attack, Build, Sacrifice, EndTurn, DrawCard, PlayCard, Discard }

## Teams
const TEAM_COLORS = [
	0xffffffff,  # no team
	0x0056b5ff,  # blue
	0xf0a818ff,  # orange
	0xed79b0ff,  # pink
	0xffea00ff,  # yellow
	0xc91e1eff,  # red
	0x09b030ff,  # green
	0x393939ff,  # grey
	0xa103fcff,  # purple
	0x03e3fcff,  # cyan
	0xc2fc03ff,  # lime
]

const TEAM_BORDER_COLORS = [
	0x000000ff,  # no team
	0x147ff7ff,  # blue
	0xffa500ff,  # orange
	0xff69b4ff,  # pink
	0xffff00ff,  # yellow
	0xff0000ff,  # red
	0x00ff00ff,  # green
	0x1a1919ff,  # grey
	0x800080ff,  # purple
	0x00b0b0ff,  # cyan
	0x63cc00ff,  # lime
]

const TEAM_NAMES = [
	"Neutral",
	"Blue Country",
	"Orange Kingdom",
	"Pink Empire",
	"Yellow Protectorate",
	"Red Republic",
	"Green Federation",
	"Grey Coalition",
	"Purple Commonwealth",
	"Cyan Union",
	"Lime Dominion",
]

## Timers
const TURN_TIME = 0.3
const MENU_WAIT_TIME = 1

## Buildings
enum Building { None, Barracks, Temple, Fort, Oracle, Seal }

const BUILDINGS = {
	Building.Barracks:
	{
		"id": Building.Barracks,
		"name": "Barracks",
		"texture": preload("res://assets/icons/sword.png"),
		"tooltip": "This territory will generate +%s unit per turn." % BARRACKS_UNITS_PER_TURN,
	},
	Building.Temple:
	{
		"id": Building.Temple,
		"name": "Temple",
		"texture": preload("res://assets/icons/temple.png"),
		"tooltip": "This territory will generate +%s faith per turn." % TEMPLE_FAITH_PER_TURN,
	},
	Building.Fort:
	{
		"id": Building.Fort,
		"name": "Fort",
		"texture": preload("res://assets/icons/castle.png"),
		"tooltip":
		"Enemies invading this territory lose %s units instantly." % CASTLE_UNITS_REMOVED,
	},
	Building.Oracle:
	{
		"id": Building.Oracle,
		"name": "Oracle",
		"texture": preload("res://assets/icons/card.png"),
		"tooltip": "This territory will generate one power every turn.",
	},
	Building.Seal:
	{
		"id": Building.Seal,
		"name": "Seal",
		"texture": preload("res://assets/icons/seal.png"),
		"tooltip":
		"If this territory is marked by Neptune, it will resist sinking. The seal will be destroyed.",
	},
}

## Scenarios
const scenarios = [
	{"title": "Confrontation", "description": "One on one.", "path": "confrontation.json"},
	# {"title": "Flower", "description": "The Flower", "path": "flower.json"},
	{"title": "The Blob", "description": "All paths lead into the blob.", "path": "blob.json"},
	# {"title": "The Wheel", "description": "wheel", "path": "wheel.json"},
	{"title": "Triangles", "description": "Triangles", "path": "triangles.json"},
	{
		"title": "The Fortress",
		"description":
		"You are outnumbered, surrounded by powerful enemies. Only by the grace of the gods may you survive this trial.",
		"path": "fortress.json"
	},
	{
		"title": "The Pretzel",
		"description": "A free for all, but every kingdom starts with an established base.",
		"path": "homebase.json"
	},
	{"title": "Rings", "description": "Ring around the rosie", "path": "rings.json"},
	{
		"title": "Triforce",
		"description": "Power is concentrated and all vye for it.",
		"path": "triforce.json"
	},
	{
		"title": "Tarp",
		"description":
		"This is a land of borg, worm, and love for nergkun. Isn't this a hidden map?",
		"path": "tarp.json"
	},
	{"title": "Santa", "description": "This is a hidden map. Go away.", "path": "santa.json"}
]
