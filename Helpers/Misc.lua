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


