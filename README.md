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
  <p><a href="#the-problem">Problem</a> · <a href="#behavior">Behavior</a> · <a href="#architecture">Architecture</a> · <a href="#installation">Install</a> · <a href="#development--support">Development</a></p>
</div>

> **Design boundary:** this mod changes presentation and navigation, not Brotato's underlying stat calculation or storage model.

## <img src="assets/readme/icons/overview.svg" width="20" height="20" alt=""> The problem

Large Brotato builds can expose more statistics than the default container can present comfortably. MoreStatsContainer keeps the original update path, then turns the resulting list into pages instead of allowing the panel to grow without structure.

## <img src="assets/readme/icons/features.svg" width="20" height="20" alt=""> Behavior

| Feature | Behavior |
| :--- | :--- |
| Primary stats | Up to **16 entries per page** |
| Secondary stats | Up to **19 entries per page** |
| Carousel | Previous / next navigation with optional `current / total` feedback |
| Layout | Page changes keep the surrounding panel stable |
| Focus | Focus is restored after navigation |
| Gamepad | Uses active-player remapped left/right trigger input through `CoopService` |

No additional in-game configuration is required.

## <img src="assets/readme/icons/architecture.svg" width="20" height="20" alt=""> Architecture

The implementation extends Brotato's existing `res://ui/menus/shop/stats_container.gd` rather than replacing the statistics system.

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

The extension wraps the original update path; pagination remains independent from stat calculation.

## <img src="assets/readme/icons/installation.svg" width="20" height="20" alt=""> Installation

Requirements: **Brotato 1.15.4** and **Brotato Mod Loader 6.3.0**.

Download `MoreStatsContainer-*.zip` from [Releases](https://github.com/CYoJkoY/Yoko-MoreStatsContainer/releases) and place the ZIP in the Mod Loader `mods` directory.

```text
mods-unpacked/
└── Yoko-MoreStatsContainer/
    ├── extensions/
    ├── manifest.json
    └── mod_main.gd
```

## <img src="assets/readme/icons/development.svg" width="20" height="20" alt=""> Development & support

`mod_main.gd` is the entry point. `extensions/stats_container.gd` handles the game-specific integration and `extensions/stats_carousel/` contains the reusable navigation component.

Keep release tags synchronized with `manifest.json` version **1.1.0** and test controller navigation when changing focus or page behavior.

<a href="https://cyojkoy.github.io/Payment/"><img src="assets/readme/support-cta.svg" alt="Support Yoko-MoreStatsContainer" width="900" style="max-width:100%;height:auto;"></a>

Development support: **https://cyojkoy.github.io/Payment/**

## License

This project is licensed under the [MIT License](LICENSE).
