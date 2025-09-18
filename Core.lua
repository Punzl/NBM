NBM = NBM or {}
NBM.Modules = NBM.Modules or {}

-- optionale Helper: sichere Funktionsaufrufe
function NBM.Call(path)
  local node = NBM
  for name in string.gmatch(path, "[^%.]+") do
    node = node and node[name]
  end
  if type(node) == "function" then node() else
    DEFAULT_CHAT_FRAME:AddMessage("|cffff5555NBM: Funktion fehlt ->|r "..path)
  end
end

-- Event-Frame für Login
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96NBM:|r Addon geladen. (/nbm für Optionen)")
end)

local version = GetAddOnMetadata("NBM", "Version") or "dev"
DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96NBM v"..version.." geladen.")