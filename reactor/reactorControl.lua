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

local redstone = component.redstone
local reactor = component.reactor_redstone_port
local turbine = component.ag_steam_turbine

local defaultCfg = {
  redstoneSide = "all",
  stayUnderCapacity = .75,
  reactorMaxHeat = .4,
  reactorMinHeat = .3,
}

config = configlib.loadConfig("reactor.cfg", defaultCfg)

local function setReactor(state)
  if state then
    output = 15
  else
    output = 0
  end
  if config.redstoneSide == "all" then
    for _,s in ipairs(sides) do
      redstone.setOutput(sides[s], output)
    end
  else
    redstone.setOutput(sides[config.redstoneSide], output)
  end
end

local function reactorHeat()
  return reactor.getHeat() / reactor.getMaxHeat()
end

local function reactorOn()
  return reactor.producesEnergy()
end

while true do
  if turbine.getEnergyStored() < turbine.getEnergyCapacity() * config.stayUnderCapacity then
    if reactorOn() then
      if reactorHeat() >= config.reactorMaxHeat then setReactor(false) end
    else
      if reactorHeat() <= config.reactorMinHeat then setReactor(true) end
    end
  else
    setReactor(false)
  end
  os.sleep(.2)
end