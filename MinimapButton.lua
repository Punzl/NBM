local function CreateMinimapButton()
  local btn = CreateFrame("Button", "NBM_MinimapButton", Minimap)
  btn:SetSize(32, 32)
  btn:SetFrameStrata("MEDIUM")
  btn:SetFrameLevel(Minimap:GetFrameLevel() + 5)
  btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  -- Icon
  local icon = btn:CreateTexture(nil, "ARTWORK")
  icon:SetSize(18, 20)
  icon:SetPoint("CENTER")
  icon:SetTexture("Interface\\AddOns\\NBM\\img\\nbm_icon.tga")

  -- Border
  local border = btn:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetPoint("TOPLEFT")
  border:SetSize(56, 56)

  ------------------------------------------------------------------
  -- Dragging rund um die Minimap
  ------------------------------------------------------------------
  local angle = 200  -- Startwinkel in Grad, 0 = rechts, 90 = oben
  local function UpdatePosition()
    local radius = (Minimap:GetWidth()/2) + 10
    local x = cos(angle) * radius
    local y = sin(angle) * radius
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
  end

  btn:RegisterForDrag("LeftButton")
  btn:SetScript("OnDragStart", function() btn:SetScript("OnUpdate", function()
    local mx, my = GetCursorPosition()
    local cx, cy = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    mx, my = mx/scale, my/scale
    angle = math.deg(math.atan2(my - cy, mx - cx))
    UpdatePosition()
  end) end)
  btn:SetScript("OnDragStop", function() btn:SetScript("OnUpdate", nil) end)

  UpdatePosition() -- initial platzieren

  ------------------------------------------------------------------
  -- Kontextmenü via EasyMenu
  ------------------------------------------------------------------
  local menuFrame = CreateFrame("Frame", "NBM_MinimapMenu", btn, "UIDropDownMenuTemplate")
  local function OpenMenu(anchor)
    local menu = {
      { text = "NBM", isTitle = true, notCheckable = true },
      { text = "Soundboard", notCheckable = true,
        func = function() (NBM.Modules.Soundboard and NBM.Modules.Soundboard.Show or function() end)() end },
      { text = "Optionen", notCheckable = true,
        func = function() (NBM.Modules.Options and NBM.Modules.Options.Show or function() end)() end },
      { text = "Reload UI", notCheckable = true, func = ReloadUI },
      { text = "Schließen", notCheckable = true, func = function() CloseDropDownMenus() end },
    }
    EasyMenu(menu, menuFrame, anchor, 0, 0, "MENU", 2)
  end

  -- Linksklick = Soundboard, Rechtsklick = Menü
  btn:SetScript("OnClick", function(self, mouseButton)
    if mouseButton == "RightButton" then
      OpenMenu(self)
    else
      if NBM.Modules.Soundboard and NBM.Modules.Soundboard.Show then
        NBM.Modules.Soundboard.Show()
      else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555NBM: Soundboard fehlt.|r")
      end
    end
  end)

  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("NBM")
    GameTooltip:AddLine("Links: Soundboard öffnen", 1,1,1)
    GameTooltip:AddLine("Rechts: Menü", 1,1,1)
    GameTooltip:AddLine("Shift+Linksklick halten: verschieben", 1,1,0)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- nach Login erstellen
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function() CreateMinimapButton() end)
