----------------------------------------------------------
--        ___ _                         _  _ _____      --
--       | __| |_____ __ _____ _ _ ___ | \| |_   _|     --
--       | _|| / _ \ V  V / -_) '_(_-< | .` | | |       --
--       |_| |_\___/\_/\_/\___|_| /__/ |_|\_| |_|       --
----------------------------------------------------------
--              Ethereal Flowers Register               --
----------------------------------------------------------
--------------------------------
-- Ethereal Specific Settings --
--------------------------------
-- Fire Flower

-- Change Ethereal "flower_spread" so Fire Flower removed 
-- found in ethereal>>dirt.lua line 105 

if flowers_nt_ethereal.fireflower then
	local flower_spread = function(pos, node)
		if (minetest.get_node_light(pos) or 0) < 13 then
			return
		end

		local pos0 = {x = pos.x - 4, y = pos.y - 2, z = pos.z - 4}
		local pos1 = {x = pos.x + 4, y = pos.y + 2, z = pos.z + 4}

		local num = #minetest.find_nodes_in_area(pos0, pos1, "group:flora")
		
		-- stop flowers spreading too much just below top of map block
		if minetest.find_node_near(pos, 2, "ignore") then
			return
		end

		if num > 3 and node.name == "ethereal:crystalgrass" then

			local grass = minetest.find_nodes_in_area_under_air(
				pos0, pos1, {"ethereal:crystalgrass"})

			if #grass > 4
			and not minetest.find_node_near(pos, 4, {"ethereal:crystal_spike"}) then

				pos = grass[math.random(#grass)]

				pos.y = pos.y - 1

				if minetest.get_node(pos).name == "ethereal:crystal_dirt" then

					pos.y = pos.y + 1

					minetest.swap_node(pos, {name = "ethereal:crystal_spike"})
				end
			end

			return

		elseif num > 3 then
			return
		end

		pos.y = pos.y - 1

		local under = minetest.get_node(pos)

		-- make sure we have soil underneath
		if minetest.get_item_group(under.name, "soil") == 0
		or under.name == "default:desert_sand" then
			return
		end

		local seedling = minetest.find_nodes_in_area_under_air(
				pos0, pos1, {under.name})

		if #seedling > 0 then

			pos = seedling[math.random(#seedling)]

			pos.y = pos.y + 1

			if (minetest.get_node_light(pos) or 0) < 13 then
				return
			end

			minetest.swap_node(pos, {name = node.name})
		end
	end

	-- Update ABM's
	for k,ab in pairs(minetest.registered_abms) do
		
		local label = ab.label or ""
		local node1 = ab.nodenames and ab.nodenames[1] or ""
		
		if label == "Flower spread"
		or node1 == "group:flora" then
			ab.action = flower_spread
		end
	end

	-- Node timer to ethereal:dry_shrub to turn into fire flowers
	e_dry_shrub_def = table.copy(minetest.registered_nodes["ethereal:dry_shrub"])

	e_dry_shrub_def.on_timer = function(pos, elapsed)
				local meta = minetest.get_meta(pos)
				local flowers_nt_eth = meta:get_int("flowers_nt_ethereal")

					if flowers_nt_eth == 0 then
						local ran = math.random(1,10)
						meta:set_int("flowers_nt_ethereal", ran)
						flowers_nt_eth = ran
					end
				
					if flowers_nt_eth <= 8 then 
						-- do nothing we are dead
						minetest.get_node_timer(pos):stop()				
					else
						local transform = math.random(1,100)
						if transform <= 10 then
							local stage = math.random(0,1)
							minetest.set_node(pos, {name = "flowers_nt_ethereal:fire_flower_"..stage})
							flowers_nt.grow_flower_tmr(pos)
						else
							minetest.get_node_timer(pos):start(math.random(60, 180))
						end				
				   end
			   end
			   
	minetest.register_node(":ethereal:dry_shrub",e_dry_shrub_def)

	-- LBM is needed to start the timers on inital mapgen for ethereal:dry_shrub
	minetest.register_lbm({
	  name = "flowers_nt_ethereal:dry_shrub",
	  run_at_every_load = true, 
	  nodenames = {"ethereal:dry_shrub"},
	  action = function(pos, node)
				local meta = minetest.get_meta(pos)
				local flowers_nt_eth = meta:get_int("flowers_nt_ethereal")
				local timer = minetest.get_node_timer(pos)
				
				if flowers_nt_eth == 0 then
					local ran = math.random(1,10)
					meta:set_int("flowers_nt_ethereal", ran)
					flowers_nt_eth = ran
				end
				
				if flowers_nt_eth > 8 then
					timer:start(math.random(10,30))
				end
			end,
	})
	 
	-- Fire Flower stages created by API
	flowers_nt.register_flower({
								flower_name = "Fire Flower",
								grow_on     = {"ethereal:fiery_dirt"},
								light_min   = 12,
								light_max   = 15,
								time_min    = 60,
								time_max    = 180,
								sounds      = default.node_sound_leaves_defaults(),
								sel_box     = {-5 / 16, -0.5, -5 / 16, 5 / 16, 1 / 2, 5 / 16},
								e_groups    = {igniter = 2},
								existing    = "ethereal:fire_flower",
								on_punch_2  = function(pos, node, puncher)
												puncher:punch(puncher, 1.0, {
													full_punch_interval = 1.0,
													damage_groups = {fleshy = 3} -- Plant more potent as it needs to flower/seed.
												}, nil)
											end, 
								on_punch_3  = function(pos, node, puncher)
												puncher:punch(puncher, 1.0, {
													full_punch_interval = 1.0,
													damage_groups = {fleshy = 2}
												}, nil)
											end,
								on_punch_4  = function(pos, node, puncher)
												puncher:punch(puncher, 1.0, {
													full_punch_interval = 1.0,
													damage_groups = {fleshy = 1} -- Plant wants to spread it's seeds/old so less potent
												}, nil)
											end
	})
end

-- Fire Thorn
-- Cold weather plant slower growth
flowers_nt.register_flower({
							flower_name = "Firethorn",
							grow_on     = {"default:snowblock"},
							biomes      = {"glacier"},
							biome_seed  = 2,
							cover       = 3,
							light_min   = 10,
							light_max   = 15,
							time_min    = 100,
							time_max    = 200,
							y_min       = 1,
							y_max       = 30,
							sounds      = default.node_sound_leaves_defaults(),
							sel_box     = {-0.3125,-0.5,-0.3125,0.3125,0.25,0.3125},
							existing    = "ethereal:firethorn"
})



-- Illumishrooms notes
-- Illumishrooms from what I can tell would appear to have no light limit ie 0 to 15.
-- deduced from Ethereal code as no ABM to remove them if light above certain level, 
-- they are not in mushroom group which enforces a 14 light limit for Red/Brown mushrooms. 
-- Illumishrooms also grow in pitch black caves down to -3000 so no lower limit either. 
-- Illumishrooms normally start growing on coal, I think this is just for ease of working out
-- initial cave placement. After that I can find no ABM that spreads them. However I have
-- added a few additional grow_on's; "default:dirt" and "ethereal:mushroom_dirt". 
-- Attached Node info - https://minetest.gitlab.io/minetest/groups/#node-only-groups

-- Red Illumishroom
flowers_nt.register_flower({
							flower_name = "Red Illumishroom",
							stage_5_name= " Spores",
							grow_on     = {"default:stone_with_coal",
										   "default:dirt",
										   "ethereal:mushroom_dirt"
									      },
							light_min   = 0,
							light_max   = 15,
							light_source= 5,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							sel_box     = {-0.375, -0.5, -0.375, 0.375, 0.47, 0.375},
							existing    = "ethereal:illumishroom" 
})

-- Green Illumishroom
flowers_nt.register_flower({
							flower_name = "Green Illumishroom",
							stage_5_name= " Spores",
							grow_on     = {"default:stone_with_coal",
										   "default:dirt",
										   "ethereal:mushroom_dirt"
									      },
							light_min   = 0,
							light_max   = 15,
							light_source= 5,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							sel_box     = {-0.375, -0.5, -0.375, 0.375, 0.47, 0.375},
							existing    = "ethereal:illumishroom2" 
})

-- Cyan Illumishroom
flowers_nt.register_flower({
							flower_name = "Cyan Illumishroom",
							stage_5_name= " Spores",
							grow_on     = {"default:stone_with_coal",
										   "default:dirt",
										   "ethereal:mushroom_dirt"
									      },
							light_min   = 0,
							light_max   = 15,
							light_source= 5,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							sel_box     = {-0.375, -0.5, -0.375, 0.375, 0.47, 0.375},
							existing    = "ethereal:illumishroom3" 
})

--------------
-- Mushroom --
--------------
flowers_nt.register_flower({
							flower_name = "Red Mushroom", --"Fly Agaric Toadstool",
							stage_5_name= " Spores",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass",
										   "default:dirt_with_coniferous_litter",
										   "ethereal:mushroom_dirt"
									      },
							biomes      = {"coniferous_forest", "deciduous_forest"},
							biome_seed  = 2,
							cover       = 3,
							light_min   = 10,
							light_max   = 14,
							light_max_death = true,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							sel_box     = {-0.35,-0.5,-0.35, 0.35, 0.125, 0.35},
							existing    = "flowers:mushroom_red",
							on_use      = minetest.item_eat(-5)
})

flowers_nt.register_flower({
							flower_name = "Brown Mushroom",
							stage_5_name= " Spores",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass",
										   "default:dirt_with_coniferous_litter",
										   "ethereal:mushroom_dirt"
									      },
							biomes      = {"coniferous_forest", "deciduous_forest"},
							biome_seed  = 2,
							cover       = 3,
							light_min   = 6,
							light_max   = 14,
							light_max_death = true,
							time_min    = 60,
							time_max    = 180,
							y_min       = -50,
							y_max       = 31000,
							sounds      = default.node_sound_leaves_defaults(),
							sel_box     = {-0.35,-0.5,-0.35, 0.35, 0.125, 0.35},
							existing    = "flowers:mushroom_brown",
							on_use      = minetest.item_eat(1)
})

-------------
-- Flowers --
-------------
flowers_nt.register_flower({
							flower_name = "Green Chrysanthemum",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass"
									      },
							biomes      = {"grassland", "deciduous_forest"},
							biome_seed  = 800081,
							cover       = 4,
							light_min   = 12,
							light_max   = 15,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							color       = "green",
							sel_box     = {-0.35,-0.5,-0.35, 0.35, 0.25, 0.35},
							e_groups    = {flammable = 1},
							existing    = "flowers:chrysanthemum_green"
})

flowers_nt.register_flower({
							flower_name = "Yellow Dandelion",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass"
									      },
							biomes      = {"grassland", "deciduous_forest"},
							biome_seed  = 1220999,
							cover       = 4,
							light_min   = 12,
							light_max   = 15,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							color       = "yellow",
							sel_box     = {-0.35,-0.5,-0.35, 0.35, 0.35, 0.35},
							e_groups    = {flammable = 1},
							existing    = "flowers:dandelion_yellow"
})

flowers_nt.register_flower({
							flower_name = "White Dandelion",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass"
									      },
							biomes      = {"grassland", "deciduous_forest"},
							biome_seed  = 73133,
							cover       = 4,
							light_min   = 12,
							light_max   = 15,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							color       = "white",
							sel_box     = {-0.25,-0.5,-0.25, 0.25, 0.10, 0.25},
							e_groups    = {flammable = 1},
							existing    = "flowers:dandelion_white"
})

flowers_nt.register_flower({
							flower_name = "Blue Geranium",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass"
									      },
							biomes      = {"grassland", "deciduous_forest"},
							biome_seed  = 36662,
							cover       = 4,
							light_min   = 12,
							light_max   = 15,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							color       = "blue",
							sel_box     = {-0.25,-0.5,-0.25, 0.25, 0.4, 0.25},
							e_groups    = {flammable = 1},
							existing    = "flowers:geranium"
})

flowers_nt.register_flower({
							flower_name = "Red Rose",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass"
									      },
							biomes      = {"grassland", "deciduous_forest"},
							biome_seed  = 436,
							cover       = 4,
							light_min   = 12,
							light_max   = 15,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							color       = "red",
							sel_box     = {-0.25,-0.5,-0.25, 0.25, 0.5, 0.25},
							e_groups    = {flammable = 1},
							existing    = "flowers:rose"
})

flowers_nt.register_flower({
							flower_name = "Black Tulip",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass"
									      },
							biomes      = {"grassland", "deciduous_forest"},
							biome_seed  = 42,
							cover       = 4,
							light_min   = 12,
							light_max   = 15,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							color       = "black",
							sel_box     = {-0.25,-0.5,-0.25, 0.25, 0.35, 0.25},
							e_groups    = {flammable = 1},
							existing    = "flowers:tulip_black"
})

flowers_nt.register_flower({
							flower_name = "Orange Tulip",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass"
									      },
							biomes      = {"grassland", "deciduous_forest"},
							biome_seed  = 19822,
							cover       = 4,
							light_min   = 12,
							light_max   = 15,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							color       = "orange",
							sel_box     = {-0.25,-0.5,-0.25, 0.25, 0.35, 0.25},
							e_groups    = {flammable = 1},
							existing    = "flowers:tulip"
})

flowers_nt.register_flower({
							flower_name = "Viola",
							grow_on     = {"default:dirt",
							               "default:dirt_with_grass"
									      },
							biomes      = {"grassland", "deciduous_forest"},
							biome_seed  = 1133,
							cover       = 4,
							light_min   = 12,
							light_max   = 15,
							time_min    = 60,
							time_max    = 180,
							sounds      = default.node_sound_leaves_defaults(),
							color       = "violet",
							sel_box     = {-0.25,-0.5,-0.25, 0.25, 0.10, 0.25},
							e_groups    = {flammable = 1},
							existing    = "flowers:viola"
})

------------------------
-- Flowers Water Lily --
------------------------
if not flowers_nt.rollback then

-- Convert any waterlilys in inventories
	minetest.register_on_joinplayer(function(player)	
		local inv_replace = {["flowers:waterlily"] = "flowers:waterlily_waving"}						   
		local inv = player:get_inventory()
				
		for i_tar,i_rep in pairs(inv_replace) do
			if inv:contains_item("main", i_tar) then
				local main_inv = inv:get_list("main")
				
				for i,itemstack in pairs(main_inv) do
					if itemstack:get_name() == i_tar then
						inv:remove_item("main", ItemStack(itemstack:get_name().." "..itemstack:get_count()))
						
						if i_rep ~= "air" then
							inv:set_stack("main", i, ItemStack(i_rep.." "..itemstack:get_count()))
						end				
						minetest.chat_send_player(player:get_player_name(),"Flowers_NT replace: "..itemstack:get_name().." replaced with "..i_rep.." x"..itemstack:get_count())					
					end
				end						
			end
		end
	end)
	

end

-- unregister flowers:waterlily
if not flowers_nt.rollback then
	minetest.unregister_item("flowers:waterlily")
end

-- ethereal uses "flowers:waterlily"
minetest.register_alias("flowers:waterlily", "flowers:waterlily_waving") 


-- Normal registration process
local eth_walkable = ethereal.lilywalk

flowers_nt.register_flower({
							flower_name = "Water Lily",
							grow_on     = {"default:water_source",
										   "default:river_water_source"
									      },
							biomes      = {"rainforest_swamp", "savanna_shore", "deciduous_forest_shore"},
							biome_seed  = 33,
							cover       = 7,
							y_max       = 0,
							y_min       = 0,
							rot_place   = true,
							light_min   = 12,
							light_max   = 15,
							time_min    = 60,
							time_max    = 180,
							drawtype    = "mesh",
							mesh        = "water_lilypad.obj",
							walkable    = eth_walkable,
							inv_img     = true,
							sounds      = default.node_sound_leaves_defaults(),
							color       = "pink",
							sel_box     = {-0.4,-0.5,-0.4, 0.4, -0.45, 0.4},
							existing    = "flowers:waterlily_waving",
							is_water    = true
})

-- Due to the custom nature best to set this up manually
-- ethereal waterlily decoration 
-- uses schematic, api dosent support schematic removal/edit

for k,v in pairs(minetest.registered_decorations) do
	if v.deco_type == "schematic" then
		if type(v.schematic.data) == "table" then
			for k2,v2 in pairs(v.schematic.data) do
				if v2.name == "flowers:waterlily" then
					flowers_nt.delete_decoration(k)
				end
			end
		end
	end
end

-- add new simple waterlily schematic
local dec_def = {
	name = "flowers_nt_ethereal:water_lily",
	deco_type = "simple",
	place_on = "default:sand",
	sidelen = 16,
	noise_params = {
		octaves = 3,
		seed = 33,
		spread = {y = 200,x = 200,z = 200},
		persist = 0.7,
		offset = -0.12,
		scale = 0.3
	},
	biomes = {
		"desert_ocean",
		"plains_ocean",
		"sandclay",
		"mesa_ocean",
		"grove_ocean",
		"deciduous_forest_ocean",
		"swamp_ocean"
	},
	y_max = 0,
	y_min = 0,
	place_offset_y = 1,
	param2 = 0,
	param2_max = 3,
	decoration = {"flowers_nt_ethereal:water_lily_1", 
				  "flowers_nt_ethereal:water_lily_2", 
				  "flowers:waterlily_waving",
				  "flowers_nt_ethereal:water_lily_4"}
}

minetest.register_decoration(dec_def)


