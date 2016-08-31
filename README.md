Simple Homestart
----------------

This mod adds  a block that will allow the silent setting of a respawn point.
It also provides simple player specific and global start location services.

Commands
--------

It adds a new privilege, startlocation (if not defined by startlocation)

/startloc - sets the start location to wherever the invoking user is standing 

/sethome - Sets a player's personal home (requires the home privilege)

/home - Player returns to personal home (requires the home privilege)

In addition, if there is a valid start location then all NEW players will 
begin life at the start location.
Also, players will begin at the start location upon respawning.


Set home block
--------------
homestart:homeblock

When the player passes near this block it will set the start location at the block.
This can be useful in narratives, where you want the player to respawn at somewhere different from the original start, such as a tutorial.


Mod Compatiblity
----------------
sethome - This mod replaces the original "sethome" mod
unified_inventory - Compatible with the "home" buttons in this mod.  User can use these instead of the builtin home and sethome.
startlocation - Is compatible with this mod and can be used as a replacement if desired (this mod only supports a subset)


