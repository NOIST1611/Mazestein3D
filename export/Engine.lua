local Engine = {}
Engine.Components = {}
Engine._TickList = {}
Engine.Config = nil
Engine._started = false

local prefix = "[Mazestein 3D]:"
local ComponentList = {
	"Render","Controls"
}

local ComponentPriorities = {
	Render = 2,
	Controls = 1,
}

local BetterEvents = require("BetterEvents")
local BetterVector = require("BetterVector")

local Send = BetterEvents.new("Mazestein_send")

export type Vector = BetterVector.Vector
export type Signal = BetterEvents.Signal

export type GameConfig = {
	TileMap : {number},
	TileMapWidth : number,
	TileMapHeight : number,
	
	PlayerPosition : Vector,
	PlayerAngle : number,
	PlayerFOV : number,
	
	RaycasterRays : number,
	RaycasterRayStepSize : number,
	WallsColor : color,
	FloorColor : color,
	BackgroundColor : color,
}

export type RenderPriorities = {
	Clear : number,
	Background : number,
	Ground : number,
	Entities : number,
	Walls : number,
	Sprites : number,
	UI : number,
}

export type RenderStep = {
	priority : number,
	fn: () -> (),
}

export type RenderAPI = {
	AddRenderStep : (name: string,priority: number,callback: () -> ()) -> (),
	RemoveRenderStep : (name: string) -> (),
	OnRender: Signal,
	RendePriorities: RenderPriorities,
	FOV: number,
}

export type ControlsAPI = {
	SetAngle: (angle: number) -> (),
	AddAngle: (angle: number) -> (),
	Move: (forward: number) -> (),
	PlayerSpeed: number,
}

local function RebuildTickList()
	Engine._TickList = {}

	for name, component in Engine.Components do
		table.insert(Engine._TickList, {
			Name = name,
			Component = component,
			Priority = ComponentPriorities[name] or 1
		})
	end

	table.sort(Engine._TickList, function(a, b)
		return a.Priority < b.Priority
	end)
end

local function LoadComponents()
		for _,name in ComponentList do
				local req
				
				local succes,err = pcall(function()
						req = require(name)
				end)
				
				if succes and req and req.Initialize and not Engine.Components[name] then
						Engine.Components[name] = req
				else
						print(string.format("%s Component skipped with error: %s",prefix,err))
				end
		end
end

function Engine:GetComponent(name)
		local Component = Engine.Components[name]
		if Component and Component.API then
				return Component.API
		else
				error(string.format("%s attempt to get API of uknown service/service who doesn't have API",prefix))
		end
end

function Engine.Initialize(config,cpu,video)
			if Engine._started then return end
			Engine.Config = config
			for _,component in Engine.Components do
					if component.Initialize then
							component.Initialize(config,cpu,video)
					end
			end
			
			RebuildTickList()
			
			Engine._started = true
end

function Engine.Update()
			if not Engine._started then return end

			for _, entry in ipairs(Engine._TickList) do
					local component = entry.Component
					if component._Tick then
							component._Tick()
					end
			end
end

LoadComponents()

return Engine
