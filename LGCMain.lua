--[[
  Let's Get Critical

  Copyright 2021 iAchieved.it LLC

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

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
--  PERIODIC_SPELL_DAMAGE_CRITICAL = {
--    title = "Critical Periodic Spell Damage"
--  }
}

-- type is (record, critical, criticalrecord)
function playSound(type)

  --print(type)
  -- are sounds off?
  if LGC_CharacterDB.sounds == "off" then
    return
  end

  if type == "record" then
    PlaySoundFile("Interface\\AddOns\\LetsGetCritical\\Sounds\\Sweet.mp3")
  elseif type == "critical" then
    PlaySoundFile("Interface\\AddOns\\LetsGetCritical\\Sounds\\Yo.mp3")
  elseif type == "criticalrecord" then
    PlaySoundFile("Interface\\AddOns\\LetsGetCritical\\Sounds\\HotDamn.mp3")
  end

end

-- Commands
-- lgc clear
-- lgc stats
-- lgc sounds off|on|crit|record
-- lgc window off|on

SLASH_LGC1 = "/lgc"

function displayStats() 
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

SlashCmdList["LGC"] = function(msg)
  if msg == 'stats' then
    displayStats()
  elseif msg == 'clear' then
    clearCharacterStats()
  else
    print(msg)
    local tbl = { strsplit(" ", msg) }
    if tbl[1] == "window" then
      if tbl[2] == "off" then
        damageFrame:Hide()
      else
        damageFrame:Show()
      end
    elseif tbl[1] == "sounds" then
      if tbl[2] == "off" then
        LGC_CharacterDB.sounds = "off"
      elseif tbl[2] == "on" then
        LGC_CharacterDB.sounds = "on"
      end
    end
  end
  --print(LGC_CharacterDB.sounds)
end

-- Indexes into CombatLog
local SPELL_DAMAGE  = 2
local SOURCE_GUID   = 4
local SPELL_ID      = 12
local SPELL_NAME    = 13
local DAMAGE_AMOUNT = 15
local CRITICAL      = 21

-- Only for events
local eventFrame = CreateFrame("Frame", "LGC_Frame")

-- Parent frame
parentFrame = CreateFrame("Frame", nil, UIParent)
parentFrame:SetSize(120,240)

-- This needs to be global
damageFrame = CreateFrame("ScrollingMessageFrame", "LGC_Message_Frame", parentFrame)
br = CreateFrame("Button", nil, damageFrame)
br:EnableMouse(true)
br:SetPoint("BOTTOMRIGHT")
br:SetSize(16, 16)
br:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
br:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
br:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
br:SetScript("OnMouseDown", function(self)
  self:GetParent():StartSizing("BOTTOMRIGHT")
end)
br:SetScript("OnMouseUp", function(self)
  self:GetParent():StopMovingOrSizing()
end)

local tex = damageFrame:CreateTexture(nil, "BACKGROUND")
tex:SetAllPoints()
tex:SetColorTexture(0.1, 0.1, 0.1, 0.3)

damageFrame:SetHeight(120)
damageFrame:SetWidth(240)
damageFrame:SetMinResize(80,120)
damageFrame:SetMaxResize(480,960)
damageFrame:SetPoint("CENTER", UIParent, 0, 0)
damageFrame:SetFontObject(GameFontNormal)
damageFrame:SetTextColor(GameFontNormal:GetTextColor())
damageFrame:SetMovable(true)
damageFrame:EnableMouse(true)
damageFrame:SetResizable(true)
damageFrame:RegisterForDrag("MiddleButton")
damageFrame:SetInsertMode("TOP")
damageFrame:SetScript("OnDragStart", function(self)
  self:StartMoving()
end)
damageFrame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
end)

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

        -- Play on any crit
        damageFrame:AddMessage("Let's Get Critical!", 1.0, 0.0, 0.0, 53, 5)

        if not LGC_CharacterDB[critTableKey][spellName] then
          damageFrame:AddMessage("First critical record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[critTableKey][spellName] = damageAmount

          playSound("criticalrecord")

          return
        end

        -- Otherwise, we have a record, see if it's broken
        if (damageAmount > LGC_CharacterDB[critTableKey][spellName]) then
          damageFrame:AddMessage("New critical record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[critTableKey][spellName] = damageAmount

          playSound("criticalrecord")

          return
        end

        -- Non-record crit
        playSound("critical")

        damageFrame:AddMessage("Critical damage "..damageAmount.." for "..spellName.."!")

      else -- Not critical
        if not LGC_CharacterDB[type][spellName] then
          damageFrame:AddMessage("First damage record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[type][spellName] = damageAmount
          playSound("record")
          return
        end

        -- Otherwise, we have a record, see if it's broken
        if damageAmount > LGC_CharacterDB[type][spellName] then
          damageFrame:AddMessage("New damage record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[type][spellName] = damageAmount

          playSound("record")

        end
      end 
    end
  end
end

eventFrame:SetScript("OnEvent", eventHandler)



