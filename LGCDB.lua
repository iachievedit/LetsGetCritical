-- LGCDB.lua
-------------------------------------------------------------------------------
-- Title:  Let's Get Critical Main
-- Author: iachievedit
-------------------------------------------------------------------------------

local addonName, addon = ...
local LGCritical = addon

-- Create module and set its name.
local module = {}
local moduleName = "Database"
LGCritical[moduleName] = module

local frame = CreateFrame("Frame", "LGCDB")

frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(this, event, ...)
    LGCritical[event](LGCritical, ...)
end)

function LGCritical:PLAYER_LOGIN()
    self:SetDefaults()
end

function LGCritical:SetDefaults()
  if not LGC_AccountDB then 
  	LGC_AccountDB = {
      loginCount = 0
    }
  end

  if not LGC_CharacterDB then 
    LGC_CharacterDB = {}
  end
end

function clearCharacterStats()
  LGC_CharacterDB = {}
end

module.clearCharacterStats = clearCharacterStats
