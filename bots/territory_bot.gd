extends BaseBot
class_name TerritoryBot

func evaluate_state(world_state, world):
	var score = 0
	var regions_owned = self.get_team_regions(world_state)
	if regions_owned.size() == 0:
		return -999
	score += regions_owned.size() * 100
	score += regions_owned.map(func(region): return region.tiles.size() * 10).reduce(func(a, b): return a + b, 0)
	score += regions_owned.map(func(region): return region.units).reduce(func(a, b): return a + b, 0)
	score -= regions_owned.filter(func(region): return is_region_landlocked(world, region.id))\
							.map(func(region): return region.units)\
							.reduce(func(a, b): return a + b, 0) * 10
	# var regions_not_owned = world_state.regions.values().filter(func(region): return region.team != self.team && region.team != Constants.NULL_TEAM)
	# var regions_not_owned_pos = regions_not_owned.map(func(region): return world.coords_to_pos(world.tiles[world.regions[region.id].data.tiles[0]].data.coords))
	# for r in regions_owned:
	# 	var pos = world.coords_to_pos(world.tiles[world.regions[r.id].data.tiles[0]].data.coords)
	# 	regions_not_owned_pos.sort_custom(func(a, b): return world.hex_distance(pos, a) - world.hex_distance(pos, b))
	# 	var closest = regions_not_owned_pos[0]
	# 	var dist = world.hex_distance(pos, closest) * r.units / 1000000.0
	# 	print("Closest ", closest, " to ", r, " is ", dist)
	#	score -= dist
	return score
		

func prune_tree(moves):
	var keep_n_moves = min(25, moves.size())
	var pruned_moves = {}
	var sorted_moves = moves.values().duplicate(true)
	sorted_moves.sort()
	for m in moves:
		if moves[m] >= sorted_moves[keep_n_moves-1]:
			pruned_moves[m] = moves[m]
		if pruned_moves.size() == keep_n_moves:
			break
	return pruned_moves

func sim_turn(sim_moves, world, world_sim):
	var possible_moves = sim_moves.duplicate(true)
	for sim_move in sim_moves:
		var world_state = world_sim.clone()
		for move in sim_move:
			world_state.simulate(move)
		var usable_regions = self.get_usable_regions(world_state)
		for region in usable_regions:
			var adjacent_regions = world.adjacent_regions(region.id)
			var test_adjacent_regions_for_realsies = adjacent_regions.filter(func(r): return !world_sim.regions[r].is_used)
			for move in self.get_region_moves(region.id, test_adjacent_regions_for_realsies):
				var clone_world = world_state.clone()
				clone_world.simulate(move)
				var all_moves = sim_move.duplicate(true)
				all_moves.append(move)
				possible_moves[all_moves] = evaluate_state(clone_world, world)
	# if possible_moves.size() == 0:
	# 	return sim_moves
	return possible_moves

func play_turn(world):
	print("Playing turn: ", Constants.TEAM_NAMES[self.team] )
	var world_sim = WorldState.new(world)
	var default_score = self.evaluate_state(world_sim, world)
	var possible_moves = {[]: default_score}
	for i in range(15):
		#print("Calculating possible moves (", i, ") , size: ", possible_moves.size())
		var new_moves = self.prune_tree(self.sim_turn(possible_moves, world, world_sim))
		if new_moves.keys() == possible_moves.keys():
			print("Stopping here ", i)
			break
		possible_moves = new_moves 

	print("Calculated possible moves", possible_moves.size())

	var best_move = [Action.new(self.team, Constants.Action.None)]
	var best_score = default_score
	for move in possible_moves.keys():
		if possible_moves[move] > best_score:
			best_move = move
			best_score = possible_moves[move]
	print("Best move", best_move, best_score)
	return best_move


func get_region_moves(region, adjacent_regions):
	# print("Getting moves for region ", region, " adjacent regions: ", adjacent_regions.size())
	var moves = []
	for adjacent_region in adjacent_regions:
		moves.append(Action.new(self.team, Constants.Action.Move, region, adjacent_region))
	#print("Moves for region ", region, ": ", moves)
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

func is_region_landlocked(world, region):
	var landlocked = true
	for neighbor in world.adjacent_regions(region):
		if world.regions[neighbor].data.team != self.team:
			landlocked = false
			break
	return landlocked
