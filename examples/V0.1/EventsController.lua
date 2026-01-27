local EventsController = {}

local stick = gdt.Stick0 -- set this variable to your Dpad/AnalogStick

local BetterEvents = require("BetterEvents")
local StickMovedSignal = BetterEvents.new("StickMoved")

local x,y = stick.X,stick.Y

function EventsController.Tick()
		if stick.X ~= x or stick.Y ~= y then
				StickMovedSignal:Fire(stick.X,stick.Y)
				x,y = stick.X,stick.Y
		end
end

return EventsController
