local _, core = ...

-- COLOR TEXT
function core:colorText(text, color)
  return "|cff".. core.colors[color] .. text.."|r"
end


-- PRINT
function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end


-- COLOR TEXT TO ADDON COLOR
function core:addonColor(text)
  return "|cff"..core.defaults.color..text.."|r "
end



-- SORT FUNCTIONS
function core.sortRegular(a, b)
  return a.roll > b.roll
end

function core.sortPlusOne(a, b)
  return (a.plusOne < b.plusOne) or (a.plusOne == b.plusOne and a.roll > b.roll)
end