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
  addon:SetMovable(true)
  addon:EnableMouse(true)
  addon:RegisterForDrag("LeftButton")
  addon:SetScript("OnDragStart", addon.StartMoving)
  addon:SetScript("OnDragStop", addon.StopMovingOrSizing)
  addon:SetScript("OnHide", function(self)
    core:ClearRolls()
  end)

  local title = addon:CreateFontString(nil, "OVERLAY")
  title:SetPoint("TOPLEFT", addon, "TOPLEFT", 10, -10)
  title:SetFontObject("GameFontNormal")
  title:SetText("+1 RollTracker")
  addon.title = title

  local closeBtn = CreateFrame("Button", nil, addon, "UIPanelCloseButton")
  closeBtn:SetSize(32,32)
  closeBtn:SetPoint("TOPRIGHT", addon, "TOPRIGHT", 1, 1)
  closeBtn:SetScript("OnClick", function(self, button)

    self:GetParent():Hide()
  end)
  addon.closeBtn = closeBtn

  local clearBtn = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
  clearBtn:SetPoint("BOTTOMRIGHT", addon, "BOTTOMRIGHT", -5, 5)
  clearBtn:SetSize(60, 25)
  clearBtn:SetText("Clear list")
  clearBtn:SetScript("OnClick", function(self, button)
    core:ClearRolls()
    core:Update()
  end)
  addon.clearBtn = clearBtn


  local resetBtn = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
  resetBtn:SetPoint("TOPRIGHT", clearBtn, "TOPLEFT", 0, 0)
  resetBtn:SetSize(55, 25)
  resetBtn:SetText("Reset +1")
  resetBtn:SetScript("OnClick", function(self, button)
    core:ResetData()
    core:Update()
  end)
  addon.resetBtn = resetBtn


  local plusoneCB = CreateFrame("CheckButton", nil, addon, "UICheckButtonTemplate")
  plusoneCB:SetSize(30,30)
  plusoneCB:SetPoint("BOTTOMLEFT", addon, "BOTTOMLEFT", 5, 2)
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
