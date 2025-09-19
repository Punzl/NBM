NBM = NBM or {}
NBM.Modules = NBM.Modules or {}

-- sichere Funktionsaufrufe: NBM.Call("Modules.Soundboard.Show")
function NBM.Call(path)
  local node = NBM
  for name in string.gmatch(path, "[^%.]+") do node = node and node[name] end
  if type(node) == "function" then node() else
    DEFAULT_CHAT_FRAME:AddMessage("|cffff5555NBM: Funktion fehlt ->|r "..path)
  end
end

-- Login-Info
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  local version = GetAddOnMetadata("NBM", "Version") or "dev"
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96NBM v"..version.." geladen. (/nbm)")
end)

-- /nbm toggle Soundboard
SLASH_NBM1 = "/nbm"
SlashCmdList.NBM = function()
  if NBM.Modules.Soundboard and NBM.Modules.Soundboard.Toggle then
    NBM.Modules.Soundboard.Toggle()
  else
    DEFAULT_CHAT_FRAME:AddMessage("|cffff5555NBM: Soundboard fehlt.|r")
  end
end
