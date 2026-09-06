<div align="center">

# Yoko-MoreStatsContainer

**A paginated stats interface for Brotato's in-game character panel.**

[![Latest Release](https://img.shields.io/github/v/release/CYoJkoY/Yoko-MoreStatsContainer?display_name=tag&sort=semver&style=flat-square)](https://github.com/CYoJkoY/Yoko-MoreStatsContainer/releases)
[![Build](https://img.shields.io/github/actions/workflow/status/CYoJkoY/Yoko-MoreStatsContainer/release.yml?style=flat-square&label=build)](https://github.com/CYoJkoY/Yoko-MoreStatsContainer/actions/workflows/release.yml)
[![Mod Loader](https://img.shields.io/badge/Mod%20Loader-6.3.0-5965FF?style=flat-square)](#compatibility)
[![Godot](https://img.shields.io/badge/Godot-3.x-478CBF?style=flat-square&logo=godot-engine&logoColor=white)](https://godotengine.org/)
[![License](https://img.shields.io/github/license/CYoJkoY/Yoko-MoreStatsContainer?style=flat-square)](LICENSE)

[Features](#features) · [Installation](#installation) · [Usage](#usage) · [How it works](#how-it-works) · [Development](#development)

</div>

---

## What it is

Yoko-MoreStatsContainer extends Brotato's existing stats container so large stat lists remain usable. Primary and secondary statistics are divided into pages, and a compact carousel lets the player move between those pages without replacing the underlying stat data.

The mod is intentionally focused: it changes presentation and navigation while keeping Brotato's original stat update flow in place.

## Features

| Feature | Behavior |
| :--- | :--- |
| **Primary stats** | Up to **16 entries per page** |
| **Secondary stats** | Up to **19 entries per page** |
| **Carousel** | Previous/next controls with optional `current / total` page feedback |
| **Stable layout** | Pagination does not cause the surrounding stats panel to jump vertically |
| **Focus handling** | Focus is restored after page changes |
| **Gamepad** | Uses the active player's remapped left/right trigger input through `CoopService` |

## Installation

Download the latest `MoreStatsContainer-*.zip` from [Releases](https://github.com/CYoJkoY/Yoko-MoreStatsContainer/releases) and place the ZIP in Brotato's Mod Loader `mods` directory.

Keep the release ZIP compressed for normal installation.

For source development:

```text
mods-unpacked/
└── Yoko-MoreStatsContainer/
    ├── extensions/
    │   ├── stats_container.gd
    │   └── stats_carousel/
    ├── manifest.json
    └── mod_main.gd
```

See the [Godot Mod Loader documentation](https://wiki.godotmodding.com/) for current installation conventions.

## Usage

No extra in-game configuration is required.

Open Brotato's normal stats screen. When the stat count exceeds the configured page capacity, use the carousel controls to switch pages. With a compatible gamepad, the active player's left/right triggers can be used for navigation.

## How it works

The mod extends Brotato's `res://ui/menus/shop/stats_container.gd` rather than replacing the entire stats system.

```text
Brotato stats container
        │
        ▼
extensions/stats_container.gd
        │
        ├── update original stats
        ├── group primary / secondary entries
        ├── create page groups
        └── update carousel + focus
                    │
                    ▼
             stats_carousel.tscn
```

The carousel is implemented as a reusable custom container with signals for page changes and navigation. The extension calls the original update path first, then applies the pagination layer around it.

## Development

The main entry point is `mod_main.gd`. The stats extension is under `extensions/`, while the carousel implementation is isolated in its own folder.

Keep pagination logic independent from the underlying stat data. Changes to page size, navigation, or presentation should not require changing how Brotato calculates or stores the statistics themselves.

The release workflow uses semantic version tags and now treats the repository manifest as authoritative:

```text
manifest.json: 1.1.0
        │
        ├── tag v1.1.0  → build allowed
        └── tag v1.2.0  → build rejected
```

The workflow also generates Godot import data, builds the Mod Loader ZIP, includes the generated `.import` cache, validates the ZIP structure, and verifies the packaged manifest version.

## Compatibility

| Component | Declared target |
| :--- | :--- |
| Engine | Godot 3.x / GDScript |
| Mod Loader | **6.3.0** |
| Mod version | **1.1.0** |
| Brotato game version | `0.0.1` declared in manifest |
| Dependencies | None |
| License | MIT |

The manifest is the source of truth for declared compatibility. The listed Brotato version should not be interpreted as a universal compatibility claim.

## Project structure

```text
Yoko-MoreStatsContainer/
├── .github/workflows/release.yml
├── extensions/
│   ├── stats_container.gd
│   └── stats_carousel/
│       ├── stats_carousel.gd
│       └── stats_carousel.tscn
├── manifest.json
├── mod_main.gd
├── README.md
└── LICENSE
```

## License

This project is licensed under the [MIT License](LICENSE).

## Support the Author

If this mod improves your Brotato interface or saves you time while testing content, consider supporting its continued development.

<div align="center">
  <a href="https://cyojkoy.github.io/Payment/">
    <img src="https://img.shields.io/badge/Support_the_Author-9E8F7E?style=for-the-badge&logo=buy-me-a-coffee&logoColor=BEB8AE" alt="Support the Author">
  </a>
</div>

---

<div align="center">
  <sub>Yoko-MoreStatsContainer · Brotato UI extension by CYoJkoY</sub>
</div>
