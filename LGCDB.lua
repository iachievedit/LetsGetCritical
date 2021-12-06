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

    LGC_AccountDB.loginCount = LGC_AccountDB.loginCount + 1  
    LGC_CharacterDB.loginCount = LGC_CharacterDB.loginCount + 1

    print("You've logged in "..LGC_AccountDB.loginCount.." times")
    print(UnitName("Player").." logged in "..LGC_CharacterDB.loginCount.." times")
end

function LGCritical:SetDefaults()

  print("SetDefaults")

  if not LGC_AccountDB then 
  	LGC_AccountDB = {
      loginCount = 0
    }
    print("Global Initialized")
  end

  if not LGC_CharacterDB then 
    LGC_CharacterDB = {
      loginCount = 0
    }
    print("Character Initialized")
  end

  if not LGC_CharacterDB.rangeDamage then
    LGC_CharacterDB.rangeDamage = {}
  end

  if not LGC_CharacterDB.spellDamage then
    LGC_CharacterDB.spellDamage = {}
  end

  if not LGC_CharacterDB.critSpellDamage then
    LGC_CharacterDB.critSpellDamage = {}
  end
end

