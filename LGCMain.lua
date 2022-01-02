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
damageFrame:SetPoint("BOTTOMLEFT", UIParent, 0, 400)
damageFrame:SetFontObject(GameFontNormal)
damageFrame:SetTextColor(GameFontNormal:GetTextColor())
damageFrame:SetMovable(true)
damageFrame:EnableMouse(true)
damageFrame:SetResizable(true)
damageFrame:RegisterForDrag("LeftButton")
damageFrame:SetInsertMode("TOP")
damageFrame:SetScript("OnDragStart", function(self)
  self:StartMoving()
--  print(self:GetLeft())
end)
damageFrame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
--  print(self:GetRight() - self:GetLeft())
end)

--[[
titleFrame = CreateFrame("Frame", nil, damageFrame)
titleFrame:SetPoint("TOPLEFT")
titleFrame:SetHeight(16)
titleFrame:SetWidth(parentFrame:GetWidth())

print(damageFrame:GetRight() - damageFrame:GetLeft())
titleFrame.Title = titleFrame:CreateFontString(nil,"ARTWORK")
titleFrame.Title:SetFont("GameFontNormal", 13, "OUTLINE")
titleFrame.Title:SetPoint("CENTER", 0,0)
titleFrame.Title:SetText("Let's Get Critical")
titleFrame.texture = titleFrame:CreateTexture(nil, "BACKGROUND")
titleFrame.texture:SetAllPoints()
titleFrame.texture:SetColorTexture(0.0, 0.0, 0.0, 0.5)
titleFrame:Show()
--]]

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

      -- Sound rules
      -- Yo! on any non-record crit
      -- Alright on first record crit
      -- Ooooh on new critical record

      -- Is this a crit?
      if (critical) then

        -- Play on any crit
        damageFrame:AddMessage("Let's Get Critical!", 1.0, 0.0, 0.0, 53, 5)

        if not LGC_CharacterDB[critTableKey][spellName] then
          damageFrame:AddMessage("First critical record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[critTableKey][spellName] = damageAmount
          PlaySoundFile("Interface\\AddOns\\LetsGetCritical\\Sounds\\HotDamn.mp3")
          return
        end

        -- Otherwise, we have a record, see if it's broken
        if (damageAmount > LGC_CharacterDB[critTableKey][spellName]) then
          damageFrame:AddMessage("New critical record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[critTableKey][spellName] = damageAmount
          PlaySoundFile("Interface\\AddOns\\LetsGetCritical\\Sounds\\HotDamn.mp3")
          return
        end

        -- Non-record crit
        PlaySoundFile("Interface\\AddOns\\LetsGetCritical\\Sounds\\Yo.mp3")
        damageFrame:AddMessage("Critical damage "..damageAmount.." for "..spellName.."!")

      else -- Not critical
        if not LGC_CharacterDB[type][spellName] then
          damageFrame:AddMessage("First damage record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[type][spellName] = damageAmount
          return
        end

        -- Otherwise, we have a record, see if it's broken
        if damageAmount > LGC_CharacterDB[type][spellName] then
          damageFrame:AddMessage("New damage record of "..damageAmount.." for "..spellName.."!")
          LGC_CharacterDB[type][spellName] = damageAmount
          PlaySoundFile("Interface\\AddOns\\LetsGetCritical\\Sounds\\Sweet.mp3")
        end
      end 
    end
  end
end

eventFrame:SetScript("OnEvent", eventHandler)

--damageFrame:AddMessage("Let's Go!", 1.0, 0.0, 0.0, 53, 5)

