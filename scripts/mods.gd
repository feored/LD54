class_name MapMods
extends RefCounted

enum Target { All, Enemies, Human }

enum Mod {
	Conscription,
	TotalWar,
	Godless,
	GodForsaken,
	Famine,
	Scarcity,
	NeptuneCurse,
	NeptunePrison,
	Treason
}

const mods = {
	Mod.Treason:
	{
		"level": 4,
		"name": "Treason",
		"effects":
		[
			{
				"target": Target.Human,
				"effect":
				{"type": "active", "name": "treason", "value": 1, "active_trigger": "turn_over"},
			},
		],
		"description":
		"At the end of your turn, one of your regions is converted to an enemy's side."
	},
	Mod.NeptunePrison:
	{
		"level": 2,
		"name": "Neptune's Prison",
		"effects":
		[
			{
				"target": Target.Human,
				"effect":
				{
					"type": "resource",
					"name": "cards_playable_per_turn",
					"value": "3",
				},
			},
		],
		"description": "Only play up to three cards per turn."
	},
	Mod.NeptuneCurse:
	{
		"level": 3,
		"name": "Neptune's Curse",
		"effects":
		[
			{
				"target": Target.Human,
				"effect":
				{
					"type": "active",
					"name": "sink_random_tiles",
					"value": 1,
					"active_trigger": "card_played"
				},
			},
		],
		"description": "Every time you play a card, Neptune randomly sinks own of your tiles."
	},
	Mod.Conscription:
	{
		"level": 1,
		"name": "Conscription",
		"effects":
		[
			{
				"target": Target.Enemies,
				"effect":
				{"type": "resource", "name": "units_per_tile", "value": "units_per_tile * 1.5"},
			}
		],
		"description": "Enemy troops regenerate twice as fast."
	},
	Mod.TotalWar:
	{
		"level": 2,
		"name": "Total War",
		"effects":
		[
			{
				"target": Target.Enemies,
				"effect":
				{"type": "resource", "name": "units_per_tile", "value": "units_per_tile * 2"},
			}
		],
		"description": "Enemy troops regenerate three times as fast."
	},
	Mod.Godless:
	{
		"level": 2,
		"name": "Godless",
		"effects":
		[
			{
				"target": Target.Human,
				"effect":
				{"type": "resource", "name": "faith_per_turn", "value": "faith_per_turn - 1"},
			}
		],
		"description": "Generate one less faith per turn."
	},
	Mod.GodForsaken:
	{
		"level": 3,
		"name": "Godforsaken",
		"effects":
		[
			{
				"target": Target.Human,
				"effect":
				{"type": "resource", "name": "faith_per_turn", "value": "faith_per_turn - 2"},
			}
		],
		"description": "Generate two less faith per turn."
	},
	Mod.Famine:
	{
		"level": 1,
		"name": "Famine",
		"effects":
		[
			{
				"target": Target.Human,
				"effect":
				{"type": "resource", "name": "units_per_tile", "value": "units_per_tile * 0.5"},
			}
		],
		"description": "Your troops regenerate half as fast."
	},
	Mod.Scarcity:
	{
		"level": 2,
		"name": "Scarcity",
		"effects":
		[
			{
				"target": Target.Human,
				"effect":
				{"type": "resource", "name": "cards_per_turn", "value": "cards_per_turn - 2"},
			}
		],
		"description": "Draw two less cards per turn."
	},
}
