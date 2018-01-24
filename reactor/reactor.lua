local component = require("component")
local sides     = require("sides")
local shell     = require("shell")
local term      = require("term")
local event     = require("event")
local reactorControl = require("reactorControl")

local stop = false

local function writeLine(str)
  term.clearLine()
  print(str)
end

local function status()
  local on, heat, energy = reactorControl.status()
  term.setCursor(1,1)
  writeLine("Reactor Controller: Running")
  writeLine("Reactor: " .. (on and "On" or "Off"))
  writeLine("Current Heat: " .. math.floor(heat * 100 + 0.5) .. "%")
  writeLine("Energy Stored: " .. math.floor(energy + 0.5).." RF")
end

local function keyHandler(_ , ch, code, playerName)
  local ch = string.char(ch)
  if ch == 'q' then
    stop = true
  end
end

local function handleEvent(e, ...)
  if e == "key_up" then
    keyHandler(...)
  elseif e == "interrupted" then 
    stop = true
  end
end

term.clear()
while not stop do
  reactorControl.mainLoop()
  status()
  handleEvent(event.pull(0.5))
end

local rs = component.redstone
for _,s in ipairs(sides) do
  rs.setOutput(sides[s], 0)
end
