extends Bot
class_name DumbBot


func play_turn(world):
	var owned_regions = get_owned_regions(world)
	for region in owned_regions:
		for adjacent in world.adjacent_regions(region):
			if (
				world.regions[adjacent].data.team != Constants.NULL_TEAM
				and world.regions[adjacent].data.team != self.team
			):
				return Action.new(self.team, Action.Type.Move, region, adjacent)
	for region in owned_regions:
		for adjacent in world.adjacent_regions(region):
			if world.regions[adjacent].data.team == Constants.NULL_TEAM:
				return Action.new(self.team, Action.Type.Move, region, adjacent)
	if not is_game_locked(world, owned_regions):
		for region in owned_regions:
			var neighbors = world.adjacent_regions(region)
			if is_region_landlocked(world, region, neighbors):
				for neighbor in neighbors:
					if not world.regions[neighbor].is_used:
						return Action.new(self.team, Action.Type.Move, region, neighbor)
	return Action.new(self.team, Action.Type.None)


func can_use_region(world, region):
	return (
		(not world.regions[region].data.is_used)
		and world.regions[region].data.team == team
		and world.regions[region].data.units > 1
	)


func is_region_landlocked(world, region, neighbors = null):
	var landlocked = true
	var neighbors_local = neighbors if neighbors != null else world.adjacent_regions(region)
	for neighbor in neighbors_local:
		if world.regions[neighbor].data.team != self.team:
			landlocked = false
			break
	return landlocked


func is_game_locked(world, owned_regions):
	var game_locked = true
	for region in owned_regions:
		if not is_region_landlocked(world, region):
			game_locked = false
			break
	return game_locked


func get_owned_regions(world):
	var owned_regions = []
	for region in world.regions.keys():
		if can_use_region(world, region):
			owned_regions.append(region)
	owned_regions.shuffle()
	return owned_regions
