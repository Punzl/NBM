-- Lade-Check
local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96HelloWorld:|r "..tostring(msg))
end

-- Fensterbau
local frame
local function BuildFrame()
    if frame then return end
    frame = CreateFrame("Frame", "HelloWorldFrame", UIParent)
    frame:SetSize(200, 100)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left=8, right=8, top=8, bottom=8 }
    })


    local line1 = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    line1:SetPoint("TOPLEFT", 16, -16)
    line1:SetText("Test_String_1")

    local line2 = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    line2:SetPoint("TOPLEFT", line1, "BOTTOMLEFT", 0, -4)
    line2:SetText("Test_String_2")

    local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    cb:SetPoint("BOTTOMLEFT", 12, 12)
    local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    lbl:SetText("Aktiv")


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