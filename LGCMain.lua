-------------------------------------------------------------------------------
-- Title:  Let's Get Critical Main
-- Author: iachievedit
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Prevent tainting global _.
--local _

local SPELL_DAMAGE  = 2
local SPELL_NAME    = 13
local DAMAGE_AMOUNT = 15
local CRITICAL      = 21


-- Dynamically created frames for receiving events.
local eventFrame = CreateFrame("Frame", "LGCFrame")

--eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
--eventFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local function eventHandler(self, event, ...)

  --local arg1, arg2 = CombatLogGetCurrentEventInfo();
  local eventInfo = {CombatLogGetCurrentEventInfo()}
  local type = eventInfo[SPELL_DAMAGE]

  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then

    if (type=="SPELL_DAMAGE") then

      local spellName = eventInfo[SPELL_NAME]
      local critical = eventInfo[CRITICAL]
      local damageAmount = eventInfo[DAMAGE_AMOUNT]

--      local spellId, spellName, spellSchool = select(12, eventInfo);
--      local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(15, ...);

      DEFAULT_CHAT_FRAME:AddMessage(spellName)

      if (critical) then
        DEFAULT_CHAT_FRAME:AddMessage(spellName.." critical for "..damageAmount);
      end
    end
  end
end

eventFrame:SetScript("OnEvent", eventHandler);

print("Let's Get Critical!");

