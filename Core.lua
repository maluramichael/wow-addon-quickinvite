local addonName, addon = ...

-- Create the addon using AceAddon with mixins
local QuickInvite = LibStub("AceAddon-3.0"):NewAddon(addon, addonName,
    "AceEvent-3.0", "AceConsole-3.0")

-- Expose globally for macro support: /run QuickInvite:Toggle()
_G["QuickInvite"] = QuickInvite

-- Addon version
QuickInvite.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"

-- Default database values
local defaults = {
    profile = {
        enabled = false,
        levelPadding = 2,
        blacklistDuration = 86400,
        scanInterval = 5,
        maxInvitesPerScan = 3,
        whitelist = {},
        blacklist = {},
    },
}

function QuickInvite:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("QuickInviteDB", defaults, true)

    self:RegisterChatCommand("qi", "SlashCommand")
    self:RegisterChatCommand("quickinvite", "SlashCommand")

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self:GetOptionsTable())
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, "QuickInvite")

    self.pendingInvites = {}
    self.scanTimer = nil

    self:Print("QuickInvite v" .. self.version .. " loaded. Type /qi help for commands.")
end

function QuickInvite:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("CHAT_MSG_SYSTEM")
    self:RegisterEvent("PARTY_INVITE_REQUEST")

    self:CleanBlacklist()

    if self.db.profile.enabled then
        self:StartScanning()
    end
end

function QuickInvite:OnDisable()
    self:StopScanning()
end

function QuickInvite:Toggle()
    self.db.profile.enabled = not self.db.profile.enabled
    if self.db.profile.enabled then
        self:StartScanning()
        self:Print("QuickInvite |cFF00FF00ENABLED|r")
    else
        self:StopScanning()
        self:Print("QuickInvite |cFFFF0000DISABLED|r")
    end
    return self.db.profile.enabled
end

function QuickInvite:Enable()
    self.db.profile.enabled = true
    self:StartScanning()
    self:Print("QuickInvite |cFF00FF00ENABLED|r")
end

function QuickInvite:Disable()
    self.db.profile.enabled = false
    self:StopScanning()
    self:Print("QuickInvite |cFFFF0000DISABLED|r")
end

function QuickInvite:IsEnabled()
    return self.db.profile.enabled
end

function QuickInvite:SlashCommand(input)
    local cmd = input:lower():trim()

    if cmd == "toggle" then
        self:Toggle()
    elseif cmd == "enable" or cmd == "on" then
        self:Enable()
    elseif cmd == "disable" or cmd == "off" then
        self:Disable()
    elseif cmd == "config" or cmd == "options" then
        Settings.OpenToCategory("QuickInvite")
    elseif cmd == "status" then
        self:PrintStatus()
    elseif cmd == "clearblacklist" then
        self:ClearBlacklist()
        self:Print("Blacklist cleared.")
    elseif cmd == "help" or cmd == "" then
        self:PrintHelp()
    else
        self:PrintHelp()
    end
end

function QuickInvite:PrintHelp()
    self:Print("QuickInvite Commands:")
    self:Print("  /qi toggle - Toggle auto-invite on/off")
    self:Print("  /qi enable|on - Enable auto-invite")
    self:Print("  /qi disable|off - Disable auto-invite")
    self:Print("  /qi config - Open configuration panel")
    self:Print("  /qi status - Show current status")
    self:Print("  /qi clearblacklist - Clear the blacklist")
    self:Print("Macro: /run QuickInvite:Toggle()")
end

function QuickInvite:PrintStatus()
    local status = self.db.profile.enabled and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r"
    self:Print("Status: " .. status)
    self:Print("Level Range: " .. UnitLevel("player") .. " +/- " .. self.db.profile.levelPadding)
    self:Print("Blacklisted Players: " .. self:GetBlacklistCount())
end

function QuickInvite:GROUP_ROSTER_UPDATE()
    if GetNumGroupMembers() >= 5 then
        self:StopScanning()
    elseif self.db.profile.enabled and GetNumGroupMembers() < 5 then
        self:StartScanning()
    end
end

function QuickInvite:CHAT_MSG_SYSTEM(event, message)
    local declinedPlayer = message:match("(.+) declines your group invitation")
    local inGroupPlayer = message:match("(.+) is already in a group")

    local playerToBlacklist = declinedPlayer or inGroupPlayer
    if playerToBlacklist then
        self:AddToBlacklist(playerToBlacklist)
    end
end

function QuickInvite:PARTY_INVITE_REQUEST(event, name)
    -- Could auto-accept from whitelisted players in the future
end
