local _, core = ...

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
    tempFrame.playerName = ""
    tempFrame:SetScript("OnMouseDown", function(self, button)
      local name = self.playerName


      -- SHIFT + LEFT CLICK
      if IsShiftKeyDown() and button == "LeftButton" then
        PORTDB.plusOne[name] = PORTDB.plusOne[name] and PORTDB.plusOne[name]+1 or 1
        if PORTDB.plusOne[name] == 0 then PORTDB.plusOne[name] = nil end
        core:Update()
        return

      -- SHIFT + RIGHT CLICK
      elseif IsShiftKeyDown() and button == "RightButton" then
        PORTDB.plusOne[name] = PORTDB.plusOne[name] and PORTDB.plusOne[name]-1 or -1
        if PORTDB.plusOne[name] == 0 then PORTDB.plusOne[name] = nil end
        core:Update()
        return


      -- ALT + LEFT CLICK
      elseif (IsAltKeyDown() and (button == "LeftButton")) or button == "MiddleButton" then

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

                        core.currentRollItem = ""

                        -- BUMP +1
                        if PORTDB.usePlusOne then
                          PORTDB.plusOne[name] = PORTDB.plusOne[name] and PORTDB.plusOne[name]+1 or 1
                          self.plusOne:SetText("+"..PORTDB.plusOne[name])
                          core:ClearRolls()
                          core:Update()
                        end
                        return
                      end
                    end
                  end -- / loot slot item is same as current roll item
                end
              end
            end -- / loop through lootwindow
          end
        end

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
