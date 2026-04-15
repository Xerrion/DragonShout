<div align="center">

![Dragon Shout Logo](https://raw.githubusercontent.com/Xerrion/DragonShout/refs/heads/master/assets/DragonShout_logo-400x400.png)

# Dragon Shout

*Shout your interrupts, CC, and dispels in chat - so your group always knows.*

[![Latest Release](https://img.shields.io/github/v/release/Xerrion/DragonShout?style=for-the-badge)](https://github.com/Xerrion/DragonShout/releases/latest)
[![License](https://img.shields.io/github/license/Xerrion/DragonShout?style=for-the-badge)](LICENSE)
[![WoW Versions](https://img.shields.io/badge/WoW-Retail%20%7C%20MoP%20Classic%20%7C%20TBC%20Anniversary-blue?style=for-the-badge&logo=battledotnet)](https://worldofwarcraft.blizzard.com/)
[![Lint](https://img.shields.io/github/actions/workflow/status/Xerrion/DragonShout/lint.yml?style=for-the-badge&label=luacheck)](https://github.com/Xerrion/DragonShout/actions)

</div>

A highly customizable combat announcer addon for World of Warcraft. DragonShout sends chat messages when you interrupt, get CC'd, apply CC to enemies, or dispel.

## Features

- **Interrupt announcements** - Notify your group when you interrupt a cast
- **CC on you** - Announce when you are crowd controlled (silence, polymorph, stun, disorient, fear, root) with per-type toggles
- **CC applied** - Announce when you CC an enemy
- **Dispel announcements** - Notify when you dispel a debuff or buff
- **Custom spells** - Add any spell ID with a custom template and channel
- **Per-category channels** - Send each category to AUTO, PARTY, RAID, SAY, or YELL
- **Customizable templates** - Use {spell}, {target}, {source}, {extraSpell} tokens
- **Throttle control** - Prevent spam with configurable cooldown per spell
- **Profile support** - Save different configurations per character via AceDB profiles
- **DragonWidgets options UI** - Full config panel matching the Dragon addon family

## Supported Versions

- Retail (The War Within / Midnight)
- MoP Classic
- TBC Anniversary

## Installation

Install via CurseForge, Wago, or manually place the `DragonShout` and `DragonShout_Options` folders into your `Interface/AddOns/` directory.

## Slash Commands

- `/ds` or `/dragonshout` - Show help
- `/ds toggle` - Toggle addon on/off
- `/ds config` - Open settings panel
- `/ds status` - Show current settings
- `/ds help` - Show help

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](https://github.com/Xerrion/DragonShout/blob/master/LICENSE) file for details.

Made with ❤️ by [Xerrion](https://github.com/Xerrion)
