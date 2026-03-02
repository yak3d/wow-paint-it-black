local addonName, ns = ...

PIBTimeInputMixin = {}

function PIBTimeInputMixin:OnLoad()
  SettingsListElementMixin.OnLoad(self)
end

function PIBTimeInputMixin:Init(initializer)
  SettingsListElementMixin.Init(self, initializer)

  local data = initializer:GetData()
  self.setting = data.setting
  self.EditBox:SetText(data.setting:GetValue())

  self.EditBox:SetScript("OnEnterPressed", function()
    self:Commit()
  end)
  self.EditBox:SetScript("OnEditFocusLost", function()
    self:Commit()
  end)
end

function PIBTimeInputMixin:Commit()
  local text = self.EditBox:GetText()
  local h, m = ns.ParseTime(text)
  if h then
    local formatted = string.format("%02d:%02d", h, m)
    self.EditBox:SetText(formatted)
    self.setting:SetValue(formatted)
  else
    self.EditBox:SetText(self.setting:GetValue())
  end
  self.EditBox:ClearFocus()
end

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

  local function addTimeInput(key, label, tooltip, default)
    local setting = Settings.RegisterAddOnSetting(
      category,
      "PaintItBlack_" .. key,
      key,
      PaintItBlackDB,
      type(""),
      label,
      default
    )

    local data = Settings.CreateSettingInitializerData(setting, nil, tooltip)
    local initializer = Settings.CreateSettingInitializer("PIBTimeInputTemplate", data)
    Settings.RegisterInitializer(category, initializer)

    setting:SetValueChangedCallback(function()
      ns.StartCheckCycle()
    end)
  end

  addTimeInput("nightStart", "Night Starts", "When 'use potion' reminders begin (HH:MM, 24h format).", "19:00")
  addTimeInput("dayStart", "Day Starts", "When 'remove buff' reminders begin (HH:MM, 24h format).", "06:00")
  addSlider(
    "reminderInterval",
    "Reminder Interval (minutes)",
    "Minutes between reminders.",
    1, 30, 1, 5
  )
  addSlider(
    "alertDuration",
    "Alert Duration (seconds)",
    "How long the on-screen alert stays visible.",
    1, 30, 1, 5
  )

  Settings.RegisterAddOnCategory(category)

  SLASH_PAINTITBLACK1 = "/pib"
  SlashCmdList["PAINTITBLACK"] = function()
    Settings.OpenToCategory(category:GetID())
  end
end
