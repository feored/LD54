extends Node

const TILE_SIZE = 24
const WORLD_CENTER = Vector2i(512 / 24 / 2, 288 / 24 / 2)
const WORLD_BOUNDS = Vector2i(15, 10)
const WORLD_CAMERA_BOUNDS = Vector2i(25, 20)

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
	0x696969ff,  # grey
]

const TURN_TIME = 0.25

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

enum Action { NONE, MOVE }
