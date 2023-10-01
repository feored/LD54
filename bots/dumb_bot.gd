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
			if world.regions[adjacent].team != self.team:
				return Action.new(self.team, Constants.Action.MOVE, region, adjacent)
	return Action.new(self.team, Constants.Action.NONE)


func can_use_region(world, region):
	return (
		(not region in world.regions_used)
		and world.regions[region].team == team
		and world.regions[region].units > 1
	)
