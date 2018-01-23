local component = require("component")
local sides = require("sides")
local shell = require("shell")
local event = require("event")

local timer = 0

function start()
  if timer == 0 then
    local reactorControl = dofile(shell.resolve("reactorControl", "lua"))
    timer = event.timer(0.6, reactorControl.mainLoop, math.huge)
    print("Started, id: ", timer)
  else
    print("reactorControl already running")
  end
end

function stop()
  local result = event.cancel(timer)
  print("Stopped: ", result)
  if not result then
    print("Error stopping reactorControl")
  end
  timer = 0
  local rs = component.redstone

  for _,s in ipairs(sides) do
    rs.setOutput(sides[s], 0)
  end
end

function status()
  if timer == 0 then
    print("Reactor Controller: Stopped")
  else
    local on, heat, energy = reactorControl.status()
    print("Reactor Controller: Running")
    print("Reactor: ", on and "On" or "Off")
    print("Current Heat: ", math.floor(heat * 100 + 0.5), "%"
    print("Energy Stored: ", energy)
  end
end