local addonName, addon = ...
local QuickInvite = addon

function QuickInvite:AddToBlacklist(playerName)
    local expireTime = time() + self.db.profile.blacklistDuration
    self.db.profile.blacklist[playerName:lower()] = expireTime
    self:Print(playerName .. " blacklisted for " ..
        self:FormatDuration(self.db.profile.blacklistDuration))
end

function QuickInvite:RemoveFromBlacklist(playerName)
    self.db.profile.blacklist[playerName:lower()] = nil
end

function QuickInvite:IsBlacklisted(playerName)
    local expireTime = self.db.profile.blacklist[playerName:lower()]
    if expireTime then
        if time() < expireTime then
            return true
        else
            self.db.profile.blacklist[playerName:lower()] = nil
            return false
        end
    end
    return false
end

function QuickInvite:IsWhitelisted(playerName)
    return self.db.profile.whitelist[playerName:lower()] == true
end

function QuickInvite:AddToWhitelist(playerName)
    self.db.profile.whitelist[playerName:lower()] = true
end

function QuickInvite:RemoveFromWhitelist(playerName)
    self.db.profile.whitelist[playerName:lower()] = nil
end

function QuickInvite:CleanBlacklist()
    local now = time()
    local cleaned = 0
    for name, expireTime in pairs(self.db.profile.blacklist) do
        if now >= expireTime then
            self.db.profile.blacklist[name] = nil
            cleaned = cleaned + 1
        end
    end
    if cleaned > 0 then
        self:Print("Cleaned " .. cleaned .. " expired blacklist entries.")
    end
end

function QuickInvite:ClearBlacklist()
    wipe(self.db.profile.blacklist)
end

function QuickInvite:GetBlacklistCount()
    local count = 0
    local now = time()
    for name, expireTime in pairs(self.db.profile.blacklist) do
        if now < expireTime then
            count = count + 1
        end
    end
    return count
end

function QuickInvite:FormatDuration(seconds)
    if seconds >= 86400 then
        return string.format("%.1f days", seconds / 86400)
    elseif seconds >= 3600 then
        return string.format("%.1f hours", seconds / 3600)
    elseif seconds >= 60 then
        return string.format("%.0f minutes", seconds / 60)
    else
        return string.format("%.0f seconds", seconds)
    end
end

function QuickInvite:GetBlacklistEntries()
    local entries = {}
    local now = time()
    for name, expireTime in pairs(self.db.profile.blacklist) do
        if now < expireTime then
            local remaining = expireTime - now
            table.insert(entries, {
                name = name,
                expires = self:FormatDuration(remaining)
            })
        end
    end
    table.sort(entries, function(a, b) return a.name < b.name end)
    return entries
end

function QuickInvite:GetBlacklistText()
    local entries = self:GetBlacklistEntries()
    if #entries == 0 then
        return "No players blacklisted."
    end
    local lines = {}
    for _, entry in ipairs(entries) do
        table.insert(lines, string.format("  %s (expires in %s)", entry.name, entry.expires))
    end
    return table.concat(lines, "\n")
end
