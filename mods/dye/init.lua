-- minetest/dye/init.lua

-- To make recipes that will work with any dye ever made by anybody, define
-- them based on groups.
-- You can select any group of groups, based on your need for amount of colors.
-- basecolor: 9, excolor: 17, unicolor: 89
--
-- Example of one shapeless recipe using a color group:
-- Note: As this uses basecolor_*, you'd need 9 of these.
-- minetest.register_craft({
--     type = "shapeless",
--     output = '<mod>:item_yellow',
--     recipe = {'<mod>:item_no_color', 'group:basecolor_yellow'},
-- })

-- Other mods can use these for looping through available colors
local dye = {}
dye.basecolors = {"white", "grey", "black", "red", "yellow", "green", "cyan", "blue", "magenta"}
dye.excolors = {"white", "lightgrey", "grey", "darkgrey", "black", "red", "orange", "yellow", "lime", "green", "aqua", "cyan", "sky_blue", "blue", "violet", "magenta", "red_violet"}

-- Base color groups:
-- - basecolor_white
-- - basecolor_grey
-- - basecolor_black
-- - basecolor_red
-- - basecolor_yellow
-- - basecolor_green
-- - basecolor_cyan
-- - basecolor_blue
-- - basecolor_magenta

-- Extended color groups (* = equal to a base color):
-- * excolor_white
-- - excolor_lightgrey
-- * excolor_grey
-- - excolor_darkgrey
-- * excolor_black
-- * excolor_red
-- - excolor_orange
-- * excolor_yellow
-- - excolor_lime
-- * excolor_green
-- - excolor_aqua
-- * excolor_cyan
-- - excolor_sky_blue
-- * excolor_blue
-- - excolor_violet
-- * excolor_magenta
-- - excolor_red_violet

-- The whole unifieddyes palette as groups:
-- - unicolor_<excolor>
-- For the following, no white/grey/black is allowed:
-- - unicolor_medium_<excolor>
-- - unicolor_dark_<excolor>
-- - unicolor_light_<excolor>
-- - unicolor_<excolor>_s50
-- - unicolor_medium_<excolor>_s50
-- - unicolor_dark_<excolor>_s50

-- Local stuff
local dyelocal = {}

-- This collection of colors is partly a historic thing, partly something else.
dye.colors = {
	["white"] = {
		readable_name = "White",
		groups = {basecolor_white=1,   excolor_white=1,     unicolor_white=1},
		rgb = "#d0d6d7",
		unicolor = "white",
		mc = "white",
		palette_index = 0
	},
	["silver"] = {
		readable_name = "Light Grey",
		groups = {basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1},
		rgb = "#818177",
		unicolor = "grey",
		mc = "grey",
		palette_index = 1
	},
	["grey"] = {
		readable_name = "Grey",
		groups = {basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1},
		rgb = "#383c40",
		unicolor = "darkgrey",
		mc = "dark_grey",
		palette_index = 2
	},
	["black"] = {
		readable_name = "Black",
		groups = {basecolor_black=1,   excolor_black=1,     unicolor_black=1},
		rgb = "#080a10",
		unicolor = "black",
		mc = "black",
		palette_index = 3
	},
	["purple"] = {
		readable_name = "Purple",
		groups = {basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1},
		rgb = "#6821a0",
		unicolor = "violet",
		mc = "violet",
		palette_index = 4
	},
	["blue"] = {
		readable_name = "Blue",
		groups = {basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1},
		rgb = "#2e3094",
		unicolor = "blue",
		mc = "blue",
		palette_index = 5
	},
	["light_blue"] = {
		readable_name = "Light Blue",
		groups = {basecolor_blue=1,    excolor_blue=1,      unicolor_light_blue=1},
		rgb = "#258ec9",
		unicolor = "light_blue",
		mc = "lightblue",
		palette_index = 6
	},
	["cyan"] = {
		readable_name = "Cyan",
		groups = {basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1},
		rgb = "#167b8c",
		unicolor = "cyan",
		mc = "cyan",
		palette_index = 7
	},
	["green"] = {
		readable_name = "Green",
		groups = {basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1},
		rgb = "#4b5e25",
		unicolor = "dark_green",
		mc = "dark_green",
		palette_index = 8
	},
	["lime"] = {
		readable_name = "Lime",
		groups = {basecolor_green=1,   excolor_green=1,     unicolor_green=1},
		rgb = "#60ac19",
		unicolor = "green",
		mc = "green",
		palette_index = 9
	},
	["yellow"] = {
		readable_name = "Yellow",
		groups = {basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1},
		rgb = "#f1b216",
		unicolor = "yellow",
		mc = "yellow",
		palette_index = 10
	},
	["brown"] = {
		readable_name = "Brown",
		groups = {basecolor_brown=1,   excolor_orange=1,    unicolor_dark_orange=1},
		rgb = "#633d20",
		unicolor = "dark_orange",
		mc = "brown",
		palette_index = 11
	},
	["orange"] = {
		readable_name = "Orange",
		groups = {basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1},
		rgb = "#e26501",
		unicolor = "orange",
		mc = "orange",
		palette_index = 12
	},
	["red"] = {
		readable_name = "Red",
		groups = {basecolor_red=1,     excolor_red=1,       unicolor_red=1},
		rgb = "#912222",
		unicolor = "red",
		mc = "red",
		palette_index = 13
	},
	["magenta"] = {
		readable_name = "Magenta",
		groups = {basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1},
		rgb = "#ab31a2",
		unicolor = "red_violet",
		mc = "magenta",
		palette_index = 14
	},
	["pink"] = {
		readable_name = "Pink",
		groups = {basecolor_red=1,     excolor_red=1,       unicolor_light_red=1},
		rgb = "#d56791",
		unicolor = "light_red",
		mc = "pink",
		palette_index = 15
	},
}

-- Takes an unicolor group name (e.g. “unicolor_white”) and returns a
-- corresponding dye name (if it exists), nil otherwise.
function dye.unicolor_to_dye(unicolor_group)
	for k,v in pairs(dye.colors) do
		if v.groups[unicolor_group] == 1 then return "dye:"..k end
	end
end

function dye.mc_to_color(mccolor)
	for k,v in pairs(dye.colors) do
		if mccolor == v.mcre then return k end
	end
end

---Returns the definition of a color based on it's palette_index.
---@param index number?
---@return string?
---@return table?
function dye.palette_index_to_color(index)
	for k, v in pairs(dye.colors) do
		if v.palette_index == index then return k, v end
	end
end

for k, v in pairs(dye.colors) do
	core.register_craftitem("dye:" .. k, {
		_color = k,
		description = (v.readable_name .. " Dye"),
		groups = {craftitem = 1, dye = 1}, v.groups,
		inventory_image = "dye.png^(dye_mask.png^[colorize:"..v.rgb..")",
	})
end

-- Mix recipes
-- Just mix everything to everything somehow sanely

dyelocal.mixbases = {"magenta", "red", "orange", "brown", "yellow", "green", "dark_green", "cyan", "blue", "violet", "black", "dark_grey", "grey", "white", "light_blue"}

dyelocal.mixes = {
	--       	 magenta,   red,         orange,   		brown,    		yellow,   		green,  		dark_green, 	cyan,     	blue,       	violet,   	black,       	dark_grey, 		grey,       white,      	light_blue
	light_blue ={"violet",  "violet",    "orange", 		"orange", 		"green",  		"green", 		"green",  		"blue",    	"blue",     	"violet",  	"black",    	"grey",    		"grey",		"light_blue", 	"light_blue" },
	white = {    "pink",    "pink",      "orange", 		"orange", 		"yellow", 		"green", 		"green",  		"grey",  	"light_blue", 	"violet",  	"grey",      	"grey",    		"white",  	"white" },
	grey  = {	 "pink",    "pink",      "orange", 		"orange", 		"yellow", 		"green", 		"green",  		"grey",     "cyan",     	"pink",  	"dark_grey", 	"grey",    		"grey"},
	dark_grey={	 "brown",   "brown",     "brown", 		"brown", 		"brown",		"dark_green",	"dark_green",	"blue",		"blue",			"violet",	"black",		"black"},
	black = {	 "black",   "black",     "black",  		"black", 		"black",  		"black", 		"black",  		"black", 	"black", 		"black",  	"black"},
	violet= {	 "magenta", "magenta",   "red",  		"brown", 		"red",    		"cyan",  		"brown",  		"blue",  	"violet",		"violet"},
	blue  = {	 "violet",  "magenta",   "brown",		"brown",		"dark_green",	"cyan",			"cyan",   		"cyan",  	"blue"},
	cyan  = {	 "blue",    "brown",     "dark_green",	"dark_grey",	"green",		"cyan",			"dark_green",	"cyan"},
	dark_green={ "brown",   "brown",     "brown", 		"brown", 		"green",  		"green", 		"dark_green"},
	green = {	 "brown",   "yellow",    "yellow",		"dark_green",	"green",		"green"},
	yellow= {	 "red",     "orange", 	 "yellow",		"orange", 		"yellow"},
	brown = {	 "brown",   "brown",	 "orange", 		"brown"},
	orange= {	 "red",     "orange",	 "orange"},
	red   = {	 "magenta", "red"},
	magenta={	 "magenta"},
}

for one,results in pairs(dyelocal.mixes) do
	for i,result in ipairs(results) do
		local another = dyelocal.mixbases[i]
		minetest.register_craft({
			type = "shapeless",
			output = 'dye:'..result..' 2',
			recipe = {'dye:'..one, 'dye:'..another},
		})
	end
end

-- Hide dyelocal
dyelocal = nil

--[[
minetest.register_craftitem("dye:white", {
	inventory_image = "dye_white.png",
	description = "Bone Meal",
	stack_max = 64,
	groups = {dye=1, basecolor_white=1,   excolor_white=1,     unicolor_white=1},
	on_place = function(itemstack, user, pointed_thing) 
		duengen(pointed_thing)
	end,
})
]]

-- Crafts
minetest.register_craft({
	output = 'dye:white',
	recipe = {
		{'default:bone_meal'},
	}
})

minetest.register_craft({
	output = 'dye:white',
	recipe = {
		{'flowers:tulip_white'},
	}
})

minetest.register_craft({
	output = 'dye:silver',
	recipe = {
		{'flowers:oxeye_daisy'},
	}
})

minetest.register_craft({
	output = 'dye:black',
	recipe = {
		{'default:ink_sac'},
	}
})

minetest.register_craft({
	output = 'dye:blue',
	recipe = {
		{'default:lapis_lazuli'},
	}
})

minetest.register_craft({
	output = 'dye:light_blue',
	recipe = {
		{'flowers:blue_orchid'},
	}
})

minetest.register_craft({
	output = 'dye:red',
	recipe = {
		{'flowers:rose'},
	}
})

minetest.register_craft({
	output = 'dye:red',
	recipe = {
		{'flowers:tulip_red'},
	}
})

minetest.register_craft({
	output = 'dye:magenta',
	recipe = {
		{'flowers:allium'},
	}
})

minetest.register_craft({
	output = 'dye:pink',
	recipe = {
		{'flowers:houstonia'},
	}
})

minetest.register_craft({
	output = 'dye:pink',
	recipe = {
		{'flowers:tulip_pink'},
	}
})

minetest.register_craft({
	output = 'dye:pink',
	recipe = {
		{'flowers:houstonia'},
	}
})

minetest.register_craft({
	output = 'dye:yellow',
	recipe = {
		{'flowers:dandelion_yellow'},
	}
})

minetest.register_craft({
	output = 'dye:orange',
	recipe = {
		{'flowers:tulip_orange'},
	}
})