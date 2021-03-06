local _, A = ...
A.loaded = false
A.itemWaitTable = {}
A.name = "PlusOneRollTracker"


local E = CreateFrame("Frame")
E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("CHAT_MSG_SYSTEM")
E:RegisterEvent("CHAT_MSG_RAID_WARNING")
E:RegisterEvent("CHAT_MSG_RAID_LEADER")
E:RegisterEvent("CHAT_MSG_RAID")
E:RegisterEvent("CHAT_MSG_PARTY")
E:RegisterEvent("LOOT_OPENED")
E:RegisterEvent("PLAYER_LOGOUT")
E:RegisterEvent("PLAYER_ENTERING_WORLD")
E:RegisterEvent("GET_ITEM_INFO_RECEIVED");
E:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


function E:ADDON_LOADED(name)
  if name ~= A.name then return end

  PORTDB = PORTDB or {}

  -- Init addon settings if they're missing
  PORTDB.rolls = PORTDB.rolls or {}
  PORTDB.usePlusOne = PORTDB.usePlusOne or false
  PORTDB.monstersLooted = PORTDB.monstersLooted or {}
  PORTDB.plusOne = PORTDB.plusOne or {}
  PORTDB.plusOneMS = PORTDB.plusOneMS or {}
  PORTDB.plusOneOS = PORTDB.plusOneOS or {}
  PORTDB.autolootQuality = PORTDB.autolootQuality or 3
  PORTDB.autoloot = PORTDB.autoloot or false
  PORTDB.excludeItemType = PORTDB.excludeItemType or {}
  PORTDB.excludeString = PORTDB.excludeString or "Onyxia Hide Backpack\nHead of Onyxia\nHead of Nefarian"
  PORTDB.loginMessage = PORTDB.loginMessage or false

  local f=InterfaceOptionsFrame
  f:SetMovable(true)
  f:EnableMouse(true)
  f:SetUserPlaced(true)
  f:SetScript("OnMouseDown", f.StartMoving)
  f:SetScript("OnMouseUp", f.StopMovingOrSizing)


  SLASH_PLUSONEROLLTRACKER1= "/+1"
  SLASH_PLUSONEROLLTRACKER2= "/plusone"
  SlashCmdList.PLUSONEROLLTRACKER = function(msg)
    A:SlashCommand(msg)
  end

  A:CreateOptionsMenu()
  A:Hide()

  A:PruneMonstersLooted()
  A.loaded = true
end

function E:PLAYER_ENTERING_WORLD(login, reloadui)
  if not A.loaded then return end
  if (login or reloadui) and PORTDB.loginMessage and A.loaded then
    A:Print(A.defaults.addonName .. " loaded")
  end
end

--[[
  ROLL
]]
function E:CHAT_MSG_SYSTEM(msg)
  local pattern = RANDOM_ROLL_RESULT
  pattern = pattern:gsub("%(", "%%(")
  pattern = pattern:gsub("%)", "%%)")
  pattern = pattern:gsub("%%s", "(.+)")
  pattern = pattern:gsub("%%d", "(%%d+)")

  local author, roll, min, max = string.match(msg, pattern)

  roll = tonumber(roll)
  min = tonumber(min)
  max = tonumber(max)

  if min == 1 and max == 100 then
    A:Show()

    for i, player in ipairs(PORTDB.rolls) do
      if player.name == author and player.passes and not player.hasRolled then
        tremove(PORTDB.rolls, i)
      end
    end

    for _, player in ipairs(PORTDB.rolls) do
      if player.name == author and player.hasRolled then
        player.ignoreRoll = true
        return A:Update()
      end
    end

    local _, class = UnitClass(author);

    local T = {}
    T.name = author
    T.roll = roll
    T.class = class
    T.plusOne = PORTDB.plusOne[author] or 0
    T.plusOneMS = PORTDB.plusOneMS[author] or 0
    T.plusOneOS = PORTDB.plusOneOS[author] or 0
    T.hasRolled = true

    tinsert(PORTDB.rolls, T)
    A:Update()
  end
end

--[[
  RAID WARNING
]]
function E:CHAT_MSG_RAID_WARNING(msg, author)

  local itemIDPattern = "^|c........|Hitem:(%d*)"
  local rerollPattern = "reroll"
  local itemLinkPattern = "|c.*|r"

  if msg and string.find(msg, itemIDPattern) then
    if string.find(msg, "was awarded with") then
      A:ClearRolls()
      return A:Hide()
    end
    -- Dont start new roll on raidwarning with multiple items
    if select(2, string.gsub(msg, "Hitem:", '')) > 1 then return end


    -- Assert item identification
    local itemID = tonumber(string.match(msg, itemIDPattern))
    local itemName, itemLink, itemRarity = GetItemInfo(itemID)

    -- Not loaded by cache so send the item to waiting table
    if not itemName then
      A.itemWaitTable[itemID] = {msg = msg, author = author}
      return
    end

    -- If item is on ignore list then exit thread
    if A.ignoredItems[itemName] then return end
    -- Item quality is less than uncommon so exit thread
    if itemRarity < 2 then return end

    A:Show()
    A.currentRollItem = itemName
    A.addon.currentRollItem:SetText(itemLink)
    A:ClearRolls()
    A:Update()

    local params = string.gsub(msg, itemLinkPattern, "")
    if string.find(params, "+1") then
      A:PlusOneRoll(true)
    else
      A:PlusOneRoll(false)
    end

    if string.find(params:lower(), "ms") then
      A:PlusOneMSRoll(true)
    end

    if string.find(params:lower(), "os") then
      A:PlusOneOSRoll(true)
    end

  elseif msg and string.find(msg:lower(), rerollPattern) then
    A:ClearRolls()
    A:Update()
  end
end

--[[
  RAID MESSAGE
]]
function E:CHAT_MSG_RAID(msg, author)
  local passPattern = "^pass"

  if string.find(msg, "was awarded with") then
    A:ClearRolls()
    return A:Update()
  end


  if string.find(msg, passPattern) then
    A:PlayerPasses(author)

    A:Show()
    return A:Update()
  end
end

function E:CHAT_MSG_RAID_LEADER(msg, author)
  E:CHAT_MSG_RAID(msg, author)
end

function E:CHAT_MSG_PARTY(msg, author)
  E:CHAT_MSG_RAID(msg, author)
end



--[[
  LOOT READY
]]
function E:LOOT_OPENED(autoloot)
  if not UnitExists("TARGET") then return end
  local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()

  -- Only announce loot if loot method is masterlooter and the user of the addon is the masterlooter
  if lootmethod == "master" and masterlooterPartyID == 0 then
    local guid = UnitGUID("TARGET")
    local time = time()
    time = (time/60)/60 -- time in hours

    A:PruneMonstersLooted()

    -- construct string of loot links
    if PORTDB.monstersLooted[guid] == nil and PORTDB.announceLoot then -- Havn't looted this monster before
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
        if itemLink then
          local itemName, _, itemRarity, _, _, _, _, _, _, _, _, itemTypeID, itemSubTypeID = GetItemInfo(itemLink)

          if not PORTDB.excludeItemType[itemTypeID] or PORTDB.excludeItemType[itemSubTypeID] then -- IF ITEM TYPE IS NOT EXCLUDED
            if not string.find(PORTDB.excludeString:lower(), itemName:lower()) then -- IF THE ITEM ISNT IN THE EXCLUDE LIST (INTERFACE OPTIONS)
              if itemRarity <= PORTDB.autolootQuality then -- IF QUALITY IS LESS THAN OR EQUAL TO SET THRESHHOLD
                for ci = 1, 40 do
                  if GetMasterLootCandidate(li, ci) == UnitName("PLAYER") then
                    GiveMasterLoot(li, ci)
                    break
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


function E:PLAYER_LOGOUT()
  A:PruneMonstersLooted()
end



function E:GET_ITEM_INFO_RECEIVED(itemID, success)
  if success == nil then return end
  if A.itemWaitTable[itemID] then
    E:CHAT_MSG_RAID_WARNING(A.itemWaitTable.msg, A.itemWaitTable.author)
    A.itemWaitTable[itemID] = nil
  end
end