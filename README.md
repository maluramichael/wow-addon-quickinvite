# QuickInvite

A World of Warcraft addon that automatically invites nearby players within a configurable level range. Perfect for quickly forming groups while questing or grinding.

## Features

### Auto-Invite System
- Automatically scans for and invites nearby players
- Uses nameplates, target, and mouseover to detect players
- Configurable level range (your level +/- X levels)
- Limits invites per scan to avoid spam
- Stops scanning when group is full (5 players)

### Smart Blacklisting
- Automatically blacklists players who decline invites
- Automatically blacklists players already in a group
- Configurable blacklist duration (1-168 hours)
- Manual blacklist clearing option

### Whitelist System
- Add friends or regular groupmates to whitelist
- Whitelisted players bypass the blacklist
- Always get invited when detected nearby

### Configuration Options
- **Level Range**: Only invite players within X levels of you (0-10)
- **Scan Interval**: How often to scan for players (1-30 seconds)
- **Max Invites Per Scan**: Limit invites per cycle (1-10)
- **Blacklist Duration**: How long to blacklist declined players

## Installation

1. Download the latest release
2. Extract to `World of Warcraft\_classic_era_\Interface\AddOns\`
3. Restart WoW or `/reload`

## Usage

The addon starts **disabled** by default for safety. Enable it when you want to auto-invite:

- `/qi toggle` - Toggle auto-invite on/off
- `/qi config` - Open configuration panel

### Macro Support
```
/run QuickInvite:Toggle()
```

## Slash Commands

| Command | Description |
|---------|-------------|
| `/qi help` | Show help |
| `/qi toggle` | Toggle auto-invite on/off |
| `/qi enable` or `/qi on` | Enable auto-invite |
| `/qi disable` or `/qi off` | Disable auto-invite |
| `/qi config` | Open configuration panel |
| `/qi status` | Show current status and settings |
| `/qi clearblacklist` | Clear the blacklist |
| `/qi debug` | Toggle debug output |

## How It Works

1. When enabled, scans nearby nameplates every X seconds
2. Checks if player is friendly, not in your group, and within level range
3. Skips blacklisted players (unless whitelisted)
4. Sends invite and tracks pending invites (60s cooldown)
5. If declined or already in group, adds to blacklist

## Requirements

- World of Warcraft Classic Era (Interface 11508)
- Ace3 libraries (embedded)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
