local _, A = ...
A.countDownNum = 0

function A.countDown()
  SendChatMessage(A.countDownNum, "RAID_WARNING")
  A.countDownNum = A.countDownNum-1
end

function A:SlashCommand(args)
  local command, rest = strsplit(" ", args, 2)
  local PORTDB = PlusOneRollTrackerDB

  -- RESET
  if command == "reset" then
    A:ResetData()
    A:Update()

  -- COUNTDOWN
  elseif command == "countdown" or command == "count" or command == "cd" then
    local seconds, rest = strsplit(" ", rest, 2)
    A.countDownNum = tonumber(seconds)

    C_Timer.NewTicker(1,
      function()
        if A.countDownNum < 11 then
          SendChatMessage(A.countDownNum, "RAID_WARNING")
        end
        A.countDownNum = A.countDownNum-1
      end,
    seconds)


  -- STATS
  elseif command == "stats" then
    local count = 0


    if A:Count(PORTDB.plusOne) > 0 then
      A:Print("PlusOne")
      for name, v in pairs(PORTDB.plusOne) do
        Print(name, " +", v)
        count = count + 1
      end
    end

    if A:Count(PORTDB.plusOneMS) > 0 then
      A:Print("PlusOne MS")
      for name, v in pairs(PORTDB.plusOneMS) do
        Print(name, " +", v)
        count = count + 1
      end
    end

    if A:Count(PORTDB.plusOneOS) > 0 then
      A:Print("PlusOne OS")
      for name, v in pairs(PORTDB.plusOneOS) do
        Print(name, " +", v)
        count = count + 1
      end
    end


    if count == 0 then
      A:Print(A.defaults.addonName .. " no stats to show.")
    end


  -- CONFIG
  elseif command == "config" or string.find(command, "option") then
    InterfaceOptionsFrame_OpenToCategory(A.optionsPanel)
    InterfaceOptionsFrame_OpenToCategory(A.optionsPanel)

  -- HELP
  elseif command == "help" then
    A:Print(A:addonColor("PlusOne RollTracker").." options")
    A:Print(A:addonColor("/plusone") .. " reset -- Reset addon data (Must be done at the start of each raid)")
    A:Print(A:addonColor("/plusone") .. " stats -- Shows current +1 stats")
    A:Print(A:addonColor("/plusone") .. " config -- Shows config panel")

  else
    A:Toggle()
  end
end


function A:Toggle()
  local menu = A.addon or A:CreateMenu()
  menu:SetShown(not menu:IsShown())
  A:Update()
end

function A:Show()
  local menu = A.addon or A:CreateMenu()
  menu:Show()
  A:Update()
end

function A:Hide()
  local menu = A.addon or A:CreateMenu()
  menu:Hide()
end


function A:Count(t)
  local i = 0
  for _, _ in pairs(t) do
    i = i + 1
  end
  return i
end