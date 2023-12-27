extends BaseBot
class_name TerritoryBot

func evaluate_state(world_state):
	var score = 0
	var regions_owned = self.get_team_regions(world_state)
	if regions_owned.size() == 0:
		return score
	score += regions_owned.size() * 10
	score += regions_owned.map(func(region): return region.tiles.size() * 5).reduce(func(a, b): return a + b)
	score += regions_owned.map(func(region): return region.units).reduce(func(a, b): return a + b)
	return score

func play_turn(world):
	var world_sim = WorldState.new(world)
	var usable_regions = self.get_usable_regions(world_sim)
	var possible_moves = {}
	var default_score = self.evaluate_state(world_sim)
	#print("Usable regions", usable_regions)
	for region in usable_regions:
		var adjacent_regions = world.adjacent_regions(region.id)
		#print("Adjacent regions", adjacent_regions)
		for move in self.get_region_moves(region.id, adjacent_regions):
			var clone_world = world_sim.clone()
			clone_world.simulate(move)
			possible_moves[move] = self.evaluate_state(clone_world)
	#print("Calculated possible moves", possible_moves.size())
	
	var best_move = Action.new(self.team, Constants.Action.None)
	var best_score = default_score
	for move in possible_moves.keys():
		#print("Move: ", move, " Score: ",possible_moves[move])
		if possible_moves[move] > best_score:
			print("New best move: ", move, " Score: ", possible_moves[move])
			best_move = move
			best_score = possible_moves[move]
	print("Best move", best_move, best_score)
	return best_move


func get_region_moves(region, adjacent_regions):
	print("Getting moves for region ", region)
	var moves = []
	for adjacent_region in adjacent_regions:
		moves.append(Action.new(self.team, Constants.Action.Move, region, adjacent_region))
	print("Moves for region ", region, ": ", moves)
	return moves

func get_team_regions(world_state):
	var regions = []
	for region in world_state.regions.values():
		if region.team == self.team:
			regions.append(region)
	return regions

func is_usable_region(region):
	return region.units > 1 && !region.is_used && region.team == self.team

func get_usable_regions(world_state):
	return get_team_regions(world_state).filter(func(region): return is_usable_region(region))

