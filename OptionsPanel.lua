local _, A = ...


local itemTypeIDs = {
  ["Armor"] = LE_ITEM_CLASS_ARMOR,
  ["Consumable"] = LE_ITEM_CLASS_CONSUMABLE,
  ["Container"] = LE_ITEM_CLASS_CONTAINER,
  ["Gem"] = LE_ITEM_CLASS_GEM,
  ["Glyph"] = LE_ITEM_CLASS_GLYPH,
  ["Key"] = LE_ITEM_CLASS_KEY,
  ["Miscellaneous"] = LE_ITEM_CLASS_MISCELLANEOUS,
  ["Projectile"] = LE_ITEM_CLASS_PROJECTILE,
  ["Quest"] = LE_ITEM_CLASS_QUESTITEM,
  ["Quiver"] = LE_ITEM_CLASS_QUIVER,
  ["Reagent"] = LE_ITEM_CLASS_REAGENT,
  ["Recipe"] = LE_ITEM_CLASS_RECIPE,
  ["Trade Goods"] = LE_ITEM_CLASS_TRADEGOODS,
  ["Weapon"] = LE_ITEM_CLASS_WEAPON
}



-- INTERFACE OPTIONS PANEL
function A:CreateOptionsMenu()
  local optionsPanel = CreateFrame("Frame", "PlusOneRollTrackerOptions", UIParent)
  optionsPanel.name = "PlusOne RollTracker"


  local text = optionsPanel:CreateFontString(nil, "OVERLAY")
  text:SetFontObject("GameFontNormal")
  text:SetText("PlusOne RollTracker Options")
  text:SetPoint("TOPLEFT", optionsPanel, "TOPLEFT", 20, -30)



  local autolootFrame = CreateFrame("Frame", nil, optionsPanel)
  autolootFrame:SetPoint("TOPLEFT", text, "TOPLEFT", 10, -20)

    local autolootCB = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
    autolootCB:SetSize(25,25)
    autolootCB:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 10, -25)
    autolootCB:SetScript("OnClick", function(self, button) 
      PORTDB.autoloot = self:GetChecked()
    end)
    autolootCB:SetChecked(PORTDB.autoloot)
    optionsPanel.autolootCB = autolootCB

    local autolootText = autolootCB:CreateFontString(nil, "OVERLAY")
    autolootText:SetFontObject("GameFontNormal")
    autolootText:SetPoint("LEFT", autolootCB, "RIGHT", 3, 0)
    autolootText:SetText("Autoloot items to yourself when you are the masterlooter")
    optionsPanel.autolootText = autolootText


  local qualityText = optionsPanel:CreateFontString(nil, "OVERLAY")
  qualityText:SetPoint("TOPLEFT", autolootCB, "BOTTOMLEFT", 10, -10)
  qualityText:SetFontObject("GameFontNormal")
  qualityText:SetText("Highest quality to autoloot")
  optionsPanel.qualityText = qualityText
  

  qualityCheckboxes = CreateFrame("Frame", nil, optionsPanel)
  
  -- COMMON QUALITY
  local commonQualityCB = CreateFrame("CheckButton", nil, qualityCheckboxes, "UICheckButtonTemplate")
  commonQualityCB:SetSize(25,25)
  commonQualityCB:SetPoint("TOPLEFT", qualityText, "BOTTOMLEFT", 0, -5)
  commonQualityCB:SetScript("OnClick", function(self, button) 
    local children = { self:GetParent():GetChildren() }
    for _, button in ipairs(children) do
      button:SetChecked(false)
    end
    self:SetChecked(true)
    PORTDB.autolootQuality = 1
  end)

  if PORTDB.autolootQuality == 1 then
    commonQualityCB:SetChecked(true)
  else 
    commonQualityCB:SetChecked(false)
  end
  optionsPanel.commonQualityCB = commonQualityCB

  local commonQualityText = optionsPanel:CreateFontString(nil, "OVERLAY")
  commonQualityText:SetPoint("LEFT", commonQualityCB, "RIGHT", 3, 0)
  commonQualityText:SetFontObject("GameFontNormal")
  commonQualityText:SetText(A:colorText(ITEM_QUALITY1_DESC, "common"))
  optionsPanel.commonQualityText = commonQualityText


  -- UNCOMMON QUALITY
  local uncommonQualityCB = CreateFrame("CheckButton", nil, qualityCheckboxes, "UICheckButtonTemplate")
  uncommonQualityCB:SetSize(25,25)
  uncommonQualityCB:SetPoint("LEFT", commonQualityText, "RIGHT", 15, 0)
  uncommonQualityCB:SetScript("OnClick", function(self, button) 
    local children = { self:GetParent():GetChildren() }
    for _, button in ipairs(children) do
      button:SetChecked(false)
    end
    self:SetChecked(true)
    PORTDB.autolootQuality = 2
  end)
  
  if PORTDB.autolootQuality == 2 then
    uncommonQualityCB:SetChecked(true)
  else 
    uncommonQualityCB:SetChecked(false)
  end
  optionsPanel.uncommonQualityCB = uncommonQualityCB

  local uncommonQualityText = optionsPanel:CreateFontString(nil, "OVERLAY")
  uncommonQualityText:SetPoint("LEFT", uncommonQualityCB, "RIGHT", 3, 0)
  uncommonQualityText:SetFontObject("GameFontNormal")
  uncommonQualityText:SetText(A:colorText(ITEM_QUALITY2_DESC, "uncommon"))
  optionsPanel.uncommonQualityText = uncommonQualityText


  -- RARE QUALITY
  local rareQualityCB = CreateFrame("CheckButton", nil, qualityCheckboxes, "UICheckButtonTemplate")
  rareQualityCB:SetSize(25,25)
  rareQualityCB:SetPoint("LEFT", uncommonQualityText, "RIGHT", 15, 0)
  rareQualityCB:SetScript("OnClick", function(self, button) 
    local children = { self:GetParent():GetChildren() }
    for _, button in ipairs(children) do
      button:SetChecked(false)
    end
    self:SetChecked(true)
    PORTDB.autolootQuality = 3
  end)

  if PORTDB.autolootQuality == 3 then
    rareQualityCB:SetChecked(true)
  else 
    rareQualityCB:SetChecked(false)
  end
  optionsPanel.rareQualityCB = rareQualityCB

  local rareQualityText = optionsPanel:CreateFontString(nil, "OVERLAY")
  rareQualityText:SetPoint("LEFT", rareQualityCB, "RIGHT", 3, 0)
  rareQualityText:SetFontObject("GameFontNormal")
  rareQualityText:SetText(A:colorText(ITEM_QUALITY3_DESC, "rare"))  optionsPanel.rareQualityText = rareQualityText


  local recipeCB = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
  recipeCB:SetSize(25,25)
  recipeCB:SetPoint("TOPLEFT", commonQualityCB, "BOTTOMLEFT", 10, -5)
  recipeCB:SetScript("OnClick", function(self, button) 
    PORTDB.excludeItemType[LE_ITEM_CLASS_RECIPE] = self:GetChecked()
  end)
  recipeCB:SetChecked(PORTDB.excludeItemType[LE_ITEM_CLASS_RECIPE])
  optionsPanel.recipeCB = recipeCB

  local recipeText = recipeCB:CreateFontString(nil, "OVERLAY")
  recipeText:SetFontObject("GameFontNormal")
  recipeText:SetPoint("LEFT", recipeCB, "RIGHT", 3, 0)
  recipeText:SetText("Exclude recipes & tomes")
  

  local containerCB = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
  containerCB:SetSize(25,25)
  containerCB:SetPoint("TOPLEFT", recipeCB, "BOTTOMLEFT", 0, -1)
  containerCB:SetScript("OnClick", function(self, button) 
    PORTDB.excludeItemType[LE_ITEM_CLASS_CONTAINER] = self:GetChecked()
  end)
  containerCB:SetChecked(PORTDB.excludeItemType[LE_ITEM_CLASS_CONTAINER])
  optionsPanel.containerCB = containerCB

  local containerText = containerCB:CreateFontString(nil, "OVERLAY")
  containerText:SetFontObject("GameFontNormal")
  containerText:SetPoint("LEFT", containerCB, "RIGHT", 3, 0)
  containerText:SetText("Exclude containers & bags")


  

  local questCB = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
  questCB:SetSize(25,25)
  questCB:SetPoint("TOPLEFT", containerCB, "BOTTOMLEFT", 0, -1)
  questCB:SetScript("OnClick", function(self, button) 
    PORTDB.excludeItemType[LE_ITEM_CLASS_QUESTITEM] = self:GetChecked()
  end)
  questCB:SetChecked(PORTDB.excludeItemType[LE_ITEM_CLASS_QUESTITEM])
  optionsPanel.questCB = questCB

  local questText = questCB:CreateFontString(nil, "OVERLAY")
  questText:SetFontObject("GameFontNormal")
  questText:SetPoint("LEFT", questCB, "RIGHT", 3, 0)
  questText:SetText("Exclude quests items")



  local excludeHeader = optionsPanel:CreateFontString(nil, "OVERLAY")
  excludeHeader:SetPoint("TOPLEFT", questCB, "BOTTOMLEFT", 0, -5)
  excludeHeader:SetFontObject("GameFontNormal")
  excludeHeader:SetText("Exclude items")

  optionsPanel.excludeHeader = excludeHeader


  local backdrop = {
    bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    tile = true,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  }
  
  
  local excludeFrame = CreateFrame("ScrollFrame", nil, optionsPanel, "UIPanelScrollFrameTemplate")
  excludeFrame:SetPoint("TOPLEFT", excludeHeader, "BOTTOMLEFT", 5, -5)
  excludeFrame:SetSize(275, 300)
  --excludeFrame:SetBackdrop(backdrop)
  -- ON MOUSE ENTER TOOLTIP
  excludeFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("List of item names you would like \nto exclude from autolooting")
  end)
  -- ON MOUSE LEAVE HIDE TOOLTIP
  excludeFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)
  optionsPanel.excludeFrame = excludeFrame

  local excludeBG = CreateFrame("Frame", nil, optionsPanel)
  excludeBG:SetPoint("CENTER", excludeFrame, "CENTER")
  excludeBG:SetSize(285, 310)
  excludeBG:SetBackdrop(backdrop)


  local exclude = CreateFrame("EditBox", nil, excludeFrame)
  --exclude:SetBackdrop(backdrop)
  exclude:SetFrameStrata("DIALOG")
  exclude:SetPoint("TOP", excludeFrame, "TOP", 0, -10)
  exclude:SetFont(GameFontNormal:GetFont(), 12)
  exclude:SetWidth(265)
  exclude:SetHeight(300)
  exclude:SetText(PORTDB.excludeString)
  exclude:SetAutoFocus(false)
  exclude:SetMultiLine(true)
  exclude:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  --exclude:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  exclude:SetScript("OnKeyUp", function(self)
    PORTDB.excludeString = self:GetText()
  end)

  excludeFrame:SetScrollChild(exclude)
  optionsPanel.exclude = exclude




  A.optionsPanel = optionsPanel
  InterfaceOptions_AddCategory(optionsPanel)
end
