local _, A = ...

function A:CreateRollFrames(addon)

  for i = 1, 40 do
    local childframes = { A.hiddenFrame:GetChildren() }
    local lastChild = childframes[#childframes]

    local tempFrame = CreateFrame("Frame", nil, A.hiddenFrame)
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

        local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()

        if lootmethod == "master" and masterlooterPartyID == 0 then -- PLAYER is masterlooter
          if A.currentRollItem ~= "" then -- currently rolling on an item
            for li = 1, GetNumLootItems() do -- loop through lootwindow
              if LootSlotHasItem(li) then -- current slot has item
                local lootSlotItemLink = GetLootSlotLink(li) -- get item info

                if lootSlotItemLink ~= nil then
                  local itemName = GetItemInfo(lootSlotItemLink)

                  if itemName == A.currentRollItem then -- loot slot item is same as current roll item
                    for ci = 1, 40 do -- for each person in raid
                      if GetMasterLootCandidate(li, ci) == name then
                        GiveMasterLoot(li, ci)


                        -- BUMP +1
                        if PORTDB.usePlusOne then
                          A:AddPlayerPlusOne(name)
                          self.plusOne:SetText("+"..PORTDB.plusOne[name])
                          A:Update()
                        end
                        A.currentRollItem = ""
                        A.addon.currentRollItem:SetText("")
                        return
                      end
                    end
                  end -- / loot slot item is same as current roll item
                end
              end
            end -- / loop through lootwindow
          end
        end
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

    tinsert(A.framepool, tempFrame)

  end
end
