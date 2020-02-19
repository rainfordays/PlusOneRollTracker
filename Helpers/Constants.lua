local _, core = ...

core.defaults = {}
core.defaults.color = "FF69B4"
core.defaults.addonPrefix = "|cff".. core.defaults.color .."PlusOne RollTracker|r"

core.currentRollItem = ""


core.ignoredItems = {
  "Onyxia Scale Cloak"
}


core.colors = {
  ["common"] = "ffffff",
  ["uncommon"] = "1eff00",
  ["rare"] = "0070dd",
  ["epic"] = "a335ee",
  ["DRUID"] = "FF7D0A",
  ["HUNTER"] = "A9D271",
  ["MAGE"] = "40C7EB",
  ["PALADIN"] = "F58CBA",
  ["PRIEST"] = "FFFFFF",
  ["ROGUE"] = "FFF569",
  ["SHAMAN"] = "0070DE",
  ["WARLOCK"] = "8787ED",
  ["WARRIOR"] = "C79C6E"
}


core.ClassIcons = {
  WARRIOR = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:0:64:0:64|t",
  MAGE = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:64:128:0:64|t",
  ROGUE = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:128:196:0:64|t",
  DRUID = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:196:256:0:64|t",
  HUNTER = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:0:64:64:128|t",
  SHAMAN = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:64:128:64:128|t",
  PRIEST = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:128:196:64:128|t",
  WARLOCK = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:196:256:64:128|t",
  PALADIN = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:15:15:0:0:256:256:0:64:128:196|t"
}

return core