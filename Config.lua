local addonName, addon = ...
local QuickInvite = addon

function QuickInvite:GetOptionsTable()
    return {
        name = "QuickInvite",
        handler = QuickInvite,
        type = "group",
        args = {
            headerDesc = {
                type = "description",
                name = "QuickInvite v" .. self.version .. " - Auto-invite nearby players\n\nMacro: /run QuickInvite:Toggle()",
                fontSize = "medium",
                order = 1,
            },
            enabled = {
                type = "toggle",
                name = "Enable Auto-Invite",
                desc = "Toggle automatic player invites on/off",
                order = 10,
                get = function() return self.db.profile.enabled end,
                set = function(_, val)
                    self.db.profile.enabled = val
                    if val then
                        self:StartScanning()
                    else
                        self:StopScanning()
                    end
                end,
                width = "full",
            },
            levelHeader = {
                type = "header",
                name = "Level Settings",
                order = 20,
            },
            levelPadding = {
                type = "range",
                name = "Level Range (+/-)",
                desc = "Only invite players within this level range of your character",
                order = 21,
                min = 0,
                max = 10,
                step = 1,
                get = function() return self.db.profile.levelPadding end,
                set = function(_, val) self.db.profile.levelPadding = val end,
            },
            scanHeader = {
                type = "header",
                name = "Scan Settings",
                order = 30,
            },
            scanInterval = {
                type = "range",
                name = "Scan Interval (seconds)",
                desc = "How often to scan for nearby players",
                order = 31,
                min = 1,
                max = 30,
                step = 1,
                get = function() return self.db.profile.scanInterval end,
                set = function(_, val)
                    self.db.profile.scanInterval = val
                    if self.scanTimer then
                        self:StopScanning()
                        self:StartScanning()
                    end
                end,
            },
            maxInvitesPerScan = {
                type = "range",
                name = "Max Invites Per Scan",
                desc = "Maximum invites to send per scan cycle",
                order = 32,
                min = 1,
                max = 10,
                step = 1,
                get = function() return self.db.profile.maxInvitesPerScan end,
                set = function(_, val) self.db.profile.maxInvitesPerScan = val end,
            },
            blacklistHeader = {
                type = "header",
                name = "Blacklist Settings",
                order = 40,
            },
            blacklistDuration = {
                type = "range",
                name = "Blacklist Duration (hours)",
                desc = "How long to blacklist players who decline or are in a group",
                order = 41,
                min = 1,
                max = 168,
                step = 1,
                get = function() return self.db.profile.blacklistDuration / 3600 end,
                set = function(_, val) self.db.profile.blacklistDuration = val * 3600 end,
            },
            blacklistCount = {
                type = "description",
                name = function()
                    return "Currently blacklisted: " .. self:GetBlacklistCount() .. " players"
                end,
                order = 42,
            },
            clearBlacklist = {
                type = "execute",
                name = "Clear Blacklist",
                desc = "Remove all players from the blacklist",
                order = 43,
                func = function()
                    self:ClearBlacklist()
                    self:Print("Blacklist cleared.")
                end,
            },
            blacklistList = {
                type = "description",
                name = function()
                    return "\nBlacklisted players:\n" .. self:GetBlacklistText()
                end,
                order = 44,
                fontSize = "medium",
            },
            blacklistRemove = {
                type = "input",
                name = "Remove from Blacklist",
                desc = "Enter player name to remove from blacklist",
                order = 45,
                get = function() return "" end,
                set = function(_, val)
                    if val and val:trim() ~= "" then
                        self:RemoveFromBlacklist(val:trim())
                        self:Print(val:trim() .. " removed from blacklist.")
                    end
                end,
            },
            whitelistHeader = {
                type = "header",
                name = "Whitelist",
                order = 50,
            },
            whitelistDesc = {
                type = "description",
                name = "Whitelisted players bypass the blacklist and will always be invited.",
                order = 51,
            },
            whitelistInput = {
                type = "input",
                name = "Add to Whitelist",
                desc = "Enter player name to always invite (bypasses blacklist)",
                order = 52,
                get = function() return "" end,
                set = function(_, val)
                    if val and val:trim() ~= "" then
                        self:AddToWhitelist(val:trim())
                        self:Print(val:trim() .. " added to whitelist.")
                    end
                end,
            },
            whitelistRemove = {
                type = "input",
                name = "Remove from Whitelist",
                desc = "Enter player name to remove from whitelist",
                order = 53,
                get = function() return "" end,
                set = function(_, val)
                    if val and val:trim() ~= "" then
                        self:RemoveFromWhitelist(val:trim())
                        self:Print(val:trim() .. " removed from whitelist.")
                    end
                end,
            },
        },
    }
end
