local _, core = ...
core.loaded = false
core.itemWaitTable = {}


local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("CHAT_MSG_SYSTEM")
events:RegisterEvent("CHAT_MSG_RAID_WARNING")
events:RegisterEvent("CHAT_MSG_RAID_LEADER")
events:RegisterEvent("CHAT_MSG_RAID")
events:RegisterEvent("LOOT_READY")
events:RegisterEvent("PLAYER_LOGOUT")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED");
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


function events:ADDON_LOADED(name)
  if name ~= "PlusOneRollTracker" then return end

  if PlusOneRollTrackerDB == nil then PlusOneRollTrackerDB = {} end
  PORTDB = PlusOneRollTrackerDB

  -- Init addon settings if they're missing
  if not PORTDB.rolls then PORTDB.rolls = {} end
  if not PORTDB.usePlusOne then PORTDB.usePlusOne = false end
  if not PORTDB.monstersLooted then PORTDB.monstersLooted = {} end
  if not PORTDB.plusOne then PORTDB.plusOne = {} end
  if not PORTDB.autolootQuality then PORTDB.autolootQuality = 3 end
  if not PORTDB.autoloot then PORTDB.autoloot = false end
  if not PORTDB.excludeItemType then PORTDB.excludeItemType = {} end
  if not PORTDB.excludeString then PORTDB.excludeString = "Onyxia Hide Backpack\nHead of Onyxia" end

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

  core:CreateOptionsMenu()
  core:Hide()

  core:PruneMonstersLooted()
  core.loaded = true
end

function events:PLAYER_ENTERING_WORLD(login, reloadui)
  if not core.loaded then return end
  if login or reloadui then
    core:Print(core.defaults.addonPrefix .. " loaded. /+1 or /plusone to open addon.")
  end
end

--[[
  ROLL
]]
function events:CHAT_MSG_SYSTEM(msg)
  local pattern = RANDOM_ROLL_RESULT
  pattern = pattern:gsub("%(", "%%(")
  pattern = pattern:gsub("%)", "%%)")
  pattern = pattern:gsub("%%s", "(.+)")
  pattern = pattern:gsub("%%d", "(%%d+)")

  local name, roll, min, max = string.match(msg, pattern)

  roll = tonumber(roll)
  min = tonumber(min)
  max = tonumber(max)

  if min == 1 and max == 100 then
    core:Show()
    for _, player in ipairs(PORTDB.rolls) do
      if player.name == name then
        core:IgnoreRoll(player.name)
        core:Update()
        return
      end
    end

    local _, class = UnitClass(name);

    local temp = {}
    temp.name = name
    temp.roll = roll
    temp.class = class
    temp.plusOne = PORTDB.plusOne[name] or 0

    tinsert(PORTDB.rolls, temp)
    core:Update()
  end
end

--[[
  RAID WARNING
]]
function events:CHAT_MSG_RAID_WARNING(msg, author)
  local itemIDPattern = "Hitem:(%d*)"
  local itemLinkPattern = "item:.+%[(.+)%]"
  local plusOnePattern = "%+1$"
  local rerollPattern = "reroll"

  if string.find(msg, itemLinkPattern) then

    local itemID = tonumber(string.match(msg, itemIDPattern))

    local itemName, itemLink, itemRarity = GetItemInfo(itemID)

    if not itemName then
      core.itemWaitTable[itemID] = {msg = msg, author = author}
      return
    end

    if itemRarity < 2 then return end



    core:Show()
    core.currentRollItem = itemName

    if string.find(msg, plusOnePattern) then
      PORTDB.usePlusOne = true
      core.addon.plusOneCB:SetChecked(true)
      core:ClearRolls()
      core:Update()

    else
      PORTDB.usePlusOne = false
      core.addon.plusOneCB:SetChecked(false)
      core:ClearRolls()
      core:Update()
    end

  elseif string.find(msg:lower(), rerollPattern) then
    core:ClearRolls()
    core:Update()
  end
end

--[[
  RAID MESSAGE
]]
function events:CHAT_MSG_RAID(msg, author)
  local passPattern = "^pass"

  if string.find(msg, passPattern) then
    local playerHasRolledBefore = false
    local name = author
    if string.find(name, "-") then
      name = string.gsub(author, "-.*", "")
    end
    local _, class = UnitClass(name);

    for _, player in ipairs(PORTDB.rolls) do
      if player.name == author then
        core:IgnoreRoll(player.name)
        playerHasRolledBefore = true
      end
    end

    if not playerHasRolledBefore then
      local temp = {}

      temp.name = name
      temp.roll = 0
      temp.class = class
      temp.plusOne = PORTDB.plusOne[name] or 0

      tinsert(PORTDB.rolls, temp)
    end

    core:Update()
  end
end

function events:CHAT_MSG_RAID_LEADER(msg, author)
  events:CHAT_MSG_RAID(msg, author)
end



--[[
  LOOT READY
]]
function events:LOOT_READY(autoloot)
  if not UnitExists("TARGET") then return end
  local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()

  -- Only announce loot if loot method is masterlooter and the user of the addon is the masterlooter
  if lootmethod == "master" and masterlooterPartyID == 0 then
    local guid = UnitGUID("TARGET")
    local time = time()
    time = (time/60)/60 -- time in hours

    core:PruneMonstersLooted()

    -- construct string of loot links
    if PORTDB.monstersLooted[guid] == nil then -- Havn't looted this monster before
      PORTDB.monstersLooted[guid] = time
      local lootstring = ""
      for li = 1, GetNumLootItems() do
        local itemLink = GetLootSlotLink(li)
        if itemLink ~= nil then
          local _, _, itemRarity = GetItemInfo(itemLink)
          if itemRarity == 4 or itemRarity == 5 then -- if epic or legendary loot
            lootstring = lootstring..itemLink
          end
        end
      end -- / forloop
      if #lootstring > 0 then
        SendChatMessage(lootstring ,"RAID") -- send string of loot links in raidchat
      end
    end -- / monster not looted


    if autoloot == true and PORTDB.autoloot then -- AUTOLOOTING AND SETTING ENABLED
      for li = 1, GetNumLootItems() do
        local itemLink = GetLootSlotLink(li)

        if itemLink ~= nil then
          local itemName, _, itemRarity, _, _, _, _, _, _, _, _, itemTypeID = GetItemInfo(itemLink)

          if not PORTDB.excludeItemType[itemTypeID] then -- IF ITEM TYPE IS NOT EXCLUDED
            if not string.find(PORTDB.excludeString:lower(), itemName:lower()) then -- IF THE ITEM ISNT IN THE EXCLUDE LIST (INTERFACE OPTIONS)
              if itemRarity <= PORTDB.autolootQuality then -- IF QUALITY IS LESS THAN OR EQUAL TO SET THRESHHOLD
                for ci = 1, 40 do
                  if GetMasterLootCandidate(li, ci) == UnitName("PLAYER") then
                    GiveMasterLoot(li, ci)
                  end
                end
              end
            end
          end
        end
      end -- / forloop
    end

  end -- / lootmethod = master and player is masterlooter
end


function events:PLAYER_LOGOUT()
  core:PruneMonstersLooted()
end



function events:GET_ITEM_INFO_RECEIVED(itemID, success)
  if success == nil then return end
  if core.itemWaitTable[itemID] then
    events:CHAT_MSG_RAID_WARNING(core.itemWaitTable.msg, core.itemWaitTable.author)
    core.itemWaitTable[itemID] = nil
  end
end