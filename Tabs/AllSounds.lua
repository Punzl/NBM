NBM = NBM or {}; NBM.Tabs = NBM.Tabs or {}; NBM.Tabs.AllSounds = {}

function NBM.Tabs.AllSounds.Build(parent)
  local t = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  t:SetPoint("TOPLEFT", 12, -12); t:SetText("Debug: Alle Sounds")
end
