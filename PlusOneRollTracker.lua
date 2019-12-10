local _, core = ...


core.framepool = {}
core.hiddenFrame = CreateFrame("Frame", nil, UIParent)
core.hiddenFrame:Hide()


-- RESET DATA
function core:ResetData()
  PORTDB.rolls = {}
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



