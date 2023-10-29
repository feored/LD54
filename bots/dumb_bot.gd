extends BaseBot
class_name DumbBot


func play_turn(world):
	var owned_regions = []
	for region in world.regions.keys():
		if can_use_region(world, region):
			owned_regions.append(region)
	owned_regions.shuffle()
	for region in owned_regions:
		for adjacent in world.adjacent_regions(region):
			if (
				world.regions[adjacent].team != Constants.NULL_TEAM
				and world.regions[adjacent].team != self.team
			):
				return Action.new(self.team, Constants.Action.Move, region, adjacent)
	for region in owned_regions:
		for adjacent in world.adjacent_regions(region):
			if world.regions[adjacent].team == Constants.NULL_TEAM:
				return Action.new(self.team, Constants.Action.Move, region, adjacent)
	for region in owned_regions:
		var landlocked = true
		var neighbors = world.adjacent_regions(region)
		for neighbor in neighbors:
			if world.regions[neighbor].team != self.team:
				landlocked = false
				break
		if landlocked:
			for neighbor in neighbors:
				if not world.regions[neighbor].is_used:
					return Action.new(self.team, Constants.Action.Move, region, neighbor)
	return Action.new(self.team, Constants.Action.None)


func can_use_region(world, region):
	return (
		(not world.regions[region].is_used)
		and world.regions[region].team == team
		and world.regions[region].units > 1
	)
