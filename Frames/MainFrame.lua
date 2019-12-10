local _, core = ...

function core:CreateMenu()
  local backdrop = {bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }}
  -- Frame
  local addon = CreateFrame("Frame", nil, UIParent)
  addon:SetSize(220, 300)
  addon:SetPoint("RIGHT", UIParent, "RIGHT", -20, 20)
  addon:SetBackdrop(backdrop)

  local title = addon:CreateFontString(nil, "OVERLAY")
  title:SetPoint("TOPLEFT", addon, "TOPLEFT", 10, -10)
  title:SetFontObject("GameFontNormal")
  title:SetText("+1 RollTracker")
  addon.title = title

  local closeBtn = CreateFrame("Button", nil, addon, "UIPanelCloseButton")
  closeBtn:SetSize(32,32)
  closeBtn:SetPoint("TOPRIGHT", addon, "TOPRIGHT", 1, 1)
  closeBtn:SetScript("OnClick", function(self, button)
    local alt_key = IsAltKeyDown()
    local shift_key = IsShiftKeyDown()
    local control_key = IsControlKeyDown()

    if alt_key and control_key and shift_key and (button == "LeftButton") then
      core:ResetData()
      core:Update()
    else
      self:GetParent():Hide()
    end
  end)
  addon.closeBtn = closeBtn

  local clearBtn = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
  clearBtn:SetPoint("BOTTOMRIGHT", addon, "BOTTOMRIGHT", -5, 5)
  clearBtn:SetSize(60, 30)
  clearBtn:SetText("Clear list")
  clearBtn:SetScript("OnClick", function(self, button)
    core:ClearRolls()
    core:Update()
  end)
  addon.clearBtn = clearBtn


  local plusoneCB = CreateFrame("CheckButton", nil, addon, "UICheckButtonTemplate")
  plusoneCB:SetSize(30,30)
  plusoneCB:SetPoint("BOTTOMLEFT", addon, "BOTTOMLEFT", 5, 5)
  plusoneCB:SetScript("OnClick", function(self, button) 
    PORTDB.usePlusOne = self:GetChecked()
    core:Update()
  end)
  plusoneCB:SetChecked(PORTDB.usePlusOne)
  addon.plusOneCB = plusoneCB

  local cbText = plusoneCB:CreateFontString(nil, "OVERLAY")
  cbText:SetPoint("LEFT", plusoneCB, "RIGHT", 3)
  cbText:SetFontObject("GameFontNormalSmall")
  cbText:SetText("+1 roll")
  addon.cbText = cbText



  local scrollFrame = CreateFrame("ScrollFrame", nil, addon, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 5, -7)
  scrollFrame:SetPoint("BOTTOMRIGHT", clearBtn, "TOPRIGHT", -24, 2)
  addon.scrollFrame = scrollFrame

  local scrollChild = CreateFrame("Frame")
  --scrollChild:SetWidth(scrollFrame:GetWidth())
  --scrollChild:SetHeight(1000)
  addon.scrollChild = scrollChild

  core:CreateRollFrames(addon)


  scrollFrame:SetScrollChild(scrollChild)
  scrollChild:SetWidth(scrollFrame:GetWidth());


  addon:Hide()

  core.addon = addon
  return core.addon
end
