local component = require("component")
local sides = require("sides")
local shell = require("shell")
local event = require("event")

local reactorControl = dofile(shell.resolve("reactorControl", "lua"))
local timer = 0

function start()
  if timer == 0 then
    timer = event.timer(0.2, reactorControl.mainLoop, math.huge)
    print("id: ", timer)
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