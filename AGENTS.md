# DragonShout AGENTS.md

Project-specific guidelines for DragonShout. See the parent `../AGENTS.md` for general WoW addon rules.

## Trigger Categories and Listeners

| Category    | Listener              | CLEU Sub-event          | Description                     |
|-------------|-----------------------|-------------------------|---------------------------------|
| interrupts  | InterruptListener     | SPELL_INTERRUPT         | Player interrupts a cast        |
| ccOnYou     | AuraListener            | SPELL_AURA_APPLIED      | CC debuff applied to player     |
| ccApplied   | AuraListener            | SPELL_AURA_APPLIED      | Player applies CC to enemy      |
| dispels     | DispelListener        | SPELL_DISPEL            | Player dispels an aura          |

## CLEU Event Handling Pattern

1. `CombatLogListener` registers `COMBAT_LOG_EVENT_UNFILTERED`
2. Handler calls `CombatLogGetCurrentEventInfo()` - never reads `...` args
3. Sub-event dispatch table routes to specific listener handlers
4. Each listener guards on `ns.playerGUID` (set by Lifecycle after PLAYER_LOGIN)
5. Listener calls `ns.Announcer.Announce(category, spellId, tokens)` which handles throttle, template substitution, and channel resolution

## Known Gotchas

1. `ns.playerGUID` is nil until PLAYER_LOGIN - all listeners must nil-check it
2. `SPELL_AURA_REFRESH` does NOT have an amount field at idx 16
3. `CC_TYPE[spellId] ~= nil` is the guard for CC detection in AuraListener - no separate IS_CC_SPELL table exists
4. `C_ChatInfo.SendChatMessage` is Retail 11.2+ only - fallback to `SendChatMessage`
5. AceEvent-3.0 shares a single `AceEvent30Frame` (one CallbackHandler dispatch frame across every addon that embeds AceEvent), so taint from any other addon's handlers accumulates on it. Registering `COMBAT_LOG_EVENT_UNFILTERED` through `AceEvent:RegisterEvent` can therefore trigger `ADDON_ACTION_FORBIDDEN`. Register CLEU on a private unnamed `CreateFrame("Frame")` inside `CombatLogListener` instead.

## Labels

| Label | Description |
| --- | --- |
| **Category** | |
| `C-Bug` | Unexpected or incorrect behavior |
| `C-Feature` | New feature or enhancement |
| `C-Performance` | Speed, memory, or efficiency improvement |
| `C-Usability` | UX improvement, better defaults, polish |
| `C-Code-Quality` | Refactor, cleanup, technical debt |
| `C-Documentation` | Docs, README, AGENTS.md, comments |
| `C-Localization` | Translation and locale support |
| **Area** | |
| `A-Core` | Addon lifecycle, slash commands, minimap icon |
| `A-Announcer` | Message formatting, throttling, channel resolution |
| `A-Listeners` | Combat log listeners (interrupt, CC/aura, dispel) |
| `A-Config` | Config schema, defaults, AceDB |
| `A-Options` | DragonShout_Options companion addon |
| `A-Appearance` | Visual styling, fonts, textures |
| `A-Localization` | Locale files, translations |
| `A-CI` | GitHub workflows, packaging, CI/CD |
| **Difficulty** | |
| `D-Good-First-Issue` | Good for newcomers |
| `D-Straightforward` | Clear scope, low risk |
| `D-Complex` | Multiple files or systems involved |
| `D-Expert` | Deep WoW API knowledge or tricky edge cases |
| **Platform** | |
| `P-Retail` | Retail (11.x / 12.x) |
| `P-TBC-Anniversary` | TBC Anniversary Classic |
| `P-MoP-Classic` | Mists of Pandaria Classic |
| `P-All-Versions` | Affects all supported versions |
| **Status** | |
| `S-Needs-Triage` | New issue awaiting review |

## GitHub Projects

- DragonShout has two projects: **DragonShout - Bugs** (project #10) and **DragonShout - Feature Requests** (project #11)
- Route by label: `C-Bug` -> Bugs project, `C-Feature` -> Feature Requests project
