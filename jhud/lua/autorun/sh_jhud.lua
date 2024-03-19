if SERVER then
	AddCSLuaFile("jhud/cl_jhud.lua")
	include("jhud/sv_jhud.lua")
else
	include("jhud/cl_jhud.lua")
end