NBM = NBM or {}; NBM.Modules = NBM.Modules or {}
NBM.Modules.Options = NBM.Modules.Options or {}

local frame

local function Build()
  if frame then return end
  frame = CreateFrame("Frame", "NBM_Options", UIParent, "BackdropTemplate")
  frame:SetSize(360, 260)
  frame:SetPoint("CENTER")
  frame:SetBackdrop({
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
    tile=true, tileSize=32, edgeSize=32,
    insets={left=8,right=8,top=8,bottom=8}
  })
  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 6, 6)
  close:SetScript("OnClick", function() frame:Hide() end)

  local t = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  t:SetPoint("TOPLEFT", 12, -12); t:SetText("NBM Optionen")
end

function NBM.Modules.Options.Show() Build(); frame:Show() end
