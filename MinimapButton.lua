local function CreateMinimapButton()
  local btn = CreateFrame("Button", "NBM_MinimapButton", Minimap)
  btn:SetSize(32, 32)
  btn:SetFrameStrata("MEDIUM")
  btn:SetFrameLevel(Minimap:GetFrameLevel() + 5)
  btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local icon = btn:CreateTexture(nil, "ARTWORK")
  icon:SetSize(18, 18)
  icon:SetPoint("CENTER")
  icon:SetTexture("Interface\\AddOns\\NBM\\img\\icon.tga")

  local border = btn:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetPoint("CENTER")
  border:SetSize(56, 56)

  -- Drag um die Minimap
  local angle = 200
  local function UpdatePosition()
    local r = (Minimap:GetWidth()/2) + 10
    btn:SetPoint("CENTER", Minimap, "CENTER", cos(angle)*r, sin(angle)*r)
  end
  btn:RegisterForDrag("LeftButton")
  btn:SetScript("OnDragStart", function()
    btn:SetScript("OnUpdate", function()
      local mx,my = GetCursorPosition()
      local cx,cy = Minimap:GetCenter()
      local s = Minimap:GetEffectiveScale()
      angle = math.deg(math.atan2(my/s - cy, mx/s - cx))
      UpdatePosition()
    end)
  end)
  btn:SetScript("OnDragStop", function() btn:SetScript("OnUpdate", nil) end)
  UpdatePosition()

  -- Menü
  local menuFrame = CreateFrame("Frame", "NBM_MinimapMenu", btn, "UIDropDownMenuTemplate")
  local function OpenMenu(anchor)
    local menu = {
      { text="NBM", isTitle=true, notCheckable=true },
      { text="Soundboard", notCheckable=true, func=function() NBM.Call("Modules.Soundboard.Show") end },
      { text="Optionen",   notCheckable=true, func=function() NBM.Call("Modules.Options.Show") end },
      { text="Reload UI",  notCheckable=true, func=ReloadUI },
      { text="Schließen",  notCheckable=true, func=CloseDropDownMenus },
    }
    EasyMenu(menu, menuFrame, anchor, 0, 0, "MENU", 2)
  end

  btn:SetScript("OnClick", function(self, button)
    if button == "RightButton" then OpenMenu(self) else NBM.Call("Modules.Soundboard.Show") end
  end)
  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("NBM")
    GameTooltip:AddLine("Links: Soundboard öffnen", 1,1,1)
    GameTooltip:AddLine("Rechts: Menü", 1,1,1)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", CreateMinimapButton)
