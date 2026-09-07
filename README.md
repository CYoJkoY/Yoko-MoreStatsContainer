<div align="center">
  <h1>Yoko-MoreStatsContainer</h1>
  <p><strong>Turn an oversized Brotato stat list into a compact, navigable interface.</strong></p>
  <p>Pagination · Primary / Secondary stats · Carousel · Focus · Controller</p>

  <p>
    <a href="https://github.com/CYoJkoY/Yoko-MoreStatsContainer/releases"><img src="https://img.shields.io/github/v/release/CYoJkoY/Yoko-MoreStatsContainer?display_name=tag&sort=semver&style=flat-square&label=release" alt="Latest release"></a>
    <a href="https://github.com/CYoJkoY/Yoko-MoreStatsContainer/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/CYoJkoY/Yoko-MoreStatsContainer/release.yml?style=flat-square&label=build" alt="Build status"></a>
    <img src="https://img.shields.io/badge/Brotato-1.15.4-478CBF?style=flat-square" alt="Brotato 1.15.4">
    <img src="https://img.shields.io/badge/Mod%20Loader-6.3.0-5965FF?style=flat-square" alt="Mod Loader 6.3.0">
    <a href="LICENSE"><img src="https://img.shields.io/github/license/CYoJkoY/Yoko-MoreStatsContainer?style=flat-square" alt="MIT License"></a>
  </p>

  <p><a href="#the-problem">Problem</a> · <a href="#behavior">Behavior</a> · <a href="#how-it-works">Architecture</a> · <a href="#installation">Install</a> · <a href="#development">Develop</a></p>
</div>

> **Design boundary:** the mod changes presentation and navigation, not Brotato's underlying stat calculation or storage model.

## The problem

Large Brotato builds can expose more statistics than the default container can present comfortably. MoreStatsContainer keeps the original stat update path, then turns the resulting list into pages instead of allowing the panel to grow without structure.

## Behavior

| Feature | Behavior |
| :--- | :--- |
| Primary stats | Up to **16 entries per page** |
| Secondary stats | Up to **19 entries per page** |
| Carousel | Previous / next navigation with optional `current / total` feedback |
| Layout | Page changes keep the surrounding panel stable |
| Focus | Focus is restored after navigation |
| Gamepad | Uses the active player's remapped left/right trigger input through `CoopService` |

No additional in-game configuration is required.

## How it works

The implementation extends Brotato's existing `res://ui/menus/shop/stats_container.gd` instead of replacing the complete statistics system.

```text
Brotato stats container
        │
        ▼
extensions/stats_container.gd
        │
        ├── run original stat update
        ├── group primary / secondary entries
        ├── create pages
        └── update carousel + focus
                    │
                    ▼
             stats_carousel.tscn
```

The extension first allows the original update path to produce the current entries, then applies pagination around that result. The carousel remains a small reusable component with page-change and navigation signals.

## Usage

Open Brotato's normal stats screen. When entries exceed the page capacity, use the carousel controls to switch pages.

With a compatible controller setup, the active player's left/right triggers can move between pages.

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

See the [Godot Mod Loader documentation](https://wiki.godotmodding.com/) for current conventions.

## Compatibility

| Component | Version |
| :--- | :--- |
| Brotato | **1.15.4** |
| Godot | 3.x / GDScript |
| Mod Loader | **6.3.0** |
| MoreStatsContainer | **1.1.0** |
| Dependencies | None |
| License | MIT |

`manifest.json` is the source of truth for compatibility.

## Development

`mod_main.gd` is the entry point. The game-specific extension lives in `extensions/stats_container.gd`, while the carousel implementation is isolated in `extensions/stats_carousel/`.

Keep pagination independent from stat calculation. A page-size or navigation change should not require changing how Brotato computes or stores statistics.

### Release validation

Release tags must match the manifest version exactly:

```text
manifest.json: 1.1.0
        │
        ├── v1.1.0     → build allowed
        └── v1.2.0     → build rejected
```

The workflow imports Godot resources, packages the Mod Loader ZIP, preserves generated `.import` data, validates archive contents, and checks the packaged manifest.

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

[Yoko-Fantasy](https://github.com/CYoJkoY/Yoko-Fantasy) declares MoreStatsContainer as a required dependency for its expanded gameplay systems.

## Contributing

Useful changes fix concrete UI defects, improve controller navigation, preserve compatibility, or make the presentation layer cleaner without coupling it to stat calculation.

When changing the stats panel, keep the original stat update flow intact unless there is a clear integration reason to alter it.

## Support

Development support is available through the deployed payment page:

**https://cyojkoy.github.io/Payment/**

## License

This project is licensed under the [MIT License](LICENSE).

<div align="center">
  <sub>Yoko-MoreStatsContainer · Brotato stats UI extension by CYoJkoY</sub>
</div>
