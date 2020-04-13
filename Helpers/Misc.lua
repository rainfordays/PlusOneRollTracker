local _, A = ...

-- COLOR TEXT
function A:colorText(text, color)
  return "|cff".. A.colors[color] .. text.."|r"
end


-- PRINT
function A:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end


-- COLOR TEXT TO ADDON COLOR
function A:addonColor(text)
  return "|cff"..A.defaults.color..text.."|r "
end



-- SORT FUNCTIONS
function A.sortRegular(a, b)
  return a.roll > b.roll
end

function A.sortPlusOne(a, b)
  return (a.plusOne < b.plusOne) or (a.plusOne == b.plusOne and a.roll > b.roll)
end



-- USE PLUSONE
function A:IsPlusOneRoll()
  PORTDB.usePlusOne = true
  A.addon.plusOneCB:SetChecked(true)
end

-- REGULAR ROLL
function A:NotPlusOneRoll()
  PORTDB.usePlusOne = false
  A.addon.plusOneCB:SetChecked(false)
end



-- GET NON USED FRAME FOR ROLLS
function A:GetRollFrame()
  for _, frame in ipairs(A.framepool) do
    if not frame.used then
      return frame
    end
  end
end


function A:ClearFramepool()
  -- RESET ALL ROLL FRAMES
  for _, frame in ipairs(A.framepool) do
    frame:SetParent(A.hiddenFrame)
    frame.used = false
    frame.class:SetText("")
    frame.playerName = ""
  end
end

function A:SortRolls()
  if PORTDB.usePlusOne then
    table.sort(PORTDB.rolls, A.sortPlusOne)
  else
    table.sort(PORTDB.rolls, A.sortRegular)
  end
end


-- CLEAR ROLLS
function A:ClearRolls()
  wipe(PORTDB.rolls)
end




function A:PlayerPasses(author)
  local author = string.gsub(author, "%-.*", "")
  local _, class = UnitClass(author)


  for _, player in ipairs(PORTDB.rolls) do
    if player.name == author then
      player.roll = 0
      player.plusOne = PORTDB.plusOne[author] or 0
      player.passes = true
      return
    end
  end


  local T = {}
  T.name = author
  T.roll = 0
  T.class = class
  T.plusOne = PORTDB.plusOne[author] or 0
  T.passes = true
  tinsert(PORTDB.rolls, T)
end












-- PRUNE MONSTERS LOOTED
function A:PruneMonstersLooted()
  local time = time()
  time = (time/60)/60 -- time in hours

  for k, _ in pairs(PORTDB.monstersLooted) do
    if PORTDB.monstersLooted[k]-time > 3 then PORTDB.monstersLooted[k] = nil end
  end
end