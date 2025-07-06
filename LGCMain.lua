--[[
  Let's Get Critical

  Copyright 2024 iAchieved.it LLC

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
local moduleName = "LGCMain"
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

-- type is (record, critical, criticalrecord)
function playSound(type)

  -- Are sounds off?
  if LGC_CharacterDB.sounds == "off" then
    -- If so, do nothing
    return
  end

  -- Determine which clip to play
  local file = nil
  if LGC_CharacterDB.soundPreferences and LGC_CharacterDB.soundPreferences[type] then
    file = LGC_CharacterDB.soundPreferences[type]
  end

  if file then
    local path = "Interface\\AddOns\\LetsGetCritical\\Sounds\\" .. file
    PlaySoundFile(path)
  end

end

-- Commands
-- lgc clear
-- lgc stats
-- lgc sounds off|on
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
    elseif tbl[1] == "clips" then
      toggleSoundFrame()
    end
  end
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

local width = 240
local height = 120
local titleBarHeight = 20


-- Parent frame
parentFrame = CreateFrame("Frame", nil, UIParent)
parentFrame:SetSize(width,height)

-- This needs to be global
damageFrame = CreateFrame("ScrollingMessageFrame", "LGC_Message_Frame", parentFrame)

-- Create the title bar font string
local titleBar = damageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleBar:SetText("Let's Get Critical")
titleBar:SetPoint("TOP", damageFrame, "TOP", 0, -5)

-- Create a child frame for the actual messages
--messageContainer = CreateFrame("ScrollingMessageFrame", "nil", damageFrame)
--messageContainer:SetSize(width, height - titleBarHeight) -- Adjust the height to account for the title bar
--messageContainer:SetPoint("TOP", damageFrame, "TOP", 0, -titleBarHeight)

-- Apply the insets to the damageFrame
--damageFrame:SetClipsChildren(true) -- This ensures content doesn't overflow
--damageFrame:SetClampRectInsets(insetLeft, insetRight, insetTop, insetBottom)

-- Create button frame for resizing
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



local tex = damageFrame:CreateTexture(nil, "ARTWORK")
tex:SetAllPoints()
tex:SetColorTexture(0.1, 0.1, 0.1, 0.3)

damageFrame:SetHeight(120)
damageFrame:SetWidth(240)
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

-- Frame for selecting sounds
local soundFrame = CreateFrame("Frame", "LGC_SoundFrame", UIParent, "BasicFrameTemplateWithInset")
soundFrame:SetSize(260, 180)
soundFrame:SetPoint("CENTER")
soundFrame:Hide()

soundFrame.title = soundFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
soundFrame.title:SetPoint("CENTER", soundFrame.TitleBg, "CENTER", 0, 0)
soundFrame.title:SetText("Select Clips")

local soundOptions = {"Explosion.mp3", "HotDamn.mp3", "Sweet.mp3", "Yo.mp3"}
local dropDowns = {}

local function createDropDown(labelText, soundType, yOffset)
  local dd = CreateFrame("Frame", "LGC_DropDown_"..soundType, soundFrame, "UIDropDownMenuTemplate")
  dd:SetPoint("TOPLEFT", 20, yOffset)
  UIDropDownMenu_SetWidth(dd, 120)

  local label = soundFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", dd, "RIGHT", -10, 2)
  label:SetText(labelText)

  UIDropDownMenu_Initialize(dd, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for _, file in ipairs(soundOptions) do
      info.text = file
      info.value = file
      info.func = function(self)
        UIDropDownMenu_SetSelectedValue(dd, self.value)
        LGC_CharacterDB.soundPreferences[soundType] = self.value
      end
      UIDropDownMenu_AddButton(info)
    end
  end)

  UIDropDownMenu_SetSelectedValue(dd, LGC_CharacterDB.soundPreferences[soundType])
  dropDowns[soundType] = dd
end

createDropDown("Record", "record", -40)
createDropDown("Critical", "critical", -80)
createDropDown("Critical Record", "criticalrecord", -120)

local function toggleSoundFrame()
  if soundFrame:IsShown() then
    soundFrame:Hide()
  else
    soundFrame:Show()
  end
end

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



