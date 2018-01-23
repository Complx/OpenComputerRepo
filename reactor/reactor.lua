local component = require("component")
local sides = require("sides")
local shell = require("shell")

local e, r = shell.execute("reactorControl")

local rs = component.redstone

for _,s in ipairs(sides) do
  rs.setOutput(sides[s], 0)
end
