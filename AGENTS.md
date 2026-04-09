# DragonShout - Agent Guidelines

Project-specific guidelines for DragonShout. See the parent `../AGENTS.md` for general WoW addon rules.

---

## Build, Lint & Test

### Linting

Luacheck is the only static analysis tool. Config lives in `.luacheckrc` (Lua 5.1, 120 char lines, `Libs/` excluded).

```bash
# Lint entire addon
luacheck .

# Lint a single file (preferred during development)
luacheck DragonShout/Core/Init.lua

# CI-style (matches GitHub Actions workflow)
luacheck . --no-color
```

### Testing

No tests for now. No busted setup.

### Packaging

No local build step. BigWigsMods packager runs automatically via `packager.yml` (dispatched by `release.yml`). Release flow: merge to `master` -> release-please PR -> merge that PR -> tag + GitHub Release -> release.yml dispatches packager.yml -> packager publishes to CurseForge, Wago, GitHub Releases.

---

## Architecture

| Layer     | Directory    | Responsibility                                         |
|-----------|--------------|--------------------------------------------------------|
| Core      | `Core/`      | Addon lifecycle, config, announcer engine, slash cmds  |
| Listeners | `Listeners/` | CLEU dispatcher, interrupt/CC/dispel handlers           |
| Locales   | `Locales/`   | AceLocale translation tables                           |
| Libs      | `Libs/`      | Embedded Ace3 + utility libraries (never lint or edit) |

### Namespace Sub-tables

All modules attach to `ns`: `ns.Addon`, `ns.Announcer`, `ns.Lifecycle`, `ns.MinimapIcon`, `ns.CombatLogListener`, `ns.InterruptListener`, `ns.AuraListener`, `ns.DispelListener`.

### Repo Layout

```
DragonShout/                    (repo root)
  DragonShout/                  (main addon - maps to DragonShout/ after packaging)
    Core/                       (lifecycle, config, announcer, slash, minimap)
    Listeners/                  (CLEU dispatch, interrupt, CC, dispel)
    Locales/                    (11 locale files)
    Libs/                       (embedded libraries)
  DragonShout_Options/          (LoadOnDemand options addon)
    Tabs/                       (7 option tabs)
    Core.lua                    (DragonWidgets bridge)
```

### Trigger Categories and Listeners

| Category    | Listener              | CLEU Sub-event          | Description                     |
|-------------|-----------------------|-------------------------|---------------------------------|
| interrupts  | InterruptListener     | SPELL_INTERRUPT         | Player interrupts a cast        |
| ccOnYou     | AuraListener            | SPELL_AURA_APPLIED      | CC debuff applied to player     |
| ccApplied   | AuraListener            | SPELL_AURA_APPLIED      | Player applies CC to enemy      |
| dispels     | DispelListener        | SPELL_DISPEL            | Player dispels an aura          |

### CLEU Event Handling Pattern

1. `CombatLogListener` registers `COMBAT_LOG_EVENT_UNFILTERED`
2. Handler calls `CombatLogGetCurrentEventInfo()` - never reads `...` args
3. Sub-event dispatch table routes to specific listener handlers
4. Each listener guards on `ns.playerGUID` (set by Lifecycle after PLAYER_LOGIN)
5. Listener calls `ns.Announcer.Announce(category, spellId, tokens)` which handles throttle, template substitution, and channel resolution

### Ace3 Stack (mandatory, no raw alternatives)

| Library        | Purpose                  |
|----------------|--------------------------|
| AceAddon       | Addon lifecycle          |
| AceEvent       | Event registration       |
| AceTimer       | Timer scheduling         |
| AceDB          | SavedVariables profiles  |
| AceLocale      | Localization             |
| AceConsole     | Slash commands           |

---

## Known Gotchas

1. `ns.playerGUID` is nil until PLAYER_LOGIN - all listeners must nil-check it
2. `CombatLogGetCurrentEventInfo()` is the only way to read CLEU payload
3. `SPELL_AURA_REFRESH` does NOT have an amount field at idx 16
4. `CC_TYPE[spellId] ~= nil` is the guard for CC detection in AuraListener - no separate IS_CC_SPELL table exists
5. `C_ChatInfo.SendChatMessage` is Retail 11.2+ only - fallback to `SendChatMessage`

## Labels

### DragonShout Labels

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
- Status columns: **To triage -> Backlog -> Ready -> In progress -> In review -> Done**
- Move status as work progresses: To triage (filed) -> Backlog (scoped) -> In progress (branch created) -> In review (PR open) -> Done (merged)

