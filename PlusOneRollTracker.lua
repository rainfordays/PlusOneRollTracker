local _, core = ...


core.framepool = {}
core.currentRollItem = ""

core.defaults = {
  addonColor = "ea00ff",
  addonPrefix = "|cffea00ffPlusOneRollTracker|r"
}

ROLLFRAME_HEIGHT = 15
ROLLFRAME_HIDDEN_HEIGHT = 0


-- SORT FUNCTIONS
function sortRegular(a, b)
  return a.roll > b.roll
end

function sortPlusOne(a, b)
  return (a.plusone < b.plusone) or (a.plusone == b.plusone and a.roll > b.roll)
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
  core:Update()
end


-- CLEAR ROLLS
function core:ClearRolls()
  PORTDB.rolls = {}
  core:Update()
end

-- IGNORE ROLL
function core:IgnoreRoll(name)
  for i, player in ipairs(PORTDB.rolls) do
    if player.name == name then
      player.roll = 0
    end
  end
end

-- CLASS COLOR TEXT
function core:ClassColorText(text, class)
  local string = "|cFF"..core.ClassColors[class]..text.."|r"
  return string
end

-- UPDATE
function core:Update()

  scrollChildren = { core.addon.scrollChild:GetChildren() }

  for i, frame in ipairs(scrollChildren) do
    if frame.isHelper == false then
      frame:Hide()
      frame.used = false
    end
  end
  local rolltable = PORTDB.rolls
  if PORTDB.usePlusOne then
    table.sort(rolltable, sortPlusOne)
  else
    table.sort(rolltable, sortRegular)
  end



  for i, player in ipairs(PORTDB.rolls) do
    for ii, frame in ipairs(scrollChildren) do
      if not frame.used then
        local coloredName = core:ClassColorText(player.name, player.class)
        local name = player.name
        frame:SetHeight(ROLLFRAME_HEIGHT)
        frame.name:SetText(coloredName)
        frame.roll:SetText(player.roll)
        frame.plusone:SetText(PORTDB.plusOne[player.name] and "+"..PORTDB.plusOne[player.name] or "")
        
        frame.class:SetText(core.ClassIcons[player.class])
        frame.used = true
        frame:Show()
        break
      end
    end
  end

end





----------------------------
---- EVENTS
----------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("CHAT_MSG_SYSTEM")
events:RegisterEvent("CHAT_MSG_RAID_WARNING")
events:RegisterEvent("CHAT_MSG_RAID")
events:RegisterEvent("LOOT_OPENED")
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


function events:ADDON_LOADED(name)
  if name ~= "PlusOneRollTracker" then return end

  if PlusOneRollTrackerDB == nil then PlusOneRollTrackerDB = {} end
  PORTDB = PlusOneRollTrackerDB

  if PORTDB.rolls == nil then PORTDB.rolls = {} end
  if PORTDB.usePlusOne == nil then PORTDB.usePlusOne = false end
  if PORTDB.monstersLooted == nil then PORTDB.monstersLooted = {} end
  if PORTDB.plusOne == nil then PORTDB.plusOne = {} end


  local f=InterfaceOptionsFrame
  f:SetMovable(true)
  f:EnableMouse(true)
  f:SetUserPlaced(true)
  f:SetScript("OnMouseDown", f.StartMoving)
  f:SetScript("OnMouseUp", f.StopMovingOrSizing)


  SLASH_PLUSONEROLLTRACKER1= "/+1"
  SLASH_PLUSONEROLLTRACKER2= "/plusone"
  SlashCmdList.PLUSONEROLLTRACKER = function(msg)
    core:SlashCommand(msg)
  end
  core:Print(core.defaults.addonPrefix .. " by |cffFFF569Mayushi|r on |cffff0000Gehennas|r. /+1 or /plusone to open addon.")
end


function events:CHAT_MSG_SYSTEM(msg)
  local pattern = RANDOM_ROLL_RESULT
  pattern = pattern:gsub("%(", "%%(")
  pattern = pattern:gsub("%)", "%%)")
  pattern = pattern:gsub("%%s", "(.+)")
  pattern = pattern:gsub("%%d", "(%%d+)")

  local name, roll, min, high = string.match(msg, pattern)

  if name then
    core:Show()
    for i, player in ipairs(PORTDB.rolls) do
      if player.name == name then
        PORTDB.rolls[i].roll = 0
        core:Update()
        return
      end
    end
    roll = tonumber(roll)
    min = tonumber(min)
    high = tonumber(high)
    

    if min == 1 and high == 100 then
      local _, class = UnitClass(name);

      local temp = {}
      temp.name = name
      temp.roll = roll
      temp.class = class
      temp.plusone = PORTDB.plusOne[name] or 0

      tinsert(PORTDB.rolls, temp)
    end
    core:Update()
  end
end


function events:CHAT_MSG_RAID_WARNING(msg, author)
  local itemLinkPattern = "item:(%d+).+%[.+%]"
  local plusOnePattern = "%+1$"
  local itemID = tonumber(string.match(msg, itemLinkPattern))
  

  if string.find(msg, itemLinkpattern) then
    local itemName, itemLink, itemRarity = GetItemInfo(itemID)
    core.currentRollItem = itemLink

    if string.find(msg, plusOnePattern) then
      PORTDB.usePlusOne = true
      core.addon.plusoneCB:SetChecked(true)
      core:ClearRolls()
      core:Show()

    else
      PORTDB.usePlusOne = false
      core.addon.plusoneCB:SetChecked(false)
      core:ClearRolls()
      core:Show()
    end

  end
end


function events:CHAT_MSG_RAID(msg, author)
  passPattern = "%^pass%$"
  local _, class = UnitClass(author);

  if string.find(msg, passPattern) ~= nil then
    for i, player in ipairs(PORTDB.rolls) do
      if player.name == author then
        PORTDB.rolls[i].roll = 0
        return
      end
    end

    temp = {}

    temp.roll = 0
    temp.name = author
    temp.class = class

    tinsert(PORTDB.rolls, temp)
  end
end

function events:LOOT_OPENED(autolootBool)
  local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()
  
  -- Only announce loot if loot method is masterlooter and the user of the addon is the masterlooter
  if lootmethod == "master" and masterlooterPartyID == 0 then 
    local guid = UnitGUID("TARGET")
    if monstersLooted[guid] == nil then -- Havn't looted this monster before
      monstersLooted[guid] = true
      local lootstring = ""
      for i = 1, GetNumLootItems() do
        local itemLink = GetLootSlotLink(i)
        local itemName, _, itemRarity = GetItemInfo(itemLink)
        if itemRarity == 4 or itemRarity == 5 then
          lootstring = lootstring..itemLink
        end
      end -- / forloop
      if #lootstring > 0 then
        SendChatMessage(lootstring ,"RAID")
      end
    end -- / monster not looted
  end -- / lootmethod = master and player is masterlooter
end





------------------------
----- Slash commands
----–––––---------------

function core:SlashCommand(args)
  local farg = select(1, args)
  if farg == "reset" then
    core:ResetData()
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

    if alt_key and control_key and button == "LeftButton" then
      core:ResetData()
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
  end)
  addon.clearBtn = clearBtn


  --[[
    local resetBtn = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
    resetBtn:SetPoint("RIGHT", clearBtn, "LEFT", -3)
    resetBtn:SetSize(45, 30)
    resetBtn:SetText("Reset")
    resetBtn:SetScript("OnClick", function(self, button)
      core:ResetData()
    end)
    addon.resetBtn = resetBtn

  ]]


  local plusoneCB = CreateFrame("CheckButton", nil, addon, "UICheckButtonTemplate")
  plusoneCB:SetSize(30,30)
  plusoneCB:SetPoint("BOTTOMLEFT", addon, "BOTTOMLEFT", 5, 5)
  plusoneCB:SetScript("OnClick", function(self, button) 
    PORTDB.usePlusOne = self:GetChecked()
    core:Update()
  end)
  plusoneCB:SetChecked(PORTDB.usePlusOne)
  addon.plusoneCB = plusoneCB

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



  -- ROLL FRAMES
  for i = 1, 40 do
    local childframes = { scrollChild:GetChildren() }

    local tempFrame = CreateFrame("Frame", nil, scrollChild)
    if #childframes == 0 then
      tempFrame:SetPoint("TOP", scrollChild, "TOP")
    else
      tempFrame:SetPoint("TOP", childframes[#childframes], "BOTTOM")
    end
    tempFrame:SetSize(scrollFrame:GetWidth(), ROLLFRAME_HEIGHT)
    tempFrame:Show()
    tempFrame:SetScript("OnMouseDown", function(self, button)
      
      if button == "LeftButton" then
        local name = string.match(self.name:GetText(), "%|.........(.+)%|r") -- Strip color string from name

        if PORTDB.usePlusOne then
          if PORTDB.plusOne[name] == nil then
            PORTDB.plusOne[name] = 1
          else
            PORTDB.plusOne[name] = PORTDB.plusOne[name]+1
          end
          self.plusone:SetText("+"..PORTDB.plusOne[name])
        end

        
        local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()
  
        if lootmethod == "master" and masterlooterPartyID == 0 then -- PLAYER is masterlooter
          if #core.currentRollItem > 0 then -- currently rolling on an item
            for li = 1, GetNumLootItems() do -- loop through lootwindow
              if LootSlotHasItem(li) then -- current slot has item
                lootSlotItemLink = GetLootSlotLink(li) -- get item info
                if lootSlotItemLink == core.currentRollItem then -- loot slot item is same as current roll item

                  for ci = 1, 40 do
                    if GetMasterLootCandidate(ci) == name then
                      GiveMasterLoot(li, ci)
                      return
                    end
                  end
                end -- / loot slot item is same as current roll item
              end
            end -- / loop through lootwindow
          end
        end


      elseif button == "RightButton" then
        local name = self.name:GetText()
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
      tempFrame.plusone = plusone



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
    local class = tempFrame:CreateFontString(nil, "OVERLAY")
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
    tempFrame.isHelper = false
    tempFrame:Hide()

    addon["rollFrame"..i] = frame

    tinsert(core.framepool, frame)
  end
  -- ROLL FRAMES END


  scrollFrame:SetScrollChild(scrollChild)
  local scrollChildren = { scrollChild:GetChildren() }
  scrollChild:SetSize(scrollFrame:GetWidth(), ( #scrollChildren * 15 ));


  addon:Hide()

  core.addon = addon
  return core.addon
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

core.ClassColors = {
  DRUID = "FF7D0A",
  HUNTER = "A9D271",
  MAGE = "40C7EB",
  PALADIN = "F58CBA",
  PRIEST = "FFFFFF",
  ROGUE = "FFF569",
  SHAMAN = "0070DE",
  WARLOCK = "8787ED",
  WARRIOR = "C79C6E"
}
