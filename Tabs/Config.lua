-- Tabs/Config.lua
NBM = NBM or {}; NBM.Tabs = NBM.Tabs or {}; NBM.Tabs.Config = {}

-- Datenmodell: Kategorie -> Liste von Sounds (text = Label, value = Sound-Key/Dateiname)
local CATEGORIES = {
  ["Allgemein"] = {
    {text="Aaah", value="aaah"}, {text="Areh", value="areh"}, {text="Aueh", value="aueh"},
    {text="Buff Mich", value="buff"}, {text="Hi", value="hi"}, {text="Hilfe", value="hilfe"},
  },
  ["China"] = {
    {text="China1", value="china1"}, {text="China2", value="china2"},
    {text="China3", value="china3"}, {text="China4", value="china4"},
  },
  ["Klingeln"] = {
    {text="Klingeln 1", value="klingeln1"}, {text="Klingeln 2", value="klingeln2"},
  },
  ["NBM"] = {
    {text="NBM1", value="nbm1"}, {text="NBM2", value="nbm2"}, {text="NBM3", value="nbm3"},
  },
}

-- SavedVariables: NBM_Saved.bindings[i] = { cat="Allgemein", sound="aaah" }
local function EnsureSaved()
  NBM_Saved = NBM_Saved or {}
  NBM_Saved.bindings = NBM_Saved.bindings or {}
  for i=1,12 do
    if not NBM_Saved.bindings[i] then
      -- Default: erste Kategorie + erster Sound
      local firstCat = next(CATEGORIES)
      local firstSound = CATEGORIES[firstCat][1].value
      NBM_Saved.bindings[i] = { cat = firstCat, sound = firstSound }
    end
  end
end

-- Public API für Board
NBM.Modules = NBM.Modules or {}
NBM.Modules.Config = NBM.Modules.Config or {}
function NBM.Modules.Config.GetBinding(index)
  EnsureSaved()
  local b = NBM_Saved.bindings[index]
  return b and b.cat, b and b.sound
end

-- ---------- Dropdown-Helper (farbig, ohne Blizzard-Texturen) ----------
local function CreateColoredDropdown(parent, name, x, y, width, itemsProvider, getValue, setValue)
  local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
  dd:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  UIDropDownMenu_SetWidth(dd, width or 120)
  UIDropDownMenu_SetButtonWidth(dd, (width or 120) + 30)
  UIDropDownMenu_JustifyText(dd, "LEFT")

  local btn   = _G[name.."Button"]
  local text  = _G[name.."Text"]
  local left  = _G[name.."Left"]
  local mid   = _G[name.."Middle"]
  local right = _G[name.."Right"]
  if left then left:Hide() end; if mid then mid:Hide() end; if right then right:Hide() end

  local bg = dd:CreateTexture(nil, "BACKGROUND")
  bg:SetPoint("TOPLEFT",  16, -2)
  bg:SetPoint("BOTTOMRIGHT", -16, 2)
  bg:SetTexture(0.20, 0.30, 0.40, 1)

  local border = dd:CreateTexture(nil, "BORDER")
  border:SetPoint("TOPLEFT", 15, -1)
  border:SetPoint("BOTTOMRIGHT", -15, 1)
  border:SetTexture(0, 0, 0, 1)

  ---local arrow = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
 --- arrow:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
 --- arrow:SetText("▾")

  btn:SetScript("OnEnter", function() bg:SetTexture(0.30, 0.50, 0.70, 1) end)
  btn:SetScript("OnLeave", function() bg:SetTexture(0.20, 0.30, 0.40, 1) end)
  btn:SetScript("OnMouseDown", function() bg:SetTexture(0.12, 0.22, 0.32, 1) end)
  btn:SetScript("OnMouseUp", function()
    if btn:IsMouseOver() then bg:SetTexture(0.30,0.50,0.70,1) else bg:SetTexture(0.20,0.30,0.40,1) end
  end)

  text:ClearAllPoints(); text:SetPoint("LEFT", dd, "LEFT", 22, 2)

  local function Init(self, level)
    local items = itemsProvider()
    for _, it in ipairs(items) do
      local info = UIDropDownMenu_CreateInfo()
      info.text  = it.text
      info.value = it.value
      info.func  = function()
        UIDropDownMenu_SetSelectedValue(dd, it.value)
        setValue(it.value)
      end
      info.checked = (getValue() == it.value)
      UIDropDownMenu_AddButton(info, level)
    end
  end

  UIDropDownMenu_Initialize(dd, Init)
  UIDropDownMenu_SetSelectedValue(dd, getValue())

  -- Externe Refresh-Funktion, falls Items sich ändern
  function dd:Refresh()
    UIDropDownMenu_Initialize(dd, Init)
    UIDropDownMenu_SetSelectedValue(dd, getValue())
  end

  return dd
end
-- ---------------------------------------------------------------------

function NBM.Tabs.Config.Build(parent)
  EnsureSaved()

  local rows = 12
  local startX, startY = 4, -30
  local rowH, gapY = 12, 6
  local colCatX, colSndX = startX + 20, startX + 100
  local ddW = 60

  for i = 1, rows do
    local y = startY - (i-1)*(rowH + gapY)

    -- Label "Btn i"
    local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", parent, "TOPLEFT", startX, y - 10)
    lbl:SetText(("Btn %d"):format(i))

    -- Vor-Deklaration
    local ddSnd

    -- Getter/Setter für SavedVariables dieses Slots
    local function getCat()  return NBM_Saved.bindings[i].cat end
    local function setCat(v)
      NBM_Saved.bindings[i].cat = v
      -- bei Kategoriewechsel Sound auf ersten der neuen Kategorie setzen
      local sounds = CATEGORIES[v]
      if sounds and sounds[1] then
        NBM_Saved.bindings[i].sound = sounds[1].value
      else
        NBM_Saved.bindings[i].sound = nil
      end
      if ddSnd and ddSnd.Refresh then
        ddSnd:Refresh()
      end
    end
    local function getSnd()  return NBM_Saved.bindings[i].sound end
    local function setSnd(v) NBM_Saved.bindings[i].sound = v end

    -- Provider-Funktionen
    local function catItems()
      local out = {}
      for cat,_ in pairs(CATEGORIES) do table.insert(out, {text=cat, value=cat}) end
      table.sort(out, function(a,b) return a.text < b.text end)
      return out
    end
    local function sndItems()
      local cat = getCat()
      return CATEGORIES[cat] or {}
    end

    -- Kategorie-Dropdown
    local ddCat = CreateColoredDropdown(
      parent, "NBM_Config_Cat"..i,
      colCatX, y-2, ddW,
      catItems, getCat,
      function(v) setCat(v) end
    )

    -- Sound-Dropdown (abhängig von Kategorie)
    ddSnd = CreateColoredDropdown(
      parent, "NBM_Config_Snd"..i,
      colSndX, y-2, ddW,
      sndItems, getSnd,
      function(v) setSnd(v) end
    )
  end
end

