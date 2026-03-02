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
  nightStart       = "19:00",
  dayStart         = "06:00",
  reminderInterval = 1,
  alertDuration    = 5,
}

function ns.ParseTime(str)
  if type(str) ~= "string" then return nil end
  local h, m = str:match("^(%d%d?):(%d%d?)$")
  if not h then return nil end
  h, m = tonumber(h), tonumber(m)
  if h > 23 or m > 59 then return nil end
  return h, m
end

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
  local nh, nm = ns.ParseTime(ns.db.nightStart)
  local dh, dm = ns.ParseTime(ns.db.dayStart)
  local nightStart = (nh or 19) * 60 + (nm or 0)
  local dayStart   = (dh or 6) * 60 + (dm or 0)

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

  -- migrate old nightHour/nightMinute/dayHour/dayMinute to HH:MM strings
  if ns.db.nightHour ~= nil then
    ns.db.nightStart = string.format("%02d:%02d", ns.db.nightHour or 19, ns.db.nightMinute or 0)
    ns.db.dayStart   = string.format("%02d:%02d", ns.db.dayHour or 6, ns.db.dayMinute or 0)
    ns.db.nightHour   = nil
    ns.db.nightMinute = nil
    ns.db.dayHour     = nil
    ns.db.dayMinute   = nil
  end

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
  elseif phase == "day" and hasBuff then
    ns.removedBuffToday = false
    ns.dbg("Aura change detected: " .. tostring(hasBuff))
  elseif phase == "day" and not hasBuff then
    ns.removedBuffToday = true
    ns.dbg("Aura change detected: " .. tostring(hasBuff))
  end
end

---------------------------------------------------------------------------
-- Debug slash command to dump internal state
---------------------------------------------------------------------------
SLASH_PIBDEBUG1 = "/pibdebug"
SlashCmdList["PIBDEBUG"] = function()
    ns.dbg("enabled: " .. tostring(ns.db.enabled))
    ns.dbg("phase: " .. tostring(ns.GetTimePhase()))
    ns.dbg("hasBuff: " .. tostring(ns.HasInkyBlackness()))
    ns.dbg("usedPotionTonight: " .. tostring(ns.usedPotionTonight))
    ns.dbg("removedBuffToday: " .. tostring(ns.removedBuffToday))
    ns.dbg("pendingReminder: " .. tostring(ns.pendingReminder))
    ns.dbg("lastPhase: " .. tostring(ns.lastPhase))
end

