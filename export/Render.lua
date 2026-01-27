local Render = {}

local API = {}
API.__index = API

Render.RenderPriorities = {
	Clear = 0,
	Background = 1,
	Ground = 2,
	Entities = 3,
	Walls = 4,
	Sprites = 5,
	UI = 6,
}

Render._ready = false

local BetterEvents = require("BetterEvents")
local BetterVector = require("BetterVector")

local Send = BetterEvents.Get("Mazestein_send")

local pi = math.pi
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local floor = math.floor
local min = math.min
local max = math.max
local clamp = math.clamp

Render._CPU = nil
Render._VIDEOCHIP = gdt.VideoChip0
local Width,Height = 1,1
Render._GLOBAL = {
	FOV = math.rad(60),
	RAYS = 120,
	MAP_SIZE = 0,
	MAP_WIDTH = 0,
	MAP_HEIGHT = 0,
	RAYSTEP = 4,
	MAP = {},
	FLOOR_COLOR = color.green,
	BACKGROUND_COLOR = color.cyan,
	WALL_COLOR = color.gray,
	PLAYER_ANGLE = 0,
	PLAYER_POSITION = BetterVector.new(2,0,0),
}

Send:Connect(function(to,data)
		if to == 1 then
				for name,value in data do
						if not Render._GLOBAL[name] then continue end
						
						Render._GLOBAL[name] = value
				end
		end
end)

Render.OnRender = BetterEvents.new("OnRender")
API.OnRender = Render.OnRender
API.FOV = Render._GLOBAL.FOV

local function CastRay(px, py, ra)
	local stepSize = Render._GLOBAL.RAYSTEP
	local maxSteps = 2000
	local dx = cos(ra)
	local dy = sin(ra)

	local rx, ry
	for i = 1, maxSteps do
		local dist = i * stepSize
		rx = px + dx * dist
		ry = py + dy * dist

		local mx = math.floor(rx / Render._GLOBAL.MAP_SIZE)
		local my = math.floor(ry / Render._GLOBAL.MAP_SIZE)

		if mx < 0 or my < 0 or mx >= Render._GLOBAL.MAP_WIDTH or my >= Render._GLOBAL.MAP_HEIGHT then
			return rx, ry, dist
		end

		local idx = my * Render._GLOBAL.MAP_WIDTH + mx + 1
		if Render._GLOBAL.MAP[idx] == 1 then
			return rx, ry, dist
		end
	end
	
	return px + dx * (maxSteps * stepSize), py + dy * (maxSteps * stepSize), maxSteps * stepSize
end

Render.RenderSteps = {
	Clear = {priority = Render.RenderPriorities.Clear,fn = function()
			Render._VIDEOCHIP:Clear(color.black)
	end},
	Background = {priority = Render.RenderPriorities.Background,
	fn = function()
			local viewX = 0
			local viewW = Width
			local viewH = Height
			Render._VIDEOCHIP:FillRect(vec2(viewX, 0), vec2(viewX + viewW, viewH * 0.5), Render._GLOBAL.BACKGROUND_COLOR)
	end,
	},
	Floor = {priority = Render.RenderPriorities.Ground,fn = function()
			local viewX = 0
			local viewW = Width
			local viewH = Height
			
			Render._VIDEOCHIP:FillRect(vec2(viewX, viewH * 0.5), vec2(viewX + viewW, viewH), Render._GLOBAL.FLOOR_COLOR)
	end
	},
	Walls = {priority = Render.RenderPriorities.Walls,fn = function()
			local viewX = 0
			local viewW = Width
			local viewH = Height

			local numRays = Render._GLOBAL.RAYS
			local fov = Render._GLOBAL.FOV
			local halfFOV = fov * 0.5
			local sliceW = viewW / numRays

			for r = 0, numRays - 1 do
					local rayAng = Render._GLOBAL.PLAYER_ANGLE - halfFOV + (r / (numRays - 1)) * fov
					local hx, hy, rawDist = CastRay(Render._GLOBAL.PLAYER_POSITION.x, Render._GLOBAL.PLAYER_POSITION.y, rayAng)
		
					local ca = Render._GLOBAL.PLAYER_ANGLE - rayAng
					local corrected = rawDist * math.cos(ca)
					if corrected <= 0.0001 then corrected = 0.0001 end
			
					local lineH = (Render._GLOBAL.MAP_SIZE * viewH) / corrected
					if lineH > viewH then lineH = viewH end
					local lineOff = (viewH / 2) - (lineH / 2)
		
					local shade = 1 / (1 + corrected / 400)
					if shade < 0.2 then shade = 0.2 end
					local baseColor = Render._GLOBAL.WALL_COLOR
					
					local R = clamp(math.floor(baseColor.R * shade), 0, 255)
					local G = clamp(math.floor(baseColor.G * shade), 0, 255)
					local B = clamp(math.floor(baseColor.B * shade), 0, 255)

					local wallColor = Color(R, G, B)
					
					local x1 = viewX + r * sliceW
					local x2 = viewX + (r + 1) * sliceW
					local y1 = lineOff
					local y2 = lineOff + lineH
					Render._VIDEOCHIP:FillRect(vec2(x1, y1), vec2(x2, y2), wallColor)
			end
	end},
}
Render.SortedRenderSteps = {}
Render._StepsSorted = false

function Render.Initialize(config,_cpu,_video)
		if Render._ready then return end
		Render._GLOBAL.PLAYER_POSITION = config.PlayerPosition
		Render._GLOBAL.PLAYER_ANGLE = config.PlayerAngle
		Render._GLOBAL.MAP = config.TileMap
		Render._GLOBAL.MAP_SIZE = #config.TileMap
		Render._GLOBAL.MAP_WIDTH = config.TileMapWidth
		Render._GLOBAL.MAP_HEIGHT = config.TileMapHeight
		API.FOV = math.rad(config.PlayerFOV)
		Render._GLOBAL.RAYS = config.RaycasterRays
		Render._GLOBAL.RAYSTEP = config.RaycasterRayStepSize
		Render._GLOBAL.WALL_COLOR = config.WallsColor
		Render._GLOBAL.FLOOR_COLOR = config.FloorColor
		Render._GLOBAL.BACKGROUND_COLOR = config.BackgroundColor
		Render._ChangeCore(_cpu,_video)
		Render._ready = true
end

function Render._RebuildSteps()
		Render.SortedRenderSteps = {}
		
		for _,step in Render.RenderSteps do
				table.insert(Render.SortedRenderSteps,step)
		end
		
    table.sort(Render.SortedRenderSteps, function(a, b)
        return a.priority < b.priority
    end)
		
		Render._StepsSorted = true
end

function Render._ChangeCore(_cpu,_video)
		Render._CPU = _cpu
		Render._VIDEOCHIP = _video
		
		Width,Height = Render._VIDEOCHIP.Width,Render._VIDEOCHIP.Height
end

function Render._AddStep(name,priority,fn)
		    Render.RenderSteps[name] = {
        priority = priority,
        fn = fn
    }
    Render._StepsDirty = true
end

function Render._RemoveStep(name)
		if not Render.RenderSteps[name] then return end
			
		Render.RenderSteps[name] = nil
		Render._StepsDirty = true
end

function Render._Tick()
    Render._GLOBAL.FOV = API.FOV
		
		if not Render._StepsSorted then
				Render._RebuildSteps()
		end

    for _, step in ipairs(Render.SortedRenderSteps) do
        step.fn()
    end
		
		Render.OnRender:Fire(Render._CPU.DeltaTime)
end

function API:AddRenderStep(name,priority,callback)
		Render._AddStep(name,priority,callback)
end

function API:RemoveRenderStep(name)
		Render._RemoveStep(name)
end

API.RenderPriorities = Render.RenderPriorities
Render.API = API

return Render
