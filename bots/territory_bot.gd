class_name TerritoryBot extends BaseBot

func evaluate_state(world_state, world):
	var score = 0
	var regions_owned = self.get_team_regions(world_state)
	if regions_owned.size() == 0:
		return -999
	# ADD BACK THIS
	for rt in world_state.team_regions:
		if rt != self.team and world_state.team_regions[rt] == 0:
			score += (1.0/world_state.team_regions.size()) * self.personality.teams_alive
	var n_regions = world.regions.size()
	var n_tiles = world.tiles.size()
	var bonus_regions_owned = regions_owned.size() / float(n_regions)
	#Utils.log("Bonus regions owned: ", bonus_regions_owned)
	score += bonus_regions_owned * self.personality.regions
	var bonus_tiles_owned = regions_owned.map(func(region): return region.tiles.size()).reduce(func(a, b): return a + b, 0) / float(n_tiles)
	#Utils.log("Bonus tiles owned: ", bonus_tiles_owned)
	score += bonus_tiles_owned * self.personality.tiles
	# either total units in map or delete
	var bonus_units_owned = regions_owned.map(func(region): return region.units).reduce(func(a, b): return a + b, 0) / (n_regions * 50.0)
	#Utils.log("Bonus units owned: ", bonus_units_owned)
	score += bonus_units_owned

	## malus for landlocked regions
	var malus_landlocked_regions = 0
	for r in regions_owned:
		if is_region_landlocked(world, r.id):
			malus_landlocked_regions += r.units
	malus_landlocked_regions = malus_landlocked_regions / (n_regions*50.0)
	score -= malus_landlocked_regions * self.personality.landlocked

	# score -= regions_owned.filter(func(region): return is_region_landlocked(world, region.id))\
	# 						.map(func(region): return region.units)\
	# 						.reduce(func(a, b): return a + b, 0) * 5
	# var bonus_adjacent = regions_owned.map(func(region): return region.units * (world.adjacencies[region.id]\
	# .filter(func(r): return world_state.regions[r].team != self.team).size()))\
	# .reduce(func(a, b): return a + b, 0) *0.5
	# #Utils.log("Minus adjacent: ", bonus_adjacent)
	# score += bonus_adjacent

	# var regions_not_owned = world_state.regions.values().filter(func(region): return region.team != self.team && region.team != Constants.NULL_TEAM)
	# var regions_not_owned_pos = regions_not_owned.map(func(region): return world.coords_to_pos(world.tiles[world.regions[region.id].data.tiles[0]].data.coords))
	# var total_dist = 0
	# for r in regions_owned:
	# 	var pos = world.coords_to_pos(world.tiles[world.regions[r.id].data.tiles[0]].data.coords)
	# 	regions_not_owned_pos.sort_custom(func(a, b): return world.hex_distance(pos, a) < world.hex_distance(pos, b))
	# 	var closest = regions_not_owned_pos[0]
	# 	var dist = world.hex_distance(pos, closest) * r.units / 1000000.0
	# 	#Utils.log("Closest ", closest, " to ", r, " is ", dist)
	# 	total_dist += dist
	# var avg_dist = total_dist / regions_owned.size()
	# #Utils.log("Average distance: ", avg_dist)
	# score -= avg_dist

	var regions_not_owned = world_state.regions.values().filter(func(region): return region.team != self.team && region.team != Constants.NULL_TEAM)\
	.map(func(region): return region.id)
	var total_dist = 0
	if regions_not_owned.size() == 0:
		return 999
	for r in regions_owned:
		regions_not_owned.sort_custom(func(a, b): return world.path_lengths[r.id][a] < world.path_lengths[r.id][b])
		#Utils.log("%s regions not owned: %s " % [regions_not_owned.size(), regions_not_owned])
		var closest = regions_not_owned[0]
		#Utils.log("Closest ", closest)
		var dist = world.path_lengths[r.id][closest] * r.units
		#Utils.log("Closest ", closest, " to ", r, " is ", dist)
		total_dist += dist
	var avg_dist = total_dist / regions_owned.size()
	var max_dist = 0
	for r in world.regions:
		for y in world.regions:
			if r!=y and world.path_lengths[r][y] > max_dist:
				max_dist = world.path_lengths[r][y]
	#Utils.log("Average distance: ", avg_dist)
	score -= (avg_dist/(max_dist*50.0)) * self.personality.distance
	
	return score
		

func prune_tree(moves, number_of_moves):
	# Utils.log("Pruning moves: ", moves.size())
	var keep_n_moves = min(number_of_moves, moves.size())
	var pruned_moves = {}
	var sorted_moves = moves.values()
	sorted_moves.sort()
	sorted_moves.reverse()
	# Utils.log("Sorted moves: ", sorted_moves)
	# var picked_moves = sorted_moves.slice(0, keep_n_moves)
	# for i in range(keep_n_moves):
	# 	picked_moves.append(sorted_moves.pop_at(Utils.rng.randi() % sorted_moves.size()))
	# for m in moves:
	# 	if moves[m] in picked_moves:
	# 		pruned_moves[m] = moves[m]
	# 		picked_moves.erase(moves[m])
	var min_score = sorted_moves[keep_n_moves-1]
	for m in moves:
		# Utils.log("Move: ", m, " score: ", moves[m], " min: ", min_score)
		if moves[m] >= min_score:
			pruned_moves[m] = moves[m]
		if pruned_moves.size() == keep_n_moves:
			break
	# Utils.log("Pruned moves: ", pruned_moves.size())

	return pruned_moves

func sim_turn(sim_moves, world, world_sim):
	var possible_moves = sim_moves.duplicate(true)
	for sim_move in sim_moves:
		var world_state = world_sim.clone()
		for move in sim_move:
			world_state.simulate(move)
		var usable_regions = self.get_usable_regions(world_state)
		for region in usable_regions:
			var adjacent_regions = world.adjacencies[region.id].filter(func(r): return !world_state.regions[r].is_used)
			for move in self.get_region_moves(region.id, adjacent_regions):
				var clone_world = world_state.clone()
				clone_world.simulate(move)
				var all_moves = sim_move.duplicate(true)
				all_moves.append(move)
				possible_moves[all_moves] = evaluate_state(clone_world, world)
	# if possible_moves.size() == 0:
	# 	return sim_moves
	return possible_moves

func play_turn(world):
	Utils.log("Playing turn: %s" % Constants.TEAM_NAMES[self.team])
	var world_sim = WorldState.new(world)
	var default_score = self.evaluate_state(world_sim, world)
	var possible_moves = {[]: default_score}
	var number_of_moves = 15
	var number_of_turns = 15
	var minus_moves = number_of_moves / number_of_turns
	for i in range(number_of_turns):
		#Utils.log("Calculating possible moves (", i, ") , size: ", possible_moves.size())
		var new_moves = self.prune_tree(self.sim_turn(possible_moves, world, world_sim), number_of_moves)
		if new_moves.keys() == possible_moves.keys():
			Utils.log("Stopping here %s" % i)
			break
		possible_moves = new_moves 
		number_of_moves -= minus_moves

	Utils.log("Calculated possible moves %s" % possible_moves.size())

	var best_move = [Action.new(self.team, Constants.Action.None)]
	var best_score = default_score
	for move in possible_moves.keys():
		if possible_moves[move] > best_score:
			best_move = move
			best_score = possible_moves[move]
	Utils.log("Best move %s / %s" % [best_move, best_score])
	return best_move


func get_region_moves(region, adjacent_regions):
	# Utils.log("Getting moves for region ", region, " adjacent regions: ", adjacent_regions.size())
	var moves = []
	for adjacent_region in adjacent_regions:
		moves.append(Action.new(self.team, Constants.Action.Move, region, adjacent_region))
	#Utils.log("Moves for region ", region, ": ", moves)
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
	if world.adjacencies[region].size() == 0:
		return true
	for neighbor in world.adjacencies[region]:
		if world.regions[neighbor].data.team != self.team:
			landlocked = false
			break
	return landlocked
