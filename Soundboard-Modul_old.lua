-- Soundboard-Modul
NBM.Modules.Soundboard = NBM.Modules.Soundboard or {}

do
  local frame  -- privat, wird einmal gebaut

  local function BuildFrame()
    if frame then return end

    frame = CreateFrame("Frame", "NBM_Soundboard", UIParent)
    frame:SetSize(150, 240)
    frame:SetPoint("RIGHT")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left=8, right=8, top=8, bottom=8 }
    })
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing() end)

    -- Close
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() frame:Hide() end)

    -- BG
    local img = frame:CreateTexture(nil, "BACKGROUND")
    img:SetAllPoints()
    img:SetTexture("Interface\\AddOns\\NBM\\img\\logo.tga")

    -- Header
    local line1 = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    line1:SetPoint("TOP", 0, -20)
    line1:SetText("Soundboard")

    -- === deine Dropdown-Helper und Dropdowns genau wie bisher ===
    -- Helper
    local function CreateSimpleDropdown(parent, name, anchorFrame, x, y, items, defaultIndex, labelText, onChange)
      local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
      dd:SetPoint("CENTER", anchorFrame, "CENTER", x, y)
      if labelText then
        local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("CENTER", dd, "CENTER", 0, 25)
        lbl:SetText(labelText)
      end
      local function OnClick(self)
        UIDropDownMenu_SetSelectedValue(dd, self.value)
        if onChange then onChange(self.value) end
      end
      local function Init(self, level)
        local info
        for _, it in ipairs(items) do
          info = UIDropDownMenu_CreateInfo()
          info.text, info.value, info.func = it.text, it.value, OnClick
          info.checked = (UIDropDownMenu_GetSelectedValue(dd) == it.value)
          UIDropDownMenu_AddButton(info, level)
        end
      end
      UIDropDownMenu_Initialize(dd, Init)
      UIDropDownMenu_SetWidth(dd, 85)
      UIDropDownMenu_SetButtonWidth(dd, 160)
      UIDropDownMenu_SetSelectedValue(dd, items[defaultIndex or 1].value)
      UIDropDownMenu_JustifyText(dd, "LEFT")
      return dd
    end

    -- Receiver
    local list_guild_members = {
      {text="Group", value="Group"}, {text="Raid", value="Raid"}, {text="Guild", value="Guild"},
      {text="Sahnenugget", value="Sahnenugget"}, {text="Willywerkel", value="Willywerkel"},
      {text="Hexherr", value="Hexherr"}, {text="Penetraetor", value="Penetraetor"},
      {text="Herrow", value="Herrow"}, {text="Zapfhahn", value="Zapfhahn"},
    }
    local dd_receiver = CreateSimpleDropdown(frame, "DD_Receiver", line1, 0, -60, list_guild_members, 1, "Receiver")

    -- Sounds
    local list_sounds = {
      {text="Buff Mich", value="buff"}, {text="Heil Mich", value="heil"},
      {text="Hauueue", value="haue"}, {text="Houuaa", value="houa"},
      {text="Ku Ku Ku", value="kuku"}, {text="Pumpen 1", value="pump1"},
      {text="Pumpen 2", value="pump2"},
    }
    local dd_sound = CreateSimpleDropdown(frame, "DD_Sound", dd_receiver, 0, -60, list_sounds, 1, "Sound")

    -- Channel-Resolver
    local function ResolveChannelAndTarget(receiver)
      if receiver == "Group" then return "PARTY", nil end
      if receiver == "Raid"  then return "RAID",  nil end
      if receiver == "Guild" then return "GUILD", nil end
      return "WHISPER", receiver
    end

    -- Send-Button
    local btnSend = CreateFrame("Button", "NBM_SendBtn", frame, "UIPanelButtonTemplate")
    btnSend:SetSize(120, 30)
    btnSend:SetPoint("BOTTOM", 0, 20)
    btnSend:SetText("Send")
    btnSend:SetScript("OnClick", function()
      local receiver = UIDropDownMenu_GetSelectedValue(dd_receiver)
      local soundKey = UIDropDownMenu_GetSelectedValue(dd_sound)
      if not receiver or not soundKey then
        print("|cffff5555NBM: Receiver oder Sound nicht gewählt.|r")
        return
      end
      local payload = "SND:" .. soundKey .. ".ogg"  -- oder .wav
      local channel, target = ResolveChannelAndTarget(receiver)
      SendAddonMessage("NBM", payload, channel, target)
      print(("Gesendet → %s via %s: %s"):format(receiver, channel, payload))
    end)

    -- Listener (einmal pro Modul)
    local listener = CreateFrame("Frame")
    listener:RegisterEvent("CHAT_MSG_ADDON")
    listener:SetScript("OnEvent", function(_, _, prefix, msg, _, sender)
      if prefix ~= "NBM" or type(msg) ~= "string" then return end
      local cmd, arg = msg:match("^(%w+):(.+)$")
      if cmd == "SND" and arg and arg ~= "" then
        local ok = PlaySoundFile("Interface\\AddOns\\NBM\\sounds\\" .. arg)
        print(("Empfangen von %s: %s | ok=%s"):format(sender, msg, tostring(ok)))
      end
    end)

    frame:Hide()
  end

  -- öffentliche API
  function NBM.Modules.Soundboard.Show()
    BuildFrame()
    frame:Show()
  end
end
