local _, core = ...

function core:SlashCommand(args)
  local command, rest = strsplit(" ", args, 2)
  local PORTDB = PlusOneRollTrackerDB

  -- RESET
  if command == "reset" then
    core:ResetData()
    core:Update()

  -- STATS
  elseif command == "stats" then
    local temp = {}

    for k,v in pairs(PORTDB.plusOne) do
      tinsert(temp, k .. "+"..v)
    end
    table.sort(temp)

    if #temp > 0 then
      core:Print(core.defaults.addonPrefix.." stats.")
      for _,v in ipairs(temp) do
        core:Print("    "..v)
      end
    else
      core:Print(core.defaults.addonPrefix .. " no stats to show.")
    end


  -- CONFIG
  elseif command == "config" or string.find(command, "option") then
    InterfaceOptionsFrame_OpenToCategory(core.optionsPanel)
    InterfaceOptionsFrame_OpenToCategory(core.optionsPanel)

  -- HELP
  elseif command == "help" then
    core:Print(core:addonColor("PlusOne RollTracker").." options")
    core:Print(core:addonColor("/plusone") .. " reset -- Reset addon data (Must be done at the start of each raid)")
    core:Print(core:addonColor("/plusone") .. " stats -- Shows current +1 stats")
    core:Print(core:addonColor("/plusone") .. " config -- Shows config panel")

  else
    core:Toggle()
  end
end


function core:Toggle()
  local menu = core.addon or core:CreateMenu()
  menu:SetShown(not menu:IsShown())
  core:Update()
end

function core:Show()
  local menu = core.addon or core:CreateMenu()
  menu:Show()
  core:Update()
end

function core:Hide()
  local menu = core.addon or core:CreateMenu()
  menu:Hide()
end