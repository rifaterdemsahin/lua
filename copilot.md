# GitHub Copilot Context

This repository contains **Lua scripts** for automating [DaVinci Resolve](https://www.blackmagicdesign.com/products/davinciresolve) video production pipelines, plus supporting Python helper scripts and documentation.

## Repository Structure

```
lua/
├── index.html              # Root navigation page → links to all 7 sections
├── README.md               # Project overview and quick-start guide
├── copilot.md              # This file — Copilot context and guidelines
├── 1_Real_Unknown/         # Objectives and OKRs
├── 2_Environment/          # Environment setup, install paths, env vars
├── 3_Simulation/           # Main HTML page with examples and full docs
│   └── index.html          # Comprehensive single-page reference
├── 4_Formula/              # Step-by-step guide and deploy scripts
├── 5_Symbols/              # Lua script source files
│   ├── chaptermarkers.lua  # Creates animated chapter title cards
│   └── fill_last_marker.lua # Auto-fills markers with subtitle text
├── 6_Semblance/            # Error logs and solutions
└── 7_Testing_Known/        # Acceptance criteria and test data
```

## Key Scripts

### `5_Symbols/chaptermarkers.lua`
Creates animated Fusion `Text+` title cards for each chapter, with fade-in/fade-out, over a black background. Edit the `chapter_titles` table at the top of the file to set your chapter names.

### `5_Symbols/fill_last_marker.lua`
Finds the last timeline marker without subtitle text in its note and auto-fills it from the nearest subtitle clip. Run once per marker drop.

## Development Guidelines

- **Language:** Lua 5.1 (DaVinci Resolve scripting environment)
- **API:** DaVinci Resolve scripting API accessed via `Resolve()` global
- **Style:** Use local variables, descriptive names, `--` inline comments and `--[[ ]]` block comments
- **Error handling:** Always check `if not timeline then ... return end` before operating on timeline objects
- **No external dependencies:** All scripts must run from Workspace → Scripts without installing anything extra

## HTML Pages

- `index.html` (root) — Navigation hub; links to each section of `3_Simulation/index.html`
- `3_Simulation/index.html` — Full single-page reference with embedded Lua code, copy buttons, and Prism.js syntax highlighting
- `1_Real_Unknown/post_prod_todo.html` — Post-production task list

When editing HTML files, match the existing dark-theme style (`#1a1a2e` background, `#e94560` accent, `#a8b2d8` body text).

## Useful Links

- Live site: <https://rifaterdemsahin.github.io/lua/>
- DaVinci Resolve Scripting API docs: installed with Resolve at `%PROGRAMDATA%\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\`
