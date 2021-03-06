local _, A = ...

function A:CreateMenu()
  local backdrop = {bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }}
  -- Frame
  local addon = CreateFrame("Frame", nil, UIParent)
  addon:SetSize(220, 320)
  addon:SetPoint("RIGHT", UIParent, "RIGHT", -20, 20)
  addon:SetBackdrop(backdrop)
  addon:SetMovable(true)
  addon:EnableMouse(true)
  addon:RegisterForDrag("LeftButton")
  addon:SetScript("OnDragStart", addon.StartMoving)
  addon:SetScript("OnDragStop", addon.StopMovingOrSizing)
  addon:SetScript("OnHide", function(self)
    A:ClearRolls()
  end)

  local title = addon:CreateFontString(nil, "OVERLAY")
  title:SetPoint("TOPLEFT", addon, "TOPLEFT", 10, -10)
  title:SetFontObject("GameFontNormal")
  title:SetText("+1 RollTracker")
  addon.title = title

  local currentRollItem = addon:CreateFontString(nil, "OVERLAY")
  currentRollItem:SetPoint("TOPLEFT", addon, "TOPLEFT", 10, 12)
  currentRollItem:SetFontObject("GameFontNormal")
  currentRollItem:SetText("")
  addon.currentRollItem = currentRollItem

  local closeBtn = CreateFrame("Button", nil, addon, "UIPanelCloseButton")
  closeBtn:SetSize(32,32)
  closeBtn:SetPoint("TOPRIGHT", addon, "TOPRIGHT", 1, 1)
  closeBtn:SetScript("OnClick", function(self, button)

    self:GetParent():Hide()
  end)
  addon.closeBtn = closeBtn

  local clearBtn = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
  clearBtn:SetPoint("BOTTOMRIGHT", addon, "BOTTOMRIGHT", -5, 5)
  clearBtn:SetSize(40, 25)
  clearBtn:SetText("Clear")
  clearBtn:SetScript("OnClick", function(self, button)
    A:ClearRolls()
    A:Update()
  end)
  addon.clearBtn = clearBtn


  local resetBtn = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
  resetBtn:SetPoint("TOPRIGHT", clearBtn, "TOPLEFT", 0, 0)
  resetBtn:SetSize(55, 25)
  resetBtn:SetText("Reset +1")
  resetBtn:SetScript("OnClick", function(self, button)
    A:ResetData()
    A:Update()
  end)
  addon.resetBtn = resetBtn


  local plusoneCB = CreateFrame("CheckButton", nil, addon, "UICheckButtonTemplate")
  plusoneCB:SetSize(25, 25)
  plusoneCB:SetPoint("BOTTOMLEFT", addon, "BOTTOMLEFT", 5, 5)
  plusoneCB:SetScript("OnClick", function(self, button)
    A:PlusOneRoll(self:GetChecked())
    A:Update()
  end)
  plusoneCB:SetChecked(PORTDB.usePlusOne)
  addon.plusOneCB = plusoneCB

  local plusOneText = plusoneCB:CreateFontString(nil, "OVERLAY")
  plusOneText:SetPoint("BOTTOM", plusoneCB, "TOP", 0, -3)
  plusOneText:SetFontObject("GameFontNormalSmall")
  plusOneText:SetText("+1")
  addon.plusOneText = plusOneText


  local MSCB = CreateFrame("CheckButton", nil, addon, "UICheckButtonTemplate")
  MSCB:SetSize(25, 25)
  MSCB:SetPoint("LEFT", plusoneCB, "RIGHT", 1)
  MSCB:SetScript("OnClick", function(self, button)
    A:PlusOneMSRoll(self:GetChecked())
    A:Update()
  end)
  MSCB:SetChecked(PORTDB.rollMS)
  addon.MSCB = MSCB

  local MSText = MSCB:CreateFontString(nil, "OVERLAY")
  MSText:SetPoint("BOTTOM", MSCB, "TOP", 0, -3)
  MSText:SetFontObject("GameFontNormalSmall")
  MSText:SetText("MS")
  addon.MSText = MSText


  local OSCB = CreateFrame("CheckButton", nil, addon, "UICheckButtonTemplate")
  OSCB:SetSize(25, 25)
  OSCB:SetPoint("LEFT", MSCB, "RIGHT", -2, 0)
  OSCB:SetScript("OnClick", function(self, button)
    A:PlusOneOSRoll(self:GetChecked())
    A:Update()
  end)
  OSCB:SetChecked(PORTDB.rollOS)
  addon.OSCB = OSCB

  local OSText = OSCB:CreateFontString(nil, "OVERLAY")
  OSText:SetPoint("BOTTOM", OSCB, "TOP", 0, -3)
  OSText:SetFontObject("GameFontNormalSmall")
  OSText:SetText("OS")
  addon.OSText = OSText





  local scrollFrame = CreateFrame("ScrollFrame", nil, addon, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 5, -7)
  scrollFrame:SetPoint("BOTTOMRIGHT", clearBtn, "TOPRIGHT", -24, 10)
  addon.scrollFrame = scrollFrame

  local scrollChild = CreateFrame("Frame")
  --scrollChild:SetWidth(scrollFrame:GetWidth())
  --scrollChild:SetHeight(1000)
  addon.scrollChild = scrollChild

  A:CreateRollFrames(addon)


  scrollFrame:SetScrollChild(scrollChild)
  scrollChild:SetWidth(scrollFrame:GetWidth());


  addon:Hide()

  A.addon = addon
  return A.addon
end
