std = "lua51"
codes = true
quiet = 1
max_line_length = false
exclude_files = { ".release/", "libs/", "Libs/" }

ignore = {
    "21.",          -- All unused variable warnings (W211, W212, W213)
    "231",          -- Variable never accessed
    "311",          -- Value assigned to variable is unused
    "631",          -- Line too long
}

globals = { "_G", "QuickInvite" }

read_globals = {
    "LibStub",
    "CreateFrame", "UIParent", "GameTooltip", "Settings",
    "UnitName", "UnitLevel", "InviteUnit", "C_NamePlate",
    "InterfaceOptionsFrame_OpenToCategory", "C_Timer", "C_AddOns",
    "GetNumGroupMembers", "UnitExists", "UnitIsPlayer", "UnitIsFriend",
    "UnitIsUnit", "UnitInParty", "UnitInRaid", "wipe",
    "pairs", "ipairs", "select", "string", "table", "math", "format",
    "tonumber", "tostring", "type", "unpack", "time",
}
