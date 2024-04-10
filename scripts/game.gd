extends RefCounted
class_name Game

var turn: int = 0
var global_turn: int = 0
var players: Array = []
var current_player: Player
var human : Player
var started = false
var actions_history : Array[Action] = []

const PLAYER_TEAM = 1


func _init(teams):
	for team in teams:
		var player = Player.new()
		player.team = team
		player.is_bot = team != PLAYER_TEAM
		players.append(player)
		if team == PLAYER_TEAM:
			current_player = player
			human = player
		else:
			player.bot = TerritoryBot.new(team, Personalities.AGGRESSIVE_PERSONALITY)

func get_random_enemy():
	return self.players.filter(func(p): return p.team != self.current_player.team).pick_random()

func next_turn():
	global_turn += 1
	turn = 1
	current_player = players[turn]
	Effects.trigger(Effect.Trigger.GlobalTurnOver)

func next_player():
	turn = (turn + 1) % players.size()
	current_player = players[turn]
	Effects.trigger(Effect.Trigger.TurnOver)

func get_current_player():
	return self.current_player

func player_from_team(team):
	for player in players:
		if player.team == team:
			return player
	return null