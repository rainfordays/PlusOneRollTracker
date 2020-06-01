local _, A = ...


A.framepool = {}
A.hiddenFrame = CreateFrame("Frame", nil, UIParent)
A.hiddenFrame:Hide()


-- RESET DATA
function A:ResetData()
  wipe(PORTDB.rolls)
  wipe(PORTDB.plusOne)
  wipe(PORTDB.plusOneMS)
  wipe(PORTDB.plusOneOS)
  A:Print("All " .. A.defaults.addonName .. " data has been reset.")
end




-- UPDATE
function A:Update()
  for _, player in ipairs(PORTDB.rolls) do
    player.plusOne = PORTDB.plusOne[player.name]
    player.plusOneMS = PORTDB.plusOneMS[player.name]
    player.plusOneOS = PORTDB.plusOneOS[player.name]
  end

  -- RESET ALL ROLL FRAMES
  A:ClearFramepool()

  -- SORT ROLLTABLE
  A:SortRolls()


  -- SET ROLLFRAMES
  for _, player in ipairs(PORTDB.rolls) do
    --if not player.ignoreRoll then
      local frame = A:GetRollFrame()

      local coloredName = A:colorText(player.name, player.class)
      local pprefix = PORTDB.plusOne[player.name] and PORTDB.plusOne[player.name] > 0 and "+" or ""
      frame:SetParent(A.addon.scrollChild)
      frame:SetHeight(15)
      frame.name:SetText(coloredName)
      frame.class:SetText(A.ClassIcons[player.class])
      frame.used = true
      frame:Show()
      frame.playerName = player.name

      if player.ignoreRoll then
        frame.roll:SetText(0)
        frame.plusOne:SetText("")
        frame.name:SetText(frame.name:GetText() .. " (ignored)")
      elseif player.passes then
        frame.roll:SetText("")
        frame.plusOne:SetText("")
        frame.name:SetText(frame.name:GetText() .. " (passes)")
      else
        frame.roll:SetText(player.roll)
        frame.plusOne:SetText(A:GetPlayerPlusOne(player.name))
      end
    --end
  end

  local numFramesActive = 0
  for _, frame in ipairs(A.framepool) do
    if frame.used then numFramesActive = numFramesActive+1 end
  end

  A.addon.scrollChild:SetHeight(15*numFramesActive)

end


function A:GetPlayerPlusOne(name)
  local usePlusOne = PORTDB.usePlusOne
  local rollMS = PORTDB.rollMS
  local rollOS = PORTDB.rollOS
  local playerPlusOneMS = PORTDB.plusOneMS[name]
  local playerPlusOneOS = PORTDB.plusOneOS[name]
  local playerPlusOne = PORTDB.plusOne[name]

  if usePlusOne then
    if rollMS and playerPlusOneMS then
      return playerPlusOneMS
    elseif rollOS and playerPlusOneOS then
      return playerPlusOneOS
    elseif playerPlusOne then
      return playerPlusOne
    end
  else
    return ""
  end
end




function A:AddPlayerPlusOne(name)
  if PORTDB.usePlusOne then
    if PORTDB.rollMS then
      PORTDB.plusOneMS[name] = PORTDB.plusOneMS[name] and PORTDB.plusOneMS[name] + 1 or 1
      if PORTDB.plusOneMS[name] == 0 then PORTDB.plusOneMS[name] = nil end
    elseif PORTDB.rollOS then
      PORTDB.plusOneOS[name] = PORTDB.plusOneOS[name] and PORTDB.plusOneOS[name] + 1 or 1
      if PORTDB.plusOneOS[name] == 0 then PORTDB.plusOneOS[name] = nil end
    else
      PORTDB.plusOne[name] = PORTDB.plusOne[name] and PORTDB.plusOne[name] + 1 or 1
      if PORTDB.plusOne[name] == 0 then PORTDB.plusOne[name] = nil end
    end
  end
end


function A:SubPlayerPlusOne(name)
  if PORTDB.usePlusOne then
    if PORTDB.rollMS then
      PORTDB.plusOneMS[name] = PORTDB.plusOneMS[name] and PORTDB.plusOneMS[name] - 1 or 1
      if PORTDB.plusOneMS[name] == 0 then PORTDB.plusOneMS[name] = nil end
    elseif PORTDB.rollOS then
      PORTDB.plusOneOS[name] = PORTDB.plusOneOS[name] and PORTDB.plusOneOS[name] - 1 or 1
      if PORTDB.plusOneOS[name] == 0 then PORTDB.plusOneOS[name] = nil end
    else
      PORTDB.plusOne[name] = PORTDB.plusOne[name] and PORTDB.plusOne[name] - 1 or 1
      if PORTDB.plusOne[name] == 0 then PORTDB.plusOne[name] = nil end
    end
  end
end