extends Node

const AUTHORNAME_MODNAME_DIR := "Yoko-MoreStatsContainer/"
const AUTHORNAME_MODNAME_LOG_NAME := "Yoko-MoreStatsContainer"

var mod_dir_path: String = ""
var ext_dir: String = ""
    
# =========================== Extension =========================== #
func _init() -> void:
    mod_dir_path = ModLoaderMod.get_unpacked_dir() + AUTHORNAME_MODNAME_DIR
    ext_dir = mod_dir_path + "extensions/"

    # Add extensions
    install_script_extensions()

# =========================== Custom =========================== #
func install_script_extensions() -> void:
    var extensions: Array = [

        "stats_container.gd",

    ]

    for path in extensions:
        var extension_path = ext_dir.plus_file(path)
        ModLoaderMod.install_script_extension(extension_path)
