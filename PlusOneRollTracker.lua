local _, core = ...

core.rolls = {}
core.framepool = {}
core.usePlusOne = true

core.defaults = {
  addonColor = "ea00ff",
  addonPrefix = "|cffea00ffPlusOneRollTracker|r "
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
  PORTDB = {}
end

-- CLEAR ROLLS
function core:ClearRolls()
  core.rolls = {}
  core:Update()
end

-- UPDATE
function core:Update()

  scrollChildren = { core.addon.scrollChild:GetChildren() }

  for i, frame in ipairs(scrollChildren) do
    if frame.isHelper == false then
      frame:SetHeight(ROLLFRAME_HIDDEN_HEIGHT)
      frame.used = false
    end
  end
  local rolltable = core.rolls
  if core.usePlusOne then
    table.sort(rolltable, sortPlusOne)
  else
    table.sort(rolltable, sortRegular)
  end



  for i, player in ipairs(core.rolls) do
    for ii, frame in ipairs(scrollChildren) do
      if not frame.used then
        frame:SetHeight(ROLLFRAME_HEIGHT)
        frame.name:SetText(player.name)
        frame.roll:SetText(player.roll)
        frame.plusone:SetText(PORTDB[name] or "")
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
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


function events:ADDON_LOADED(name)
  if name ~= "PlusOneRollTracker" then return end

  if PlusOneRollTrackerDB == nil then PlusOneRollTrackerDB = {} end
  PORTDB = PlusOneRollTrackerDB

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
  core:Print(core.defaults.addonPrefix .. "by |cffFFF569Mayushi|r on |cffff0000Gehennas|r. /+1 or /plusone to open addon.")
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
    roll = tonumber(roll)
    min = tonumber(min)
    high = tonumber(high)

    if min == 1 and high == 100 then
      local _, class = UnitClass(name);

      local temp = {}
      temp.name = name
      temp.roll = roll
      temp.class = class
      if PORTDB[name] ~= nil then temp.plusone = PORTDB[name] end

      tinsert(core.rolls, temp)
    end
    core:Update()
  end
end


function events:CHAT_MSG_RAID_WARNING(msg, author)
  itemLinkPattern = "%[.+%]"
  plusOnePattern = "%+1"

  if string.find(msg, itemLinkpattern) ~= nil then
    if string.find(msg, plusOnePattern) ~= nil then
      core.usePlusOne = true
      core:ClearRolls()
    else
      core.usePlusOne = false
      core:ClearRolls()
    end
  end
end


function events:CHAT_MSG_RAID(msg, author)
  passPattern = "%^pass%$"
  local _, class = UnitClass(author);

  if string.find(msg, passPattern) ~= nil then
    for i, player in ipairs(core.rolls) do
      if player.name == author then
        temp = {}

        temp.roll = 0
        temp.name = author
        temp.class = class

        core.rolls[i] = temp
        return
      end
    end

    temp = {}

    temp.roll = 0
    temp.name = author
    temp.class = class

    tinsert(core.rolls, temp)
  end
end






------------------------
----- Slash commands
----–––––---------------

function core:SlashCommand(args)
  local farg = select(1, args)
  core:Toggle()
end


function core:Toggle()
  local menu = core.addon or core:CreateMenu()
  menu:SetShown(not menu:IsShown())
end

function core:Show()
  local menu = core.addon or core:CreateMenu()
  menu:Show()
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
  title:SetPoint("TOPLEFT", addon, "TOPLEFT", 7, -7)
  title:SetFontObject("GameFontNormal")
  title:SetText("+1 RollTracker")
  addon.title = title

  local closeBtn = CreateFrame("Button", nil, addon, "UIPanelCloseButton")
  closeBtn:SetSize(32,32)
  closeBtn:SetPoint("TOPRIGHT", addon, "TOPRIGHT", 1, 1)
  addon.closeBtn = closeBtn

  local clearBtn = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
  clearBtn:SetPoint("BOTTOMRIGHT", addon, "BOTTOMRIGHT", -5, 5)
  clearBtn:SetSize(60, 30)
  clearBtn:SetText("Clear list")
  clearBtn:SetScript("OnClick", function(self, button)
    core:ClearRolls()
  end)
  addon.clearBtn = clearBtn


  local resetBtn = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
  resetBtn:SetPoint("RIGHT", clearBtn, "LEFT", -3)
  resetBtn:SetSize(45, 30)
  resetBtn:SetText("Reset")
  resetBtn:SetScript("OnClick", function(self, button)
    core:ResetData()
  end)
  addon.resetBtn = resetBtn



  local scrollFrame = CreateFrame("ScrollFrame", nil, addon, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 5, -7)
  scrollFrame:SetPoint("BOTTOMRIGHT", clearBtn, "TOPRIGHT", -24, 2)
  addon.scrollFrame = scrollFrame

  local scrollChild = CreateFrame("Frame")
  --scrollChild:SetWidth(scrollFrame:GetWidth())
  --scrollChild:SetHeight(1000)
  addon.scrollChild = scrollChild

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

    frame["rollFrame"..i] = frame

    tinsert(core.framepool, frame)
  end


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
