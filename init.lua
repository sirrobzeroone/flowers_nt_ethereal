----------------------------------------------------------
--        ___ _                         _  _ _____      --
--       | __| |_____ __ _____ _ _ ___ | \| |_   _|     --
--       | _|| / _ \ V  V / -_) '_(_-< | .` | | |       --
--       |_| |_\___/\_/\_/\___|_| /__/ |_|\_| |_|       --
----------------------------------------------------------
--           Flowers Node Timer for Ethereal            --
----------------------------------------------------------

-- modname and path
local m_name = minetest.get_current_modname()
local m_path = minetest.get_modpath(m_name)

-- setup mod global table and registered flowers table
flowers_nt_ethereal = {}

-- Fire Flower setting left as example but recommend left as false
flowers_nt_ethereal.fireflower = false

-- Specific game files to load
local game_id = Settings(minetest.get_worldpath()..DIR_DELIM..'world.mt'):get('gameid')

-- Check for Ethereal
local is_ethereal = minetest.get_modpath("ethereal")

	if is_ethereal then
		dofile(m_path.. "/i_eth_settings.lua" )
	else
		minetest.debug("[MOD] flowers_nt_ethereal - This mod is designed to work with Ethereal, no flower settings have been loaded")	
	end

-- if Bonemeal mod loaded
if minetest.get_modpath("bonemeal") ~= nil then
	dofile(m_path.. "/i_bonemeal_override.lua" )		
end

--[[
for k,v in pairs(minetest.registered_decorations) do

--if v.deco_type == "simple" then 
			minetest.debug(dump(minetest.registered_decorations[k]))
--end
end]]