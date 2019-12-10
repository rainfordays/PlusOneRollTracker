local _, core = ...

-- COLOR TEXT
function core:colorText(text, color)
  return "|cff".. core.colors[color] .. text.."|r"
end


-- PRINT
function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end



local function addonColor(text)
  return "|cff"..core.defaults.color..text.."|r "
end


-- SORT FUNCTIONS
local function sortRegular(a, b)
  return a.roll > b.roll
end

local function sortPlusOne(a, b)
  return (a.plusOne < b.plusOne) or (a.plusOne == b.plusOne and a.roll > b.roll)
end