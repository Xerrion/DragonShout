# Changelog

## [1.3.2](https://github.com/Xerrion/DragonShout/compare/1.3.1...1.3.2) (2026-08-19)


### ⚙️ Miscellaneous Tasks

* update TOC Interface versions ([#35](https://github.com/Xerrion/DragonShout/issues/35)) ([25f5cea](https://github.com/Xerrion/DragonShout/commit/25f5cea58559eab7123416c1efea9c0612c80e30))

## [1.3.1](https://github.com/Xerrion/DragonShout/compare/1.3.0...1.3.1) (2026-07-14)


### ⚙️ Miscellaneous Tasks

* update TOC Interface versions ([#32](https://github.com/Xerrion/DragonShout/issues/32)) ([cb16718](https://github.com/Xerrion/DragonShout/commit/cb16718912b3f539cd86b5b4201cb49a5ed1ccad))
* update TOC Interface versions ([#34](https://github.com/Xerrion/DragonShout/issues/34)) ([038da32](https://github.com/Xerrion/DragonShout/commit/038da32f3e0c6e86ea4834a10509e53f89d1ac4a))

## [1.3.0](https://github.com/Xerrion/DragonShout/compare/1.2.1...1.3.0) (2026-05-15)


### 🚀 Features

* add debug log tab and split CC data by game version ([#30](https://github.com/Xerrion/DragonShout/issues/30)) ([5b24562](https://github.com/Xerrion/DragonShout/commit/5b2456218d28e5df08a84e527258d5e7908e791e))
* PR-23 ([#31](https://github.com/Xerrion/DragonShout/issues/31)) ([b43c855](https://github.com/Xerrion/DragonShout/commit/b43c855e8d17e63b6859650b832cebe439d0e9ca))


### 🐛 Bug Fixes

* avoid AceEvent shared-frame taint for combat log registration ([#22](https://github.com/Xerrion/DragonShout/issues/22)) ([#26](https://github.com/Xerrion/DragonShout/issues/26)) ([f85fe8b](https://github.com/Xerrion/DragonShout/commit/f85fe8b5ae7dcd06714e6213aa99b2bfb6cc1205))


### ⚙️ Miscellaneous Tasks

* code-quality cleanup batch ([#17](https://github.com/Xerrion/DragonShout/issues/17)) ([#20](https://github.com/Xerrion/DragonShout/issues/20)) ([562a8c4](https://github.com/Xerrion/DragonShout/commit/562a8c451b59d68e182e5d64ad8d1d28e070b921))
* ignore .deliverables/ orchestration scratchpad ([1502ed0](https://github.com/Xerrion/DragonShout/commit/1502ed0f50064fe53e77fdf6c849b0a483a8eb4d))

## [1.2.1](https://github.com/Xerrion/DragonShout/compare/1.2.0...1.2.1) (2026-04-22)


### ⚙️ Miscellaneous Tasks

* auto-assign all new issues to Xerrion ([#11](https://github.com/Xerrion/DragonShout/issues/11)) ([efab1a0](https://github.com/Xerrion/DragonShout/commit/efab1a012685042c75dd083c50f683f36baef3a8))
* update TOC Interface versions ([#14](https://github.com/Xerrion/DragonShout/issues/14)) ([5d9e89d](https://github.com/Xerrion/DragonShout/commit/5d9e89dd541fd5674f4c9cf277329e86f21896f2))

## [1.2.0](https://github.com/Xerrion/DragonShout/compare/1.1.0...1.2.0) (2026-04-15)


### 🚀 Features

* custom spell list UI with inline per-spell editing ([#8](https://github.com/Xerrion/DragonShout/issues/8)) ([#9](https://github.com/Xerrion/DragonShout/issues/9)) ([c89b53d](https://github.com/Xerrion/DragonShout/commit/c89b53d61c3b57b49af9cf51f791a780f156df17))


### 🐛 Bug Fixes

* correct DragonWidgets external path in .pkgmeta ([#10](https://github.com/Xerrion/DragonShout/issues/10)) ([cdc77cb](https://github.com/Xerrion/DragonShout/commit/cdc77cb80cb13cba665088ab54a3d9fcf7c8d472))


### ⚙️ Miscellaneous Tasks

* add manual-changelog and .release dir to pkgmeta ([737f677](https://github.com/Xerrion/DragonShout/commit/737f677ae4718f3a2c33b81c556271a7b147c40a))

## [1.1.0](https://github.com/Xerrion/DragonShout/compare/1.0.0...1.1.0) (2026-04-15)


### 🚀 Features

* add {type} and {duration} template tokens for CC announcements ([df54b78](https://github.com/Xerrion/DragonShout/commit/df54b788867e1d97d0531d5bb59446e43d3af1bb))
* add debug suite, fix playerGUID nil bug, fix test throttle, update CC templates ([f92d391](https://github.com/Xerrion/DragonShout/commit/f92d39153f67a30d7406d29a896026609e344bf6))
* add per-type Solo/Group/Raid channel selection ([#5](https://github.com/Xerrion/DragonShout/issues/5)) ([#6](https://github.com/Xerrion/DragonShout/issues/6)) ([2bb208b](https://github.com/Xerrion/DragonShout/commit/2bb208b8212b881ad45061b808c46774ddf34433))
* initial DragonShout addon scaffold ([5d1b05c](https://github.com/Xerrion/DragonShout/commit/5d1b05c2104769e9262c4a989425985b465c2bb1))
* per-CC-type template overrides and custom spell token help text ([9664381](https://github.com/Xerrion/DragonShout/commit/966438136e7b1b494905363f414f419ab4178610))


### 🐛 Bug Fixes

* correct CLEU dispatching, AuraListener robustness, and options degradation ([ab3a17d](https://github.com/Xerrion/DragonShout/commit/ab3a17d9b765b9a22c8c4cb167342ac5c2505000))
* wrap long debug print lines to pass luacheck W631 ([#4](https://github.com/Xerrion/DragonShout/issues/4)) ([24c7228](https://github.com/Xerrion/DragonShout/commit/24c72285049bc3c2755df42531159a351af0ed3c))


### 🚜 Refactor

* convert Options tabs to Section card layout ([9b74b36](https://github.com/Xerrion/DragonShout/commit/9b74b36a315ac341442ebe34ff9359922d7dae5d))
* merge CC tables, remove AuraListener ([ddfee81](https://github.com/Xerrion/DragonShout/commit/ddfee8109ff4c957d5a24617b97d86e987c0309b))
* rename CCListener to AuraListener ([39e15fe](https://github.com/Xerrion/DragonShout/commit/39e15fe534a1b5043b62686609bdbca6f6ff4ed9))


### ⚙️ Miscellaneous Tasks

* add 400x400 logo and 64x64 TGA icon ([#3](https://github.com/Xerrion/DragonShout/issues/3)) ([0066c1d](https://github.com/Xerrion/DragonShout/commit/0066c1db8486d43830f751779004ceb69b48969e))
* add CurseForge and Wago project IDs to TOC ([7856f5d](https://github.com/Xerrion/DragonShout/commit/7856f5d8a46686a35cfc62d22674b0978250b331))
* add issue templates, PR template, CODEOWNERS, FUNDING, and label/project docs ([#2](https://github.com/Xerrion/DragonShout/issues/2)) ([f444e4c](https://github.com/Xerrion/DragonShout/commit/f444e4c5ba839d45c4477671134dcd9330188328))
* initialize git submodules ([d0e32fe](https://github.com/Xerrion/DragonShout/commit/d0e32fe226aacdb5a3cd5aa9fca6f4a2da5d68f0))
* set ignore = dirty on all submodules ([c0d3a96](https://github.com/Xerrion/DragonShout/commit/c0d3a969f57675cab16418d1604d365645b42b8e))
