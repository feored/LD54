extends Node

const TILE_SIZE = 24
const WORLD_CENTER = Vector2i(512 / 24 / 2, 288 / 24 / 2)
const WORLD_BOUNDS = Vector2i(20, 15)

const TILE_GRASS = 1
const TILE_WATER = 0

const LAYER_WATER = 0
const LAYER_GRASS = 1
const LAYER_P1 = 2
const LAYER_P2 = 3
const LAYER_P3 = 4

const NO_TEAM = 0
const TEAM_COLORS = [0xffffffff, 0xff776eff, 0x6effff, 0xfdff6eff]
