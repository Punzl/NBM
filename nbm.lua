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
    
    -- Early Out
    if frame then return end
    
    -- Frame Main:
    frame = CreateFrame("Frame", "HelloWorldFrame", UIParent)
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
    -- Dragging
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing() end)

    -- (Optional) einfacher Hintergrund
    if frame.SetBackdrop then
    frame:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    tile = true, tileSize = 32, edgeSize = 32,
                    insets = { left=11, right=12, top=12, bottom=11 } })
    end

    -- Close-Button oben rechts
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() frame:Hide() end)

    -- Background
    local img = frame:CreateTexture(nil, "BACKGROUND")
    img:SetAllPoints()
    img:SetTexture("Interface\\AddOns\\NBM\\img\\logo.tga")
    img:SetTexCoord(0.4, 0.4, 0.4, 0.4) 

    -- Text Header
    local line1 = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    line1:SetPoint("TOP",frame, 0, -20)
    line1:SetText("Soundboard")

--#region DropDowns

    -- Helper-Funktion für Dropdowns
    local function CreateSimpleDropdown(parent, name, anchorFrame, x, y, items, defaultIndex, labelText, onChange)
    local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dd:SetPoint("CENTER", anchorFrame, "CENTER", x, y)

    -- Label über dem Dropdown
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
        info.text   = it.text
        info.value  = it.value
        info.func   = OnClick
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

    -- Receiver-Dropdown
    local list_guild_members = {
    {text = "Group", value = "Group"},
    {text = "Raid", value = "Raid"},
    {text = "Guild", value = "Guild"},
    {text = "Willywerkel", value = "Willywerkel"},
    {text = "Hexherr", value = "Hexherr"},
    {text = "Herrow", value = "Herrow"},
    }

    local dd_receiver = CreateSimpleDropdown(
    frame, "DD_Receiver", line1, 0, -60,
    list_guild_members, 1, "Receiver",
    function(val) print("Receiver gewählt:", val) end
    )

    -- Sound-Dropdown unter dem Receiver
    local list_sounds = {
    {text = "Header", value = "header"},
    {text = "Ding",   value = "ding"},
    {text = "Awooga", value = "awooga"},
    {text = "Sound4", value = "sound4"},
    }

    local dd_sound = CreateSimpleDropdown(
    frame, "DD_Sound", dd_receiver, 0, -60,
    list_sounds, 1, "Sound",
    function(val) print("Sound gewählt:", val) end
    )

--#region SEND (Button) AND RECEIVE

    -- Mapping für Receiver → Kanal/Target
    local function ResolveChannelAndTarget(receiver)
    if receiver == "Group"  then return "PARTY",   nil end
    if receiver == "Raid"   then return "RAID",    nil end
    if receiver == "Guild"  then return "GUILD",   nil end
    return "WHISPER", receiver  -- Spielername
    end

    -- SEND-Button
    local btnSend = CreateFrame("Button", "NBM_SendBtn", frame, "UIPanelButtonTemplate")
    btnSend:SetSize(120, 30)
    btnSend:SetPoint("BOTTOM", frame, 0, 20)
    btnSend:SetText("Send")
    btnSend:SetScript("OnClick", function()
    local receiver = UIDropDownMenu_GetSelectedValue(dd_receiver)
    local soundKey = UIDropDownMenu_GetSelectedValue(dd_sound)
    if not receiver or not soundKey then
        print("|cffff5555NBM: Receiver oder Sound nicht gewählt.|r")
        return
    end
    -- Dateiendung wählen: ".wav" oder ".ogg" je nach deiner Datei
    local payload = "SND:" .. soundKey .. ".ogg"

    local channel, target = ResolveChannelAndTarget(receiver)
    SendAddonMessage(PREFIX, payload, channel, target)
    print(string.format("Gesendet → %s via %s: %s", receiver, channel, payload))
    end)

    -- LISTENER
    local listener = CreateFrame("Frame")
    listener:RegisterEvent("CHAT_MSG_ADDON")
    listener:SetScript("OnEvent", function(_, _, prefix, msg, channel, sender)
    if prefix ~= PREFIX or type(msg) ~= "string" then return end
    local cmd, arg = msg:match("^(%w+):(.+)$")
    if cmd == "SND" and arg and arg ~= "" then
        local path = "Interface\\AddOns\\NBM\\sounds\\" .. arg
        local ok = PlaySoundFile(path)
        print(string.format("Empfangen von %s: %s | ok=%s", sender, msg, tostring(ok)))
    end
    end)

--#endregion


    frame:Hide() -- erst per Slash zeigen

end

-- Nach Login initialisieren und Slash registrieren
local evt = CreateFrame("Frame")
evt:RegisterEvent("PLAYER_LOGIN")
evt:SetScript("OnEvent", function()
  BuildFrame()
  Print("geladen. Slash: /nbm show oder /nbm hide")

--#region SlashCommands

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
--#endregion