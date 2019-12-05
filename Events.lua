local _, core = ...

----------------------------
---- EVENTS
----------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("CHAT_MSG_SYSTEM")
events:RegisterEvent("CHAT_MSG_RAID_WARNING")
events:RegisterEvent("CHAT_MSG_RAID")
events:RegisterEvent("LOOT_OPENED")
events:RegisterEvent("PLAYER_LOGOUT")
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
  core:Print(core.defaults.addonPrefix .. " by |cffFFF569Mayushi|r on |cffff0000Gehennas|r. /+1 or /plusone to open addon.")

  core:CreateOptionsMenu()
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

  if string.find(msg, itemLinkPattern) then
    core:Show()
    local itemName, _, _ = GetItemInfo(itemID)
    core.currentRollItem = itemName

    if string.find(msg, plusOnePattern) then
      PORTDB.usePlusOne = true
      core.addon.plusoneCB:SetChecked(true)
      core:ClearRolls()
      core:Update()

    else
      PORTDB.usePlusOne = false
      core.addon.plusoneCB:SetChecked(false)
      core:ClearRolls()
      core:Update()
    end

  end
end


function events:CHAT_MSG_RAID(msg, author)
  local passPattern = "pass"
  local _, class = UnitClass(author);
  local playerHasRolledBefore = false

  if string.find(msg, passPattern) then
    for i, player in ipairs(PORTDB.rolls) do
      if player.name == author then
        PORTDB.rolls[i].roll = 0
        playerHasRolledBefore = true
      end
    end

    if not playerHasRolledBefore then
      local temp = {}

      temp.roll = 0
      temp.name = author
      temp.class = class

      tinsert(PORTDB.rolls, temp)
    end

    core:Update()
  end
end

function events:LOOT_OPENED(autoloot)
  local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()

  -- Only announce loot if loot method is masterlooter and the user of the addon is the masterlooter
  if lootmethod == "master" and masterlooterPartyID == 0 then
    local guid = UnitGUID("TARGET")
    local time = time()
    time = (time/60)/60 -- time in hours

    if PORTDB.monstersLooted[guid]-time > 3 then PORTDB.monstersLooted[guid] = nil end

    if PORTDB.monstersLooted[guid] == nil then -- Havn't looted this monster before
      PORTDB.monstersLooted[guid] = time
      local lootstring = ""
      for li = 1, GetNumLootItems() do
        local itemLink = GetLootSlotLink(li)
        local _, _, itemRarity = GetItemInfo(itemLink)
        if itemRarity == 4 or itemRarity == 5 then
          lootstring = lootstring..itemLink
        end
      end -- / forloop
      if #lootstring > 0 then
        SendChatMessage(lootstring ,"RAID")
      end
    end -- / monster not looted



    for li = 1, GetNumLootItems() do
      local itemLink = GetLootSlotLink(li)
      local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, itemTypeID = GetItemInfo(itemLink)

      if PORTDB.autoloot then -- IF WE AUTOLOOT IS ENABLED
        if not PORTDB.excludeItemType[itemTypeID] then -- IF ITEM TYPE IS NOT EXCLUDED
          if not string.find(PORTDB.excludeString, itemName) then -- IF THE ITEM ISNT IN THE EXCLUDE LIST (INTERFACE OPTIONS)
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

  end -- / lootmethod = master and player is masterlooter
end


function events:PLAYER_LOGOUT()
  local time = time()
  time = (time/60)/60 -- time in hours

  for k, v in pairs(PORTDB.monstersLooted) do
    if PORTDB.monstersLooted[k]-time > 3 then PORTDB.monstersLooted[k] = nil end
  end
end
