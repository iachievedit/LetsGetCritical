-------------------------------------------------------------------------------
-- Title:  Let's Get Critical Main
-- Author: iachievedit
-------------------------------------------------------------------------------

local addonName, addon = ...
local LGCritical = addon

SLASH_LGCRITICAL_STATS1 = "/lgcstats"
SLASH_LGCRITICAL_CLEAR1 = "/lgcclear"
SlashCmdList["LGCRITICAL_STATS"] = function(msg)
  for key, value in pairs(LGC_CharacterDB.spellDamage) do
    print(key, value)
  end
end

SlashCmdList["LGCRITICAL_CLEAR"] = function(msg)

  print("clear")
  --LGCritical["Database"].SetDefaults()

end

local SPELL_DAMAGE  = 2
local SOURCE_GUID   = 4
local SPELL_ID      = 12
local SPELL_NAME    = 13
local DAMAGE_AMOUNT = 15
local CRITICAL      = 21


local eventFrame = CreateFrame("Frame", "LGC_Frame")
local playerGUID = UnitGUID("player")

eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

function LGCritical:handleRangeDamage(eventInfo)
  local damageAmount = eventInfo[DAMAGE_AMOUNT]
  --print("handleRangeDamage:  "..damageAmount)
end

function LGCritical:handleSpellPeriodicDamage(eventInfo)
  local damageAmount = eventInfo[DAMAGE_AMOUNT]
  local spellName    = eventInfo[SPELL_NAME]
  --print("handleSpellPeriodicDamage:  "..damageAmount.." from "..spellName)
end

local function eventHandler(self, event, ...)

  local eventInfo = {CombatLogGetCurrentEventInfo()}
  local type = eventInfo[SPELL_DAMAGE]
  local sourceGUID = eventInfo[SOURCE_GUID]

  --print(type)

  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then

    -- Ignore events we didn't cause
    if (sourceGUID ~= playerGUID) then
      return
    end

    if (type == "RANGE_DAMAGE") then
      LGCritical:handleRangeDamage(eventInfo)
    end

    if (type == "SPELL_PERIODIC_DAMAGE") then
      LGCritical:handleSpellPeriodicDamage(eventInfo)
    end

    if (type == "SPELL_DAMAGE") then

      local spellId   = eventInfo[SPELL_ID]
      local spellName = eventInfo[SPELL_NAME]
      local critical = eventInfo[CRITICAL]
      local damageAmount = eventInfo[DAMAGE_AMOUNT]

--      local spellId, spellName, spellSchool = select(12, eventInfo);
--      local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(15, ...);



      -- DEFAULT_CHAT_FRAME:AddMessage(spellName)

      if (critical) then
        DEFAULT_CHAT_FRAME:AddMessage(spellName.." critical for "..damageAmount)

        if not LGC_CharacterDB.critSpellDamage[spellName] then
          print("New critical record for "..spellName)
          LGC_CharacterDB.critSpellDamage[spellName] = damageAmount
          return
        end

        if (damageAmount > LGC_CharacterDB.critSpellDamage[spellName]) then
          print("New critical record for "..spellName.."!")
          LGC_CharacterDB.critSpellDamage[spellName] = damageAmount
        end
      else
        if not LGC_CharacterDB.spellDamage[spellName] then
          print("New record for "..spellName)
          LGC_CharacterDB.spellDamage[spellName] = damageAmount
          return
        end

        if (damageAmount > LGC_CharacterDB.spellDamage[spellName]) then
          print("New record for "..spellName.."!")
          LGC_CharacterDB.spellDamage[spellName] = damageAmount
        end
      end
    end
  end
end

eventFrame:SetScript("OnEvent", eventHandler)

print("Let's Get Critical!")

