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
  a.plusOne = a.plusOne or 0
  b.plusOne = b.plusOne or 0
  return (a.plusOne < b.plusOne) or (a.plusOne == b.plusOne and a.roll > b.roll)
end

function A.sortPlusOneMS(a, b)
  a.plusOneMS = a.plusOneMS or 0
  b.plusOneMS = b.plusOneMS or 0
  return (a.plusOneMS < b.plusOneMS) or (a.plusOneMS == b.plusOneMS and a.roll > b.roll)
end

function A.sortPlusOneOS(a, b)
  a.plusOneOS = a.plusOneOS or 0
  b.plusOneOS = b.plusOneOS or 0
  return (a.plusOneOS < b.plusOneOS) or (a.plusOneOS == b.plusOneOS and a.roll > b.roll)
end


function A:PlusOneRoll(bool)
  PORTDB.usePlusOne = bool
  A.addon.plusOneCB:SetChecked(bool)
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
    if PORTDB.rollMS then
      table.sort(PORTDB.rolls, A.sortPlusOneMS)
    elseif PORTDB.rollOS then
      table.sort(PORTDB.rolls, A.sortPlusOneOS)
    else
      table.sort(PORTDB.rolls, A.sortPlusOne)
    end
  else -- not +1
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