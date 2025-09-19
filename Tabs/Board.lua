NBM = NBM or {}; NBM.Tabs = NBM.Tabs or {}; NBM.Tabs.Board = {}

local WIDTH, HEIGHT = 200, 300
local PREFIX = "NBM"

local function CreateSimpleDropdown(parent, name, anchorFrame, x, y, items, defaultIndex, labelText, onChange)
  local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
  dd:SetPoint("CENTER", anchorFrame, "CENTER", x, y)
  if labelText then
    local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("LEFT", dd, "LEFT", -40, 2)
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

-- Helper: Versenden je nach Receiver
local function SendSoundFromButton(idx, dd_receiver)
  local getBind = NBM.Modules and NBM.Modules.Config and NBM.Modules.Config.GetBinding
  local cat, sound = getBind and getBind(idx)
  if not sound or sound == "" then
    print("|cffff5555NBM:|r Kein Sound für Button "..idx)
    return
  end
  local sel = UIDropDownMenu_GetSelectedValue(dd_receiver)
  local channel, target
  if sel == "Group" then
    channel = "PARTY"
  elseif sel == "Raid" then
    channel = "RAID"
  elseif sel == "Guild" then
    channel = "GUILD"
  else
    channel, target = "WHISPER", sel
  end
  local payload = "SND:"..sound
  SendAddonMessage(PREFIX, payload, channel, target)
  print(string.format("NBM send -> %s%s : %s (Btn %d)", channel, target and ("->"..target) or "", payload, idx))
end

function NBM.Tabs.Board.Build(parent)
  local rows, cols = 4, 3
  local bw, bh    = (WIDTH / 3) - 2.5, HEIGHT / 8
  local spacing   = 2
  local startX, startY = 2, -60

  -- Receiver
  local list_guild_members = {
    {text="Group", value="Group"}, {text="Raid", value="Raid"}, {text="Guild", value="Guild"},
    {text="Sahnenugget", value="Sahnenugget"}, {text="Willywerkel", value="Willywerkel"},
    {text="Hexherr", value="Hexherr"}, {text="Penetraetor", value="Penetraetor"},
    {text="Herrow", value="Herrow"}, {text="Zapfhahn", value="Zapfhahn"},
  }
  local dd_receiver = CreateSimpleDropdown(parent, "DD_Receiver", parent, 30, 63, list_guild_members, 1, "SendTo: ")

  for r = 1, rows do
    for c = 1, cols do
      local idx = (r-1)*cols + c
      local btn = CreateFrame("Button", "NBM_BoardBtn"..idx, parent)
      btn:SetSize(bw, bh)
      btn:SetPoint("TOPLEFT", parent, "TOPLEFT",
                   startX + (c-1)*(bw+spacing),
                   startY - (r-1)*(bh+spacing))

      -- Rand (hinten, 1px)
      local border = btn:CreateTexture(nil, "BACKGROUND")
      border:SetPoint("TOPLEFT", -1, 1)
      border:SetPoint("BOTTOMRIGHT", 1, -1)
      border:SetTexture(0, 0, 0, 1)
      btn.border = border

      -- Hintergrund (vorn)
      local bg = btn:CreateTexture(nil, "ARTWORK")
      bg:SetAllPoints()
      bg:SetTexture(0.2, 0.3, 0.4, 1)
      btn.bg = bg

      -- Text
      btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      btn.text:SetPoint("CENTER")
      btn.text:SetText("Btn"..idx)

      -- Hover
      btn:SetScript("OnEnter", function(self) self.bg:SetTexture(0.3, 0.5, 0.7, 1) end)
      btn:SetScript("OnLeave", function(self) self.bg:SetTexture(0.2, 0.3, 0.4, 1) end)

      -- Klick + Versand
      btn:SetScript("OnMouseDown", function(self) self.bg:SetTexture(0.1, 0.2, 0.3, 1) end)
      btn:SetScript("OnMouseUp", function(self)
        if self:IsMouseOver() then
          self.bg:SetTexture(0.3, 0.5, 0.7, 1)
        else
          self.bg:SetTexture(0.2, 0.3, 0.4, 1)
        end
        SendSoundFromButton(idx, dd_receiver) -- hier wird gesendet
      end)
    end
  end
end
