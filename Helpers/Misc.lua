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



-- USE PLUSONE
function core:IsPlusOneRoll()
  PORTDB.usePlusOne = true
  core.addon.plusOneCB:SetChecked(true)
end

-- REGULAR ROLL
function core:NotPlusOneRoll()
  PORTDB.usePlusOne = false
  core.addon.plusOneCB:SetChecked(false)
end



-- GET NON USED FRAME FOR ROLLS
function core:GetRollFrame()
  for _, frame in ipairs(core.framepool) do
    if not frame.used then
      return frame
    end
  end
end