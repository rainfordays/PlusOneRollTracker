local _, core = ...


core.framepool = {}
core.currentRollItem = ""
core.hiddenFrame = CreateFrame("Frame", nil, UIParent)
core.hiddenFrame:Hide()


core.defaults = {}
core.defaults.color = "FF69B4"
core.defaults.addonPrefix = "|cff".. core.defaults.color .."PlusOne RollTracker|r"

local function addonColor(text)
  return "|cff"..core.defaults.color..text.."|r "
end


-- SORT FUNCTIONS
local function sortRegular(a, b)
  return a.roll > b.roll
end

local function sortPlusOne(a, b)
  return (a.plusOne < b.plusOne) or (a.plusOne == b.plusOne and a.roll > b.roll)
end



-- PRINT
function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end

-- RESET DATA
function core:ResetData()
  PORTDB.rolls = {}
  PORTDB.usePlusOne = false
  PORTDB.monstersLooted = {}
  PORTDB.plusOne = {}
  core:Print("All " .. core.defaults.addonPrefix .. " data has been reset.")
end


-- PRUNE MONSTERS LOOTED
function core:PruneMonstersLooted()
  local time = time()
  time = (time/60)/60 -- time in hours

  for k, v in pairs(PORTDB.monstersLooted) do
    if PORTDB.monstersLooted[k]-time > 3 then PORTDB.monstersLooted[k] = nil end
  end
end



-- CLEAR ROLLS
function core:ClearRolls()
  PORTDB.rolls = {}
end

-- IGNORE ROLL
function core:IgnoreRoll(name)
  for _, player in ipairs(PORTDB.rolls) do
    if player.name == name then
      player.ignoreRoll = true
    end
  end
end

-- COLOR TEXT
function core:colorText(text, color)
  return "|cff".. core.colors[color] .. text.."|r"
end

core.colors = {
  ["common"] = "ffffff",
  ["uncommon"] = "1eff00",
  ["rare"] = "0070dd",
  ["epic"] = "a335ee",
  ["DRUID"] = "FF7D0A",
  ["HUNTER"] = "A9D271",
  ["MAGE"] = "40C7EB",
  ["PALADIN"] = "F58CBA",
  ["PRIEST"] = "FFFFFF",
  ["ROGUE"] = "FFF569",
  ["SHAMAN"] = "0070DE",
  ["WARLOCK"] = "8787ED",
  ["WARRIOR"] = "C79C6E"
}

-- UPDATE
function core:Update()

  for i, frame in ipairs(core.framepool) do
    frame:SetParent(core.hiddenFrame)
    frame.used = false
    frame.class:SetText("")
  end


  local rolltable = PORTDB.rolls
  if PORTDB.usePlusOne then
    table.sort(rolltable, sortPlusOne)
  else
    table.sort(rolltable, sortRegular)
  end



  for _, player in ipairs(PORTDB.rolls) do
    for _, frame in ipairs(core.framepool) do
      if not frame.used then
        local coloredName = core:colorText(player.name, player.class)
        frame:SetParent(core.addon.scrollChild)
        frame:SetHeight(15)
        frame.name:SetText(coloredName)
        frame.class:SetText(core.ClassIcons[player.class])
        frame.used = true
        frame:Show()
        if player.ignoreRoll then
          frame.roll:SetText(0)
          frame.plusOne:SetText("")
        else
          frame.roll:SetText(player.roll)
          if PORTDB.usePlusOne then
            frame.plusOne:SetText(PORTDB.plusOne[player.name] and "+"..PORTDB.plusOne[player.name] or "")
          else
            frame.plusOne:SetText("")
          end
        end
        break -- Break out of looking for an unused frame
      end
    end
  end

  local numFramesActive = 0
  for _, frame in ipairs(core.framepool) do
    if frame.used then numFramesActive = numFramesActive+1 end
  end

  core.addon.scrollChild:SetHeight(15*numFramesActive)

end



------------------------
----- Slash commands
----–––––---------------

function core:SlashCommand(args)
  local arg1 = select(1, args)
  local arg2 = select(2, args)

  -- RESET
  if arg1 == "reset" then
    core:ResetData()
    core:Update()

  -- STATS
  elseif arg1 == "stats" then
    if #PORTDB.plusOne > 0 then
      local temp = {}

      for k,v in pairs(PORTDB.plusOne) do
        tinsert(temp, k .. "+"..v)
      end
      table.sort(temp)

      core:Print(core.defauls.addonPrefix.." stats.")
      for _,v in ipairs(temp) do
        core:Print("    "..v)
      end

    else
      core:Print(core.defaults.addonPrefix .. " no stats to show.")
    end


  -- CONFIG
  elseif arg1 == "config" or arg1 == "options" or arg1 == "option" then
    InterfaceOptionsFrame_OpenToCategory(core.optionsPanel)
    InterfaceOptionsFrame_OpenToCategory(core.optionsPanel)

  -- HELP
  elseif arg1 == "help" then
    core:Print(addonColor("PlusOne RollTracker").." options")
    core:Print(addonColor("/plusone") .. " reset -- Reset addon data (Must be done at the start of each raid)")
    core:Print(addonColor("/plusone") .. " stats -- Shows current +1 stats")
    core:Print(addonColor("/plusone") .. " config -- Shows config panel")

  else
    core:Toggle()
  end
end


function core:Toggle()
  local menu = core.addon or core:CreateMenu()
  menu:SetShown(not menu:IsShown())
  core:Update()
end

function core:Show()
  local menu = core.addon or core:CreateMenu()
  menu:Show()
  core:Update()
end

function core:Hide()
  local menu = core.addon or core:CreateMenu()
  menu:Hide()
end

-----------------------
---- MAIN FRAME
-----------------------

function core:CreateMenu()
  local backdrop = {bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }}
  -- Frame
  local addon = CreateFrame("Frame", nil, UIParent)
  addon:SetSize(220, 300)
  addon:SetPoint("RIGHT", UIParent, "RIGHT", -20, 20)
  addon:SetBackdrop(backdrop)

  local title = addon:CreateFontString(nil, "OVERLAY")
  title:SetPoint("TOPLEFT", addon, "TOPLEFT", 10, -10)
  title:SetFontObject("GameFontNormal")
  title:SetText("+1 RollTracker")
  addon.title = title

  local closeBtn = CreateFrame("Button", nil, addon, "UIPanelCloseButton")
  closeBtn:SetSize(32,32)
  closeBtn:SetPoint("TOPRIGHT", addon, "TOPRIGHT", 1, 1)
  closeBtn:SetScript("OnClick", function(self, button)
    local alt_key = IsAltKeyDown()
    local shift_key = IsShiftKeyDown()
    local control_key = IsControlKeyDown()

    if alt_key and control_key and shift_key and (button == "LeftButton") then
      core:ResetData()
      core:Update()
    else
      self:GetParent():Hide()
    end
  end)
  addon.closeBtn = closeBtn

  local clearBtn = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
  clearBtn:SetPoint("BOTTOMRIGHT", addon, "BOTTOMRIGHT", -5, 5)
  clearBtn:SetSize(60, 30)
  clearBtn:SetText("Clear list")
  clearBtn:SetScript("OnClick", function(self, button)
    core:ClearRolls()
    core:Update()
  end)
  addon.clearBtn = clearBtn


  local plusoneCB = CreateFrame("CheckButton", nil, addon, "UICheckButtonTemplate")
  plusoneCB:SetSize(30,30)
  plusoneCB:SetPoint("BOTTOMLEFT", addon, "BOTTOMLEFT", 5, 5)
  plusoneCB:SetScript("OnClick", function(self, button) 
    PORTDB.usePlusOne = self:GetChecked()
    core:Update()
  end)
  plusoneCB:SetChecked(PORTDB.usePlusOne)
  addon.plusOneCB = plusoneCB

  local cbText = plusoneCB:CreateFontString(nil, "OVERLAY")
  cbText:SetPoint("LEFT", plusoneCB, "RIGHT", 3)
  cbText:SetFontObject("GameFontNormalSmall")
  cbText:SetText("+1 roll")
  addon.cbText = cbText



  local scrollFrame = CreateFrame("ScrollFrame", nil, addon, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 5, -7)
  scrollFrame:SetPoint("BOTTOMRIGHT", clearBtn, "TOPRIGHT", -24, 2)
  addon.scrollFrame = scrollFrame

  local scrollChild = CreateFrame("Frame")
  --scrollChild:SetWidth(scrollFrame:GetWidth())
  --scrollChild:SetHeight(1000)
  addon.scrollChild = scrollChild

  core:CreateRollFrames(addon)


  scrollFrame:SetScrollChild(scrollChild)
  scrollChild:SetWidth(scrollFrame:GetWidth());


  addon:Hide()

  core.addon = addon
  return core.addon
end


function core:CreateRollFrames(addon)

  for i = 1, 40 do
    local childframes = { core.hiddenFrame:GetChildren() }
    local lastChild = childframes[#childframes]

    local tempFrame = CreateFrame("Frame", nil, core.hiddenFrame)
    if i == 1 then
      tempFrame:SetPoint("TOP", addon.scrollChild, "TOP")
    else
      tempFrame:SetPoint("TOP", lastChild, "BOTTOM")
    end
    tempFrame:SetSize(addon.scrollFrame:GetWidth(), 15)
    tempFrame:Show()
    tempFrame:SetScript("OnMouseDown", function(self, button)
      local name = string.match(self.name:GetText(), "%|.........(.+)%|r") -- Strip color string from name

      -- ALT + LEFT CLICK
      if IsAltKeyDown() and (button == "LeftButton") then

        if PORTDB.usePlusOne then
          if PORTDB.plusOne[name] == nil then
            PORTDB.plusOne[name] = 1
          else
            PORTDB.plusOne[name] = PORTDB.plusOne[name]+1
          end
          self.plusOne:SetText("+"..PORTDB.plusOne[name])
        end

        local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()

        if lootmethod == "master" and masterlooterPartyID == 0 then -- PLAYER is masterlooter
          if core.currentRollItem ~= "" then -- currently rolling on an item
            for li = 1, GetNumLootItems() do -- loop through lootwindow
              if LootSlotHasItem(li) then -- current slot has item
                local lootSlotItemLink = GetLootSlotLink(li) -- get item info

                if lootSlotItemLink ~= nil then
                  local itemName = GetItemInfo(lootSlotItemLink)

                  if itemName == core.currentRollItem then -- loot slot item is same as current roll item
                    for ci = 1, 40 do -- for each person in raid
                      if GetMasterLootCandidate(li, ci) == name then
                        GiveMasterLoot(li, ci)
                        return
                      end
                    end
                  end -- / loot slot item is same as current roll item
                end
              end
            end -- / loop through lootwindow
          end
        end

      -- LEFT CLICK
      elseif button == "LeftButton" then
        if PORTDB.usePlusOne then
          if PORTDB.plusOne[name] == nil then
            PORTDB.plusOne[name] = 1
          else
            PORTDB.plusOne[name] = PORTDB.plusOne[name]+1
          end
          self.plusOne:SetText("+"..PORTDB.plusOne[name])
        end
        return
      -- RIGHT CLICK
      elseif button == "RightButton" then
        core:IgnoreRoll(name)
        core:Update()
      end
    end)


    local plusoneFrame = CreateFrame("Frame", nil, tempFrame)
      plusoneFrame:SetPoint("LEFT", tempFrame, "LEFT", 3)
      plusoneFrame:SetSize(20, 15)
    local plusone = tempFrame:CreateFontString(nil, "OVERLAY")
      plusone:SetFontObject("GameFontNormal")
      plusone:SetPoint("LEFT", plusoneFrame, "LEFT")
      plusone:SetText("")
      tempFrame.plusOne = plusone



    local rollFrame = CreateFrame("Frame", nil, tempFrame)
      rollFrame:SetPoint("LEFT", plusoneFrame, "RIGHT")
      rollFrame:SetSize(20, 15)
    local roll = tempFrame:CreateFontString(nil, "OVERLAY")
      roll:SetFontObject("GameFontNormal")
      roll:SetPoint("LEFT", rollFrame, "LEFT")
      roll:SetText("")
      tempFrame.roll = roll



    local classFrame = CreateFrame("Frame", nil, tempFrame)
      classFrame:SetPoint("LEFT", rollFrame, "RIGHT")
      classFrame:SetSize(20, 15)
    local class = classFrame:CreateFontString(nil, "OVERLAY")
      class:SetFontObject("GameFontNormal")
      class:SetPoint("LEFT", classFrame, "LEFT")
      class:SetText("")
      tempFrame.class = class



    local nameFrame = CreateFrame("Frame", nil, tempFrame)
      nameFrame:SetPoint("LEFT", classFrame, "RIGHT")
      nameFrame:SetSize(20, 15)
    local name = tempFrame:CreateFontString(nil, "OVERLAY")
      name:SetFontObject("GameFontNormal")
      name:SetPoint("LEFT", nameFrame, "LEFT")
      name:SetText("")
      tempFrame.name = name

    tempFrame.used = false
    tempFrame:Hide()

    tinsert(core.framepool, tempFrame)

  end
end



core.ClassIcons = {
  WARRIOR = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:0:64:0:64|t",
  MAGE = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:64:128:0:64|t",
  ROGUE = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:128:196:0:64|t",
  DRUID = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:196:256:0:64|t",
  HUNTER = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:0:64:64:128|t",
  SHAMAN = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:64:128:64:128|t",
  PRIEST = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:128:196:64:128|t",
  WARLOCK = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:196:256:64:128|t",
  PALADIN = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:0:64:128:196|t"
}
