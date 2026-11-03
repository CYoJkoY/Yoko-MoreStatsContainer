extends Node

const AUTHORNAME_MODNAME_DIR := "Yoko-MoreStatsContainer/"

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _init() -> void:
    # Add extensions
    install_script_extensions()

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func install_script_extensions() -> void:
    var ext_dir: String = ModLoaderMod.get_unpacked_dir() + AUTHORNAME_MODNAME_DIR + "extensions/"
    var extensions: Array = [
        "stats_container.gd",
    ]

    for path in extensions:
        var extension_path = ext_dir.plus_file(path)
        ModLoaderMod.install_script_extension(extension_path)
