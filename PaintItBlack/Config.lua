local addonName, ns = ...

function ns.InitSettings()
  -- settings category
  local category = Settings.RegisterVerticalLayoutCategory("Paint It Black")

  local function addSlider(key, name, tooltip, min, max, step, default)
    local setting = Settings.RegisterAddOnSetting(
      category,
      "PaintItBlack_" .. key,
      key,
      PaintItBlackDB,
      type(1),
      name,
      default
    )

    local options = Settings.CreateSliderOptions(min, max, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

    Settings.CreateSlider(category, setting, options, tooltip)
    setting:SetValueChangedCallback(function()
      ns.StartCheckCycle()
    end)

  end

  local enabledSetting = Settings.RegisterAddOnSetting(
    category,
    "PaintItBlack_Enabled",
    "enabled",
    PaintItBlackDB,
    type(true),
    "Enable Reminders",
    true
  )
  Settings.CreateCheckbox(category, enabledSetting, "Toggle Inky Black Potion reminders.")
  enabledSetting:SetValueChangedCallback(function()
    ns.StartCheckCycle()
  end)

  local debugSetting = Settings.RegisterAddOnSetting(
    category,
    "PaintItBlack_Debug",
    "debug",
    PaintItBlackDB,
    type(true),
    "Debug Mode",
    false
  )
  Settings.CreateCheckbox(category, debugSetting, "Print debug messages to chat.")

  addSlider(
    "nightHour",
    "Night Starts (Hour)",
    "Hour when 'use potion' reminders begin (24h format).",
    0, 23, 1, 19
  )
  addSlider(
    "nightMinute",
    "Night Starts (Minute)",
    "Minute offset for night start.",
    0, 59, 1, 0)
  addSlider(
    "dayHour",
    "Day Starts (Hour)",
    "Hour when 'remove buff' reminders begin (24h format).",
    0, 23, 1, 6
  )
  addSlider(
    "dayMinute",
    "Day Starts (Minute)",
    "Minute offset for day start.",
    0, 59, 1, 0
  )
  addSlider(
    "reminderInterval",
    "Reminder Interval (minutes)",
    "Minutes between reminders.",
    1, 30, 1, 5
  )

  Settings.RegisterAddOnCategory(category)

  SLASH_PAINTITBLACK1 = "/pib"
  SlashCmdList["PAINTITBLACK"] = function()
    Settings.OpenToCategory(category:GetID())
  end
end
