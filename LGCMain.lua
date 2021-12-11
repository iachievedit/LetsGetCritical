--[[
  Let's Get Critical

  Copyright 2021 iAchieved.it LLC

]]--

local addonName, addon = ...
local LGCritical = addon

local module = {}
local moduleName = "Main"
LGCritical[moduleName] = module

-- Imports
local clearCharacterStats = LGCritical.Database.clearCharacterStats

local damageTypes = {
  RANGE_DAMAGE = {
    title = "Range Damage"
  },
  RANGE_DAMAGE_CRITICAL = {
    title = "Critical Range Damage"
  },
  SPELL_DAMAGE = {
    title = "Spell Damage"
  },
  SPELL_DAMAGE_CRITICAL = {
    title = "Critical Spell Damage"
  },
  SPELL_PERIODIC_DAMAGE = {
    title = "Periodic Spell Damage"
  },
  PERIODIC_SPELL_DAMAGE_CRITICAL = {
    title = "Critical Periodic Spell Damage"
  }
}

SLASH_LGCRITICAL_STATS1 = "/lgcstats"
SLASH_LGCRITICAL_CLEAR1 = "/lgcclear"
SlashCmdList["LGCRITICAL_STATS"] = function(msg)

  for k,v in pairs(damageTypes) do
    damageTypeTitle = v.title
    damageFrame:AddMessage(damageTypeTitle, 1.0, 0.0, 0.0)
    if LGC_CharacterDB[k] then
      for key, value in pairs(LGC_CharacterDB[k]) do
        dmgString = key..":  "..value
        damageFrame:AddMessage(dmgString)
      end
    end
  end
end

SlashCmdList["LGCRITICAL_CLEAR"] = function(msg)
  print("Clearing character stats")
  clearCharacterStats()
end

local SPELL_DAMAGE  = 2
local SOURCE_GUID   = 4
local SPELL_ID      = 12
local SPELL_NAME    = 13
local DAMAGE_AMOUNT = 15
local CRITICAL      = 21


local eventFrame = CreateFrame("Frame", "LGC_Frame")

damageFrame = CreateFrame("MessageFrame", "LGC_Message_Frame", UIParent)

-- Eventually we need to allow this to move around
damageFrame:SetHeight(240)
damageFrame:SetWidth(240)
damageFrame:SetPoint("BOTTOMLEFT", UIParent, 0, 400)
damageFrame:SetFontObject("GameFontNormal")
damageFrame:SetMovable(true)
damageFrame:Show()

local playerGUID = UnitGUID("player")

eventFrame:Show()
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local function eventHandler(self, event, ...)

  local eventInfo = {CombatLogGetCurrentEventInfo()}
  local type       = eventInfo[SPELL_DAMAGE]
  local sourceGUID = eventInfo[SOURCE_GUID]

  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then

    -- Ignore events we didn't cause
    if (sourceGUID ~= playerGUID) then
      return
    end

    if (type == "RANGE_DAMAGE") or (type == "SPELL_DAMAGE") or (type == "SPELL_PERIODIC_DAMAGE") then

      local critTableKey = type.."_CRITICAL"
      if not LGC_CharacterDB[critTableKey] then
        LGC_CharacterDB[critTableKey] = {}
      end
      if not LGC_CharacterDB[type] then
        LGC_CharacterDB[type] = {}
      end

      local damageAmount = eventInfo[DAMAGE_AMOUNT]
      local critical     = eventInfo[CRITICAL]
      local spellName    = eventInfo[SPELL_NAME]

      -- Is this a crit?
      if (critical) then

        damageFrame:AddMessage("Let's Get Critical!", 1.0, 0.0, 0.0, 53, 5)
        PlaySoundFile("Interface\\AddOns\\LetsGetCritical\\Sounds\\Yo.mp3")

        if not LGC_CharacterDB[critTableKey][spellName] then
          damageFrame:AddMessage("First critical record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[critTableKey][spellName] = damageAmount
          return
        end

        -- Otherwise, we have a record, see if it's broken
        if (damageAmount > LGC_CharacterDB[critTableKey][spellName]) then
          damageFrame:AddMessage("New critical record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[critTableKey][spellName] = damageAmount
        end
      else -- Not critical
        if not LGC_CharacterDB[type][spellName] then
          damageFrame:AddMessage("First damage record ("..damageAmount..") for "..spellName)
          LGC_CharacterDB[type][spellName] = damageAmount
          return
        end

        -- Otherwise, we have a record, see if it's broken
        if damageAmount > LGC_CharacterDB[type][spellName] then
          damageFrame:AddMessage("New damage record ("..damageAmount..") for "..spellName.."!")
          LGC_CharacterDB[type][spellName] = damageAmount
        end
      end 
    end
  end
end

eventFrame:SetScript("OnEvent", eventHandler)

damageFrame:AddMessage("Let's Go!", 1.0, 0.0, 0.0, 53, 5)

