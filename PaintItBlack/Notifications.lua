local addonName, ns = ...

local frame = CreateFrame("Frame", "PaintItBlackAlert", UIParent, "BackdropTemplate")
frame:SetSize(350, 60)
frame:SetPoint("TOP", UIParent, "TOP", 0, -200)
frame:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
frame:SetBackdropColor(0, 0, 0, 0.8)
frame:SetBackdropBorderColor(1, 0.8, 0, 0.6)
frame:Hide()

frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function(self)
  self:Hide()
end)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("CENTER")
text:SetTextColor(1, 0.8, 0)

local messages = {
  night = "Use your Inky Black Potion!",
  day = "Remove your Inky Black Potion Buff!"
}

function ns.ShowReminder(phase)
  local msg = messages[phase] or "Inky Black Potion reminder!"

  text:SetText(msg)
  frame:Show()

  PlaySound(3081)

  print("|cFFFFCC00[Paint It Black]|r " .. msg)

  C_Timer.After(ns.db.alertDuration, function()
    frame:Hide()
  end)
end

