local addonName, ns = ...

function ns.dbg(msg)
  if not ns.db or not ns.db.debug then return end
  print("|cFF00FF00[PIB Debug]|r " .. msg)
end

-- the Inky Blackness buff spell ID
ns.BUFF_SPELL_ID = 185394

ns.defaults = {
  enabled          = true,
  debug            = false,
  nightHour        = 19,
  nightMinute      = 0,
  dayHour          = 6,
  dayMinute        = 0,
  reminderInterval = 1,
}

-------------------------
-- State                |
-------------------------
ns.ticker = nil
ns.lastCheckDate = nil
ns.lastPhase = nil
ns.usedPotionTonight = false
ns.removedBuffToday = false
ns.pendingReminder = false

function ns.HasInkyBlackness()
  return C_UnitAuras.GetPlayerAuraBySpellID(ns.BUFF_SPELL_ID) ~= nil
end

function ns.GetTimePhase()
  local now = date("*t")
  local currentMin = now.hour * 60 + now.min
  local nightStart = ns.db.nightHour * 60 + ns.db.nightMinute
  local dayStart   = ns.db.dayHour * 60 + ns.db.dayMinute

  -- Normal case: night = 19:00, day = 06:00
  -- Night phase wraps around midnight: 19:00 -> 23:59 and 00:00 -> 05:59
  if nightStart > dayStart then
    if currentMin >= nightStart or currentMin < dayStart then
      return "night"
    else
      return "day"
    end
  else
    -- edge case where boundaries are flipped, like night = 02:00 and day = 14:00
    if currentMin >= dayStart or currentMin < nightStart then
      return "day"
    else
      return "night"
    end
  end
end

function ns.CheckPhaseTransition()
  local today = date("%Y-%m-%d")

  if today ~= ns.lastCheckDate then
    ns.lastCheckDate = today
    ns.usedPotionTonight = false
    ns.removedBuffToday = false
  end

  local phase = ns.GetTimePhase()
  if phase ~= ns.lastPhase then
    if phase == "night" then
      ns.usedPotionTonight = false
    elseif phase == "day" then
      ns.removedBuffToday = false
    end
    ns.lastPhase = phase
  end
end

function ns.CheckAndRemind()
  if not ns.db.enabled then return end

  ns.CheckPhaseTransition()

  local phase = ns.GetTimePhase()
  local hasBuff = ns.HasInkyBlackness()

  ns.dbg("Check: phase=" .. phase .. " buff=" .. tostring(hasBuff))

  if phase == "night" then
    if hasBuff then
      ns.usedPotionTonight = true
      return
    end

    if ns.usedPotionTonight then return end
    if UnitAffectingCombat("player") then
      ns.pendingReminder = true
      return
    end

    ns.ShowReminder("night")

  elseif phase == "day" then
    if not hasBuff then
      ns.removedBuffToday = true
      return
    end

    if ns.removedBuffToday then return end
    if UnitAffectingCombat("player") then
      ns.pendingReminder = true
      return
    end

    ns.ShowReminder("day")
  end
end

function ns.StartCheckCycle()
  if ns.ticker then
    ns.ticker:Cancel()
  end

  ns.CheckAndRemind()

  ns.ticker = C_Timer.NewTicker(
    ns.db.reminderInterval * 60,
    ns.CheckAndRemind
  )
end

function ns.StopCheckCycle()
  if ns.ticker then
    ns.ticker:Cancel()
    ns.ticker = nil
  end
end

------------------------------------
-- Frames
------------------------------------
local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UNIT_AURA")

frame:SetScript("OnEvent", function(self, event, ...)
  if self[event] then
    self[event](self, ...)
  end
end)

function frame:ADDON_LOADED(loadedAddon)
  if loadedAddon ~= addonName then return end

  if not PaintItBlackDB then
    PaintItBlackDB = {}
    for k, v in pairs(ns.defaults) do
        PaintItBlackDB[k] = v
      end
    end

  -- fill any new keys added in updates
  for k, v in pairs(ns.defaults) do
    if PaintItBlackDB[k] == nil then
      PaintItBlackDB[k] = v
    end
  end

  ns.db = PaintItBlackDB

  ns.InitSettings()

  ns.lastCheckDate = date("%Y-%m-%d")
  ns.lastPhase = ns.GetTimePhase()

  ns.dbg("Loaded. Phase: " .. ns.lastPhase)

  self:UnregisterEvent("ADDON_LOADED")
end

function frame:PLAYER_ENTERING_WORLD()
  ns.dbg("Entering world, starting check cycle")
  ns.StartCheckCycle()
end

function frame:PLAYER_REGEN_ENABLED()
  if ns.pendingReminder then
    ns.pendingReminder = false
    ns.CheckAndRemind()
  end
end


function frame:UNIT_AURA(unit)
  if unit ~= "player" then return end

  local phase = ns.GetTimePhase()
  local hasBuff = ns.HasInkyBlackness()

  if phase == "night" and hasBuff then
    ns.usedPotionTonight = true
    ns.dbg("Aura change detected: " .. tostring(hasBuff))
  elseif phase == "day" and not hasBuff then
    ns.removedBuffToday = true
    ns.dbg("Aura change detected: " .. tostring(hasBuff))
  end
end

