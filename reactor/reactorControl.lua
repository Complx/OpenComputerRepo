reactorControl = {}
local component = require("component")
local fs = require("filesystem")
local configlib = require("configlib")
local sides = require("sides")

if not component.isAvailable("redstone") then
  io.stderr:write("No Redstone interface found")
  return
elseif not component.isAvailable("reactor_redstone_port") then
  io.stderr:write("No Reactor Found, connect an Adapter to a Reactor Redstone Port")
  return
elseif not component.isAvailable("ag_steam_turbine") then
  io.stderr:write("No Steam Turbine Found")
  return
end

local defaultCfg = {
  redstoneSide = "all",
  stayUnderCapacity = .75,
  reactorMaxHeat = .15,
  reactorMinHeat = .05,
}
local config    = configlib.loadConfig("reactor.cfg", defaultCfg)

local redstone  = component.redstone
local reactor   = component.reactor_redstone_port
local turbine   = component.ag_steam_turbine

local maxEnergy = turbine.getEnergyCapacity() * config.stayUnderCapacity
local maxHeat   = reactor.getMaxHeat()

local setReactor
if config.redstoneSide == "all" then
  setReactor = function(state)
    local output = 0
    if state then
      output = 15
    end
    for s=0,5 do
      redstone.setOutput(s, output)
    end
  end
else
  setReactor = function(state)
    local output = 0
    if state then
      output = 15
    end
    redstone.setOutput(sides[config.redstoneSide], output)
  end
end

local function reactorHeat()
  return reactor.getHeat() / maxHeat
end

function reactorControl.mainLoop()
  if config == nil then print("Error") end
  if turbine.getEnergyStored() < maxEnergy then
    if reactor.producesEnergy() then
      if reactorHeat() >= config.reactorMaxHeat then setReactor(false) end
    else
      if reactorHeat() <= config.reactorMinHeat then setReactor(true) end
    end
  else
    setReactor(false)
  end
end

function reactorControl.status()
  return reactor.producesEnergy(), reactorHeat(), turbine.getEnergyStored()
end

return reactorControl