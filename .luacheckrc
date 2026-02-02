std = "lua51"
codes = true
quiet = 1
max_line_length = false
exclude_files = { ".release/", "libs/", "Libs/" }

globals = { "QuickInvite" }

read_globals = {
    "_G", "LibStub",
    "CreateFrame", "UIParent", "GameTooltip", "Settings",
    "UnitName", "UnitLevel", "InviteUnit", "C_NamePlate",
    "InterfaceOptionsFrame_OpenToCategory",
    "pairs", "ipairs", "select", "string", "table", "math", "format",
    "tonumber", "tostring", "type", "unpack",
}
