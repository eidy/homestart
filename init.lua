-- Boilerplate to support localized strings if intllib mod is installed.
local S;
if (minetest.get_modpath("intllib")) then
    dofile(minetest.get_modpath("intllib").."/intllib.lua");
    S = intllib.Getter(minetest.get_current_modname());
else
    S = function ( s ) return s end;
end

-- If startlocation mod isn't there, declare priv
if minetest.get_modpath("startlocation") == nil then   
    minetest.register_privilege("startlocation", {
	    description = "Can use /startloc",
	    give_to_singleplayer = false
    })
end

-- Check for sethome mod ... we are not compatible
if minetest.get_modpath("sethome") ~= nil then
    print("ERROR: sethomoe mod is not compatible with the homestart mod - Please remove the sethome mod")
end

-- homestart functions
homestart = {}
homestart.getallstart = function()
    return minetest.get_worldpath() .. "/startlocation"
end

homestart.getplayerstart = function(name)
    return minetest.get_worldpath() .. "/players/" .. name .. "home"
end

homestart.readhome = function(filename)
	local input = io.open(filename, "r")
	if not input then
		return nil
	end
	local loc = minetest.deserialize(input:read("*l")) 
	if loc == nil then
        return nil
    end
    io.close(input)

    return loc
end
 
homestart.savehome = function(pos,filename)
	local output = io.open(filename, "w")
	output:write(minetest.serialize(pos))
	io.close(output)
end

minetest.register_chatcommand("startloc", {
	params = "",
	privs = {startlocation=true},
	description = "Set the start location to your current location.",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		local pos = player:getpos()
		homestart.savehome(pos, homestart.getallstart())
		return true, "Start Location Set"
	end,
})


minetest.register_privilege("home", "Can use /sethome and /home") 
minetest.register_chatcommand("home", {
    description = "Teleport you to your home point",
    privs = {home=true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player == nil then
            -- just a check to prevent the server crashing
            return false
        end
        local sloc = homestart.readhome(homestart.getplayerstart(name))
        if sloc ~= nil then
            minetest.chat_send_player(name, "Teleported to home!")
            player:setpos(sloc)  
        else
            minetest.chat_send_player(name, "Set a home using /sethome")      
        end
 
    end,
})

minetest.register_chatcommand("sethome", {
    description = "Set your home point",
    privs = {home=true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        local pos = player:getpos()
        homestart.savehome(pos, homestart.getplayerstart(name))
        minetest.chat_send_player(name, "Home set!")
         
    end,
})

minetest.register_on_newplayer(function(player)
   
    if minetest.get_modpath("startlocation") == nil then   
        local loc = homestart.readhome(homestart.getallstart())
        if loc ~= nil then
            player:setpos(loc) 
        end
    end
end)
 
minetest.register_on_respawnplayer(function(player)

    local name = player:get_player_name()
    if name == nil then 
        return
    end

    -- Try our set home
    local sloc = homestart.readhome(homestart.getplayerstart(name))
    if sloc ~= nil then
        player:setpos(sloc)            
    end
 
    -- Support unified Inventory home mod
    if minetest.get_modpath("unified_inventory") ~= nil then
        if unified_inventory.home_pos[name] ~= nil then
            unified_inventory.go_home(player)
            return
        end
    end

   
    -- If startlocation mod isn't there, then use global loc
    if minetest.get_modpath("startlocation") == nil then   
        local loc = homestart.readhome(homestart.getallstart())
        if loc ~= nil then
            player:setpos(loc) 
        end
    end
 
end)

-- Register homeblock - pass near it and home will be set silently

minetest.register_node("homestart:homeblock", {
description = "",
tiles = {"default_cobble.png"},
paramtype = "light",
is_ground_content = true,
walkable = true,
lightsource = 10,
buildable_to = true,
lightsource = 10,
groups = {cracky=3, stone=1},
sounds = default.node_sound_stone_defaults() 
})
  
minetest.register_abm({
    nodenames = {"homestart:homeblock"},
    interval = 1,
    chance = 1,
    action = function(pos)
    
        if pos ~= nil then
                   
            for _,player in ipairs(minetest.get_connected_players()) do

                    local ppos = player:getpos()

                    -- If player is sitting on top, do it
                    if vector.distance(ppos,pos) < 2 then
                        homestart.savehome(vector.add(pos,{x=0,y=1,z=0}), homestart.getplayerstart(player:get_player_name()))
                    end
                                   
            end
               
        end

    end,
})

 
