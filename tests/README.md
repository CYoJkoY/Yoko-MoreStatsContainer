# Stat panel regression tests

Use an isolated Brotato 1.1.15.4 configuration with ModLoader 6.3.0 and MoreStatsContainer. Set `application/config/use_custom_user_dir=true` and `application/config/custom_user_dir_name="Stats-Regression-Test"`. Package `Local-StatsRegression` under `mods-unpacked/`, then launch with `--stats-regression`. Both the flag and isolated profile marker are required; the test resets in-memory runs and exits.

Run with Abyssal and Fantasy enabled to reproduce base-stat displacement. Checks cover English/German, regular/pause-menu panel settings, all pages, Luck/Harvesting on page one, no padding duplicates, controller focus, navigation bounds and the 780px minimum-height budget. Require `CC_RESULT` with empty failures, exit 0 and no GDScript errors.

Validated locally using the retail PCK with a private script compatibility overlay and a headless Godot 3 build. Native rendering, Windows and arbitrary font/UI-mod combinations remain unverified. No proprietary game files are included.
