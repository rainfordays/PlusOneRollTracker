local _, A = ...


A.framepool = {}
A.hiddenFrame = CreateFrame("Frame", nil, UIParent)
A.hiddenFrame:Hide()


-- RESET DATA
function A:ResetData()
  wipe(PORTDB.rolls)
  wipe(PORTDB.plusOne)
  A:Print("All " .. A.defaults.addonName .. " data has been reset.")
end




-- UPDATE
function A:Update()

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
        if PORTDB.usePlusOne then
          frame.plusOne:SetText(PORTDB.plusOne[player.name] and pprefix ..PORTDB.plusOne[player.name] or "")
        else
          frame.plusOne:SetText("")
        end
      end
    --end
  end

  local numFramesActive = 0
  for _, frame in ipairs(A.framepool) do
    if frame.used then numFramesActive = numFramesActive+1 end
  end

  A.addon.scrollChild:SetHeight(15*numFramesActive)

end
