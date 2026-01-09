local addonName, addon = ...
local QuickInvite = addon

local nearbyPlayers = {}

function QuickInvite:StartScanning()
    if self.scanTimer then return end

    self.scanTimer = C_Timer.NewTicker(self.db.profile.scanInterval, function()
        self:ScanForPlayers()
    end)

    self:ScanForPlayers()
end

function QuickInvite:StopScanning()
    if self.scanTimer then
        self.scanTimer:Cancel()
        self.scanTimer = nil
    end
end

function QuickInvite:ScanForPlayers()
    if not self.db.profile.enabled then return end
    if GetNumGroupMembers() >= 5 then return end

    wipe(nearbyPlayers)

    local playerLevel = UnitLevel("player")
    local minLevel = playerLevel - self.db.profile.levelPadding
    local maxLevel = playerLevel + self.db.profile.levelPadding

    self:Debug("Scanning for players (level " .. minLevel .. "-" .. maxLevel .. ")")

    local invitesSent = 0

    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) then
            invitesSent = invitesSent + self:CheckUnit(unit, minLevel, maxLevel, invitesSent)
        end
    end

    if UnitExists("mouseover") then
        self:CheckUnit("mouseover", minLevel, maxLevel, invitesSent)
    end

    if UnitExists("target") then
        self:CheckUnit("target", minLevel, maxLevel, invitesSent)
    end
end

function QuickInvite:CheckUnit(unit, minLevel, maxLevel, invitesSent)
    if invitesSent >= self.db.profile.maxInvitesPerScan then return 0 end

    if not UnitIsPlayer(unit) then return 0 end

    if not UnitIsFriend("player", unit) then return 0 end

    if UnitIsUnit(unit, "player") then return 0 end

    if UnitInParty(unit) or UnitInRaid(unit) then return 0 end

    local name, realm = UnitName(unit)
    if not name then return 0 end

    local fullName = realm and realm ~= "" and (name .. "-" .. realm) or name

    if nearbyPlayers[fullName:lower()] then return 0 end
    nearbyPlayers[fullName:lower()] = true

    local level = UnitLevel(unit)
    if level < minLevel or level > maxLevel then
        self:Debug("Skipped " .. fullName .. " (level " .. level .. " out of range)")
        return 0
    end

    if not self:IsWhitelisted(fullName) and self:IsBlacklisted(fullName) then
        self:Debug("Skipped " .. fullName .. " (blacklisted)")
        return 0
    end

    if self.pendingInvites[fullName:lower()] then
        local pendingTime = self.pendingInvites[fullName:lower()]
        if time() - pendingTime < 60 then
            self:Debug("Skipped " .. fullName .. " (recently invited)")
            return 0
        end
    end

    self:InvitePlayer(fullName)
    return 1
end

function QuickInvite:InvitePlayer(playerName)
    InviteUnit(playerName)
    self.pendingInvites[playerName:lower()] = time()
    self:Print("Invited: " .. playerName)
end
