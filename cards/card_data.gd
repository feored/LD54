extends RefCounted
class_name CardData

enum Cards { Offering, Prayer, Garrison, LuckOfTheDraw, Sacrifice, Abundance, TrialAndError, Seal }

const data = {
	Cards.Offering:
	{
		"name": "Offering",
		"effects":
		[{"event": "play", "type": "resource", "resource": "faith", "value": "faith + 1"}],
		"description": "Make an offering to Neptune and gain 1 faith.",
		"cost": 0,
		"requirements": [],
		"icon": "res://assets/icons/trident.png"
	},
	Cards.Seal:
	{
		"name": "Seal",
		"effects":
		[
			{
				"event": "play",
				"type": "power",
				"power": "build",
				"building": Constants.Building.Seal
			},
		],
		"description": "Seal a region to make it resist one of Neptune's Marks.",
		"cost": 1,
		"requirements": [],
		"icon": "res://assets/icons/seal.png"
	},
	Cards.TrialAndError:
	{
		"name": "Trial and Error",
		"effects":
		[
			{"event": "play", "type": "action", "action": "draw", "value": 1},
			{"event": "play", "type": "action", "action": "random_discard", "value": 1}
		],
		"description": "Draw 1 card and discard a random card.",
		"cost": 1,
		"requirements": [],
		"icon": "res://assets/icons/card.png"
	},
	Cards.Prayer:
	{
		"name": "Prayer",
		"effects":
		[
			{"event": "play", "type": "resource", "resource": "faith", "value": "faith + 2"},
			{"event": "play", "type": "action", "action": "random_discard", "value": 2}
		],
		"description": "Gain 2 faith and discard up to 2 random cards.",
		"cost": 0,
		"requirements": [],
		"icon": "res://assets/icons/prayer.png"
	},
	Cards.Garrison:
	{
		"name": "Garrison",
		"effects": [{"event": "play", "type": "power", "power": "reinforcements", "value": 10}],
		"description": "Summon 10 troops to the selected region.",
		"cost": 1,
		"requirements": [],
		"icon": "res://assets/icons/Plus.png"
	},
	Cards.LuckOfTheDraw:
	{
		"name": "Luck of the Draw",
		"effects": [{"event": "play", "type": "action", "action": "draw", "value": 1}],
		"description": "Draw 1 card.",
		"cost": 1,
		"requirements": [],
		"icon": "res://assets/icons/card.png"
	},
	Cards.Sacrifice:
	{
		"name": "Sacrifice",
		"effects":
		[
			{"event": "play", "type": "power", "power": "sacrifice", "value": 0},
			{"event": "play", "type": "action", "action": "draw", "value": 2}
		],
		"description": "Sacrifice a region to draw 2 cards.",
		"cost": 0,
		"requirements": [],
		"icon": "res://assets/icons/skull.png"
	},
	Cards.Abundance:
	{
		"name": "Abundance",
		"effects": [{"event": "draw", "type": "action", "action": "draw", "value": 1}],
		"description": "Draw 1 extra card every time you draw a card for 3 turns.",
		"cost": 0,
		"requirements": [],
		"icon": "res://assets/icons/Plus.png"
	}
}


static func get_instance(id: Cards):
	return Card.new(data[id])
