-- Das Offizielle <Naga Bums Mich> Gilden Addon! Beachtlich!

local PREFIX = "NBM"

local message_target_name = "Hexherr"

-- Lade-Check
local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96HelloWorld:|r "..tostring(msg))
end

-- Fensterbau
local frame
local function BuildFrame()
    
    -- Early Exit
    if frame then return end
    
    -- Frame:
    frame = CreateFrame("Frame", "HelloWorldFrame", UIParent)
    frame:SetSize(400, 300)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left=8, right=8, top=8, bottom=8 }
    })


    -- Text Header
    local line1 = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    line1:SetPoint("TOP",frame, 0, -20)
    line1:SetText("Naga Bums Mich")

    -- Text paragraph
    local line2 = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    line2:SetPoint("TOP", line1, 0, -20)
    line2:SetText("Das Gilden-Addon")

    -- Image
    local img = frame:CreateTexture(nil, "BACKGROUND")
    img:SetAllPoints()
    img:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    img:SetTexCoord(0.1, 0.9, 0.1, 0.9) 

    -- Dropdown erstellen
    local dd = CreateFrame("Frame", "MyAddonDropDown", frame, "UIDropDownMenuTemplate")
    dd:SetPoint("CENTER", line2, 0, -40)

    -- Data
    local items = {
        {text = "Willywerkel", value = "Willywerkel"},
        {text = "Hexherr", value = "Hexherr"},
        {text = "Herrow", value ="Herrow"},
    }

    -- Auswahl-Handler
    local function OnClick(self)
        UIDropDownMenu_SetSelectedValue(dd, self.value)
        print("Gewählt:", self.value)
        end

    -- Initializer
    local function Init(self, level)
    local info
    for _, it in ipairs(items) do
        info = UIDropDownMenu_CreateInfo()
        info.text = it.text
        info.value = it.value
        info.func = OnClick
        info.checked = (UIDropDownMenu_GetSelectedValue(dd) == it.value)
        UIDropDownMenu_AddButton(info, level)
    end
    end

    UIDropDownMenu_Initialize(dd, Init)
    UIDropDownMenu_SetWidth(dd, 140)
    UIDropDownMenu_SetButtonWidth(dd, 160)
    UIDropDownMenu_SetSelectedValue(dd, items[1].value)
    UIDropDownMenu_JustifyText(dd, "LEFT")

    -- Checkbox
    local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    cb:SetPoint("BOTTOMLEFT", frame, 20, 20)
    local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    lbl:SetText("Ist Taminos Mutter eine Hure?")
    cb:SetScript("OnClick", function(self)
        if self:GetChecked() then
            print("Ja Sie ist eine Hure")
        else
            print("Jetzt ist Sie keine Hure")
        end
    end)


    -- Button
    local btn1 = CreateFrame("Button", "Btn1", frame, "UIPanelButtonTemplate")
    btn1:SetSize(120,30)
    btn1:SetPoint("Center", cb, 280, 0)
    btn1:SetText("Click Me")
    btn1:SetScript("OnClick", function(self,button,down)
        SendAddonMessage(PREFIX, "DEBUG:Hello", "WHISPER", UIDropDownMenu_GetSelectedValue(dd))
        print(UIDropDownMenu_GetSelectedValue(dd).." Button clicked")
        end)

    -- Empfang bei beiden Spielern
    local f = CreateFrame("Frame")
    f:RegisterEvent("CHAT_MSG_ADDON")
    f:SetScript("OnEvent", function(_, _, prefix, msg, channel, sender)
        if prefix ~= PREFIX then return end
        if msg == "DEBUG:Hello" then
            print("Empfangen von "..sender..": "..msg)
            end
        end)


    frame:Hide() -- erst per Slash zeigen

end

-- Nach Login initialisieren und Slash registrieren
local evt = CreateFrame("Frame")
evt:RegisterEvent("PLAYER_LOGIN")
evt:SetScript("OnEvent", function()
  BuildFrame()
  Print("geladen. Slash: /nbm show oder /nbm hide")

  -- /nbm commands

SLASH_NBM1 = "/nbm"
SlashCmdList["NBM"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "show" then
        frame:Show()
    
    elseif msg == "hide" then
        frame:Hide()

    elseif msg == "toggle" then
        if frame:IsShown() 
            then frame:Hide() 
        else frame:Show() 
        end
    
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96NBM:|r benutze /nbm show, /nbm hide oder /nbm toggle")
    end

    end
end)