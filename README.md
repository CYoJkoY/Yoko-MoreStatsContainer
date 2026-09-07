<div align="center">

# Yoko-MoreStatsContainer

**A focused Brotato UI extension that turns oversized stat lists into navigable pages.**

<p>
  <a href="https://github.com/CYoJkoY/Yoko-MoreStatsContainer/releases"><img src="https://img.shields.io/github/v/release/CYoJkoY/Yoko-MoreStatsContainer?display_name=tag&sort=semver&style=flat-square&label=release" alt="Latest release"></a>
  <a href="https://github.com/CYoJkoY/Yoko-MoreStatsContainer/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/CYoJkoY/Yoko-MoreStatsContainer/release.yml?style=flat-square&label=build" alt="Build status"></a>
  <img src="https://img.shields.io/badge/Brotato-1.15.4-478CBF?style=flat-square" alt="Brotato 1.15.4">
  <img src="https://img.shields.io/badge/Mod%20Loader-6.3.0-5965FF?style=flat-square" alt="Mod Loader 6.3.0">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/CYoJkoY/Yoko-MoreStatsContainer?style=flat-square" alt="MIT License"></a>
</p>

<p><a href="#the-problem">The problem</a> · <a href="#features">Features</a> · <a href="#how-it-works">How it works</a> · <a href="#installation">Installation</a> · <a href="#development">Development</a></p>

</div>

## The problem

Brotato's character panel can become difficult to scan when a build exposes a large number of statistics. Yoko-MoreStatsContainer keeps the original stat data and update flow, but changes how the list is presented.

The mod separates primary and secondary statistics into pages and adds a compact carousel for navigation instead of allowing the entire panel to grow without structure.

## Features

| Feature | Behavior |
| :--- | :--- |
| Primary stats | Up to **16 entries per page** |
| Secondary stats | Up to **19 entries per page** |
| Carousel | Previous/next navigation with optional `current / total` feedback |
| Stable layout | Page changes do not make the surrounding panel jump vertically |
| Focus handling | Focus is restored after navigation |
| Gamepad | Uses the active player's remapped left/right trigger input through `CoopService` |

The mod is intentionally limited to presentation and navigation. It does not replace Brotato's underlying stat calculation or storage model.

## How it works

The implementation extends Brotato's existing `res://ui/menus/shop/stats_container.gd` rather than replacing the entire stats system.

```text
Brotato stats container
        │
        ▼
extensions/stats_container.gd
        │
        ├── run original stat update
        ├── group primary / secondary entries
        ├── create page groups
        └── update carousel + focus
                    │
                    ▼
             stats_carousel.tscn
```

The carousel is isolated as a reusable custom container with signals for page changes and navigation. The extension first lets the original update path do its work, then applies the pagination layer around the resulting entries.

## Usage

No additional in-game configuration is required.

Open Brotato's normal stats screen. When the number of entries exceeds the page capacity, use the carousel controls to switch pages. With a compatible gamepad, the active player's left/right triggers can navigate between pages.

## Installation

Download the latest `MoreStatsContainer-*.zip` from [Releases](https://github.com/CYoJkoY/Yoko-MoreStatsContainer/releases) and place the ZIP in Brotato's Mod Loader `mods` directory.

Keep the release ZIP compressed for normal installation.

Development layout:

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

## Compatibility

| Component | Declared target |
| :--- | :--- |
| Game | **Brotato 1.15.4** |
| Engine | Godot 3.x / GDScript |
| Mod Loader | **6.3.0** |
| Mod version | **1.1.0** |
| Dependencies | None |
| License | MIT |

`manifest.json` is the source of truth for the declared compatibility.

## Development

The main entry point is `mod_main.gd`. The stats extension lives under `extensions/`, and the carousel implementation is kept in its own folder.

Keep pagination independent from stat data. A page-size or navigation change should not require changing how Brotato calculates or stores statistics.

### Release pipeline

The release workflow uses semantic version tags and requires the tag to match `manifest.json` exactly:

```text
manifest.json: 1.1.0
        │
        ├── tag v1.1.0  → build allowed
        └── tag v1.2.0  → build rejected
```

The workflow imports Godot resources, generates the Mod Loader ZIP, preserves generated `.import` data, validates archive contents, and checks the packaged manifest version.

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

## Related project

[Yoko-Fantasy](https://github.com/CYoJkoY/Yoko-Fantasy) declares Yoko-MoreStatsContainer as a required dependency for its expanded gameplay systems.

## Contributing

Useful changes include concrete UI defects, controller-navigation improvements, compatibility fixes, and narrowly scoped presentation enhancements.

When changing the stats panel, keep the original stat update flow intact unless there is a clear integration reason to change it.

## Support

If this mod makes large Brotato builds easier to inspect, support is available through the deployed payment page:

**https://cyojkoy.github.io/Payment/**

## License

This project is licensed under the [MIT License](LICENSE).

<div align="center">
  <sub>Yoko-MoreStatsContainer · Brotato stats UI extension by CYoJkoY</sub>
</div>
