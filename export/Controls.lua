local Controls = {}
Controls._ready = false

local API = {}
API.__index = {}

local BetterEvents = require("BetterEvents")
local BetterVector = require("BetterVector")

local Send = BetterEvents.Get("Mazestein_send")

Controls._GLOBAL = {
	Player_Position = BetterVector.new(2,0,0),
	Player_Direction = BetterVector.new(2,0,0),
	Player_Angle = 0,
	MAP_SIZE = 0,
	MAP_WIDTH = 0,
	MAP_HEIGHT = 0,
	MAP = {},
}

local pi = math.pi
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local floor = math.floor
local min = math.min
local max = math.max
local clamp = math.clamp

function Controls.Initialize(config,_cpu,_video)
		Controls._GLOBAL.Player_Position = config.PlayerPosition
		Controls._GLOBAL.Player_Angle = config.PlayerAngle
		Controls._GLOBAL.MAP = config.TileMap
		Controls._GLOBAL.MAP_SIZE = #config.TileMap
		Controls._GLOBAL.MAP_WIDTH = config.TileMapWidth
		Controls._GLOBAL.MAP_HEIGHT = config.TileMapHeight
end

function Controls._Tick()
		local nextX = Controls._GLOBAL.Player_Position.x + Controls._GLOBAL.Player_Direction.x
		local nextY = Controls._GLOBAL.Player_Position.y + Controls._GLOBAL.Player_Direction.y
		local mx = math.floor(nextX / Controls._GLOBAL.MAP_SIZE)
		local my = math.floor(nextY / Controls._GLOBAL.MAP_SIZE)
		local canMove = true
		if mx < 0 or my < 0 or mx >= Controls._GLOBAL.MAP_WIDTH or my >= Controls._GLOBAL.MAP_HEIGHT then canMove = false end
		if canMove then
		local idx = my * Controls._GLOBAL.MAP_WIDTH + mx + 1
		if Controls._GLOBAL.MAP[idx] == 1 then canMove = false end
		end

		if canMove then
				Controls._GLOBAL.Player_Position:Set(nextX, nextY)
		end
		Send:Fire(1,{PLAYER_ANGLE = Controls._GLOBAL.Player_Angle})
end

API.PlayerSpeed = 2

function API:SetAngle(angle)
		Controls._GLOBAL.Player_Angle = angle
end

function API:AddAngle(angle)
		Controls._GLOBAL.Player_Angle += angle
end

function API:Move(forward)
		Controls._GLOBAL.Player_Direction:Set(cos(Controls._GLOBAL.Player_Angle) * forward * API.PlayerSpeed, sin(Controls._GLOBAL.Player_Angle) * forward * API.PlayerSpeed)
		if forward == 0 then Controls._GLOBAL.Player_Direction:Set(0,0) end
end

Controls.API = API

return Controls
