NBM = NBM or {}; NBM.Modules = NBM.Modules or {}
NBM.Modules.Soundboard = NBM.Modules.Soundboard or {}

local WIDTH, HEIGHT = 200, 300
local frame, tabs, pages = nil, {}, {}

local ACTIVE   = { r=0.20, g=0.60, b=1.00 }
local INACTIVE = { r=0.30, g=0.30, b=0.30 }
local HOVER    = { r=0.50, g=0.50, b=0.50 }

local function SelectTab(id)
  for i=1,#tabs do
    local active = (i==id)
    tabs[i]._active = active
    tabs[i].bg:SetVertexColor(active and ACTIVE.r or INACTIVE.r,
                              active and ACTIVE.g or INACTIVE.g,
                              active and ACTIVE.b or INACTIVE.b, 1)
    if active then
      pages[i]:Show()
      if pages[i]._onshow then pages[i]._onshow(pages[i]) end
    else
      pages[i]:Hide()
    end
  end
end

local function BuildFrame()
  if frame then return end
  frame = CreateFrame("Frame", "NBM_Soundboard", UIParent)
  frame:SetSize(WIDTH, HEIGHT)
  frame:SetPoint("RIGHT")
  frame:EnableMouse(true); frame:SetMovable(true); frame:SetClampedToScreen(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 6, 6)
  close:SetScript("OnClick", function() frame:Hide() end)

  local bg = frame:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(); bg:SetTexture(0.4,0.4,0.4,1)

  -- Tabs
  local labels = {"Board", "Config", "Alle Sounds"}
  for i,text in ipairs(labels) do
    local tab = CreateFrame("Button", "NBM_Tab"..i, frame)
    tab:SetID(i)
    tab:SetSize(WIDTH/3, 32)
    tab:SetPoint("TOPLEFT", frame, "TOPLEFT", (WIDTH/3)*(i-1), -20)

    local tbg = tab:CreateTexture(nil, "BACKGROUND")
    tbg:SetAllPoints(); tbg:SetTexture(0.5,0.5,0.5,1)
    tab.bg = tbg

    tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tab.text:SetPoint("CENTER"); tab.text:SetText(text)

    tab:SetScript("OnClick", function() SelectTab(i) end)
    tab:SetScript("OnEnter", function(self) if not self._active then self.bg:SetVertexColor(HOVER.r,HOVER.g,HOVER.b,1) end end)
    tab:SetScript("OnLeave", function(self) if not self._active then self.bg:SetVertexColor(INACTIVE.r,INACTIVE.g,INACTIVE.b,1) end end)
    tabs[i] = tab
  end

  -- Pages
  for i=1,#tabs do
    local p = CreateFrame("Frame", nil, frame)
    p:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -24)
    p:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    pages[i] = p
  end

  -- Inhalte aus Tab-Modulen aufbauen
  if NBM.Tabs and NBM.Tabs.Board  and NBM.Tabs.Board.Build  then NBM.Tabs.Board.Build(pages[1])  end
  if NBM.Tabs and NBM.Tabs.Config and NBM.Tabs.Config.Build then NBM.Tabs.Config.Build(pages[2]) end
  if NBM.Tabs and NBM.Tabs.AllSounds and NBM.Tabs.AllSounds.Build then NBM.Tabs.AllSounds.Build(pages[3]) end

  SelectTab(1)

  -- Addon-Kommunikation Listener (Beispiel)
  local listener = CreateFrame("Frame")
  listener:RegisterEvent("CHAT_MSG_ADDON")
  listener:SetScript("OnEvent", function(_, _, prefix, msg, _, sender)
    if prefix ~= "NBM" or type(msg) ~= "string" then return end
    local cmd, arg = msg:match("^(%w+):(.+)$")
    if cmd == "SND" and arg and arg ~= "" then
      local ok = PlaySoundFile("Interface\\AddOns\\NBM\\sounds\\"..arg)
      print(("Empfangen von %s: %s | ok=%s"):format(sender, msg, tostring(ok)))
    end
  end)

  frame:Hide()
end

function NBM.Modules.Soundboard.Show()   BuildFrame(); frame:Show() end
function NBM.Modules.Soundboard.Hide()   if frame then frame:Hide() end end
function NBM.Modules.Soundboard.Toggle() BuildFrame(); if frame:IsShown() then frame:Hide() else frame:Show() end end
