------------------------------------
-- Copyright © PlaneFighter7 2023 --
------------------------------------

-- // Services // --

local Players = game:GetService("Players")

-- // Variables // --

local GroupId = require(game:GetService("ServerScriptService").Loadout.Main).GroupId
local Commands = {}
local Banned = {}
local GameBanned = {}

local Prefix = ":"
local Remotes = script.AdminRemotes

-- // Functions // --

local function GetLevel(Player)
	repeat task.wait() until Remotes.Parent == game:GetService("ReplicatedStorage")
	
	for Level, _ in pairs(require(script.Settings).Settings) do
		for Group, Ranks in pairs(require(script.Settings).Settings[Level]) do
			for _, Rank in pairs(Ranks) do
				if Player:GetRoleInGroup(Group) == Rank then
					return Level
				end
			end
		end
	end
	
	return nil
end

local function OnPlayerJoined(Player)
	Player.Chatted:Connect(function(Message, Recipient)
		local Split = string.split(Message, " ")
		local Command = string.lower(string.split(Split[1], Prefix)[2])

		if Commands[Command] then
			if table.find(Commands[Command].Permissions, GetLevel(Player)) then
				Commands[Command]["Execute"](Player, Message)
			end
		end
	end)
	
	Banned = require(script.Bans).Banned
	GameBanned = require(script.Bans).GameBanned
	
	if table.find(GameBanned, Player.UserId) then
		Player:Kick("Banned From This Game")
	end

	if table.find(Banned, Player.UserId) then
		Player:Kick("Banned From This Server")
	end
	
	if GetLevel(Player) then
		Remotes.Welcome:FireClient(Player, GetLevel(Player))
	end
end

-- // Events // --

Players.PlayerAdded:Connect(function(Player)
	OnPlayerJoined(Player)
end)

-- // Init // --

Remotes.Parent = game:GetService("ReplicatedStorage")

Banned = require(script.Bans).Banned
GameBanned = require(script.Bans).GameBanned

for _, Module in pairs(script.Commands:GetChildren()) do
	Commands[Module.Name] = require(Module)
end
