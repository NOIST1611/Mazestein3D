-- Basic example of simple maze game V0.1 --

-- Utils
local Engine = require("Engine") -- Getting Engine controller

local BetterEvents = require("BetterEvents") -- Event util
local BetterVector = require("BetterVector") -- Vector util
local EventController = require("EventsController") -- Event controller for event handling(Not part of Mazestein 3D)

-- Types --
type Vector = Engine.Vector
type GameConfig = Engine.GameConfig

-- Random seed (so maze differs each run)
math.randomseed(math.random(1,1000))

-- Maze generator --
local function GenerateMaze(width, height) : any
    if width < 3 or height < 3 then
        local tiny = {}
        for y = 1, height do
            for x = 1, width do
                tiny[#tiny + 1] = 1
            end
        end
        return tiny
    end

    local function idx(x, y)
        return (y - 1) * width + x
    end
		
    local grid = {}
    for y = 1, height do
        for x = 1, width do
            grid[idx(x, y)] = 1
        end
    end

    local function shuffle(t)
        for i = #t, 2, -1 do
            local j = math.random(i)
            t[i], t[j] = t[j], t[i]
        end
    end
		
    local dirs = {
        {dx = 0, dy = -1},
        {dx = 0, dy = 1},
        {dx = -1, dy = 0},
        {dx = 1, dy = 0},
    }
		
    local startX = 1 + 2 * math.random(0, math.floor((width - 1) / 2))
    local startY = 1 + 2 * math.random(0, math.floor((height - 1) / 2))
		
    local stack = {}
    grid[idx(startX, startY)] = 0
    stack[#stack + 1] = {x = startX, y = startY}

    while #stack > 0 do
        local cur = stack[#stack]
        local cx, cy = cur.x, cur.y
				
        local neighbors = {}
        for _, d in ipairs(dirs) do
            local nx = cx + d.dx * 2
            local ny = cy + d.dy * 2
            if nx >= 1 and nx <= width and ny >= 1 and ny <= height and grid[idx(nx, ny)] == 1 then
                neighbors[#neighbors + 1] = {x = nx, y = ny, dx = d.dx, dy = d.dy}
            end
        end

        if #neighbors > 0 then
            shuffle(neighbors)
            local n = neighbors[1]
						
            local wx = cx + n.dx
            local wy = cy + n.dy
            grid[idx(wx, wy)] = 0
            grid[idx(n.x, n.y)] = 0
						
            stack[#stack + 1] = {x = n.x, y = n.y}
        else
            stack[#stack] = nil
        end
    end

    return grid
end

-- Configuration for Mazestein 3D
local MAP_W, MAP_H = 8, 8 -- Maze Width and Height
local generatedMap = GenerateMaze(MAP_W, MAP_H)

local GameConfig : GameConfig = {
	-- Map(1D array) - Row-major array which represents map(1 = wall,0 = air),lenght should be Width * Height
	TileMap = generatedMap,
	-- Width/Height of map
	TileMapWidth = MAP_W,
	TileMapHeight = MAP_H,
	
	-- World position of player in the map(WARNING: Player shouldn't be in tile or else player will loose ability to move)
	PlayerPosition = BetterVector.new(2, 150, 150),
	-- Player Angle in radians
	PlayerAngle = 0,
	-- Player Field Of View(Should be in degress due to auto convert to radians inside Render)
	PlayerFOV = 60,
	
	-- Raycaster Settings
	-- Amount of rays who would be casted to draw walls(more rays equal better quality,at higher amount of rays affects perfomance more)
	RaycasterRays = 120,
	-- Fixed ray step size(smaller value gives better perfomance but affect perfomance heavily and bigger one is opossite)
	RaycasterRayStepSize = 1,
	
	-- Fixed color for Walls/Floor/Background(Wall color is getting darker with more distance)
	WallsColor = Color(180,180,100),
	FloorColor = Color(80,60,40),
	BackgroundColor = Color(100,120,140),
}

-- Valiables --
local Stick_Position = BetterVector.new(2,0,0) :: Vector -- Current position of Dpad

-- Initializing Mazestein 3D --
Engine.Initialize(GameConfig,gdt.CPU0,gdt.VideoChip0)

-- Components --
local Controls = Engine:GetComponent("Controls") -- Getting Controls component for handling movement

-- Movement --
function move() : ()
		if Stick_Position.y > 30 then
				Controls:Move(1)
		elseif Stick_Position.y < -30 then
				Controls:Move(-1)
		else
				Controls:Move(0)
		end
		
		if Stick_Position.x > 30 then
				Controls:AddAngle(0.04)
		elseif Stick_Position.x < -30 then
				Controls:AddAngle(-0.04)
		end
end

-- Events --
local StickMovedSignal = BetterEvents.Get("StickMoved")
local OnStickMoved = StickMovedSignal:Connect(function(x: number,y: number) : ()
	Stick_Position:Set(x,y)
end)

-- LOOP --
function update() : ()
	Engine.Update()
	EventController.Tick()
	move()
end
