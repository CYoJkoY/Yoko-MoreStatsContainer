extends "res://ui/menus/shop/stats_container.gd"

const MAX_PRIMARY_STATS_PER_GROUP: int = 16
const MAX_SECONDARY_STATS_PER_GROUP: int = 16

var primary_stats_groups: Array = []
var secondary_stats_groups: Array = []
var _stats_carousel: Container = null
var _primary_padding: Array = []
var _secondary_padding: Array = []

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _ready() -> void:
    _moresc_ensure_stats_carousel()
    _moresc_chunk_stats()
    _moresc_connect_carousel()
    # Do not force primary pages to the taller secondary page height.

func update_tab(tab: int) -> void:
    .update_tab(tab)
    _moresc_ensure_stats_carousel()
    _moresc_refresh_carousel_for_tab()

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func _moresc_ensure_stats_carousel() -> void:
    if _stats_carousel != null:
        return

    _stats_carousel = load("res://mods-unpacked/Yoko-MoreStatsContainer/extensions/stats_carousel/stats_carousel.tscn").instance()
    var layout = $"MarginContainer/VBoxContainer2"
    layout.add_child(_stats_carousel)
    # Keep navigation beside the tabs, above potentially long stat lists.
    layout.move_child(_stats_carousel, 2)
    layout.add_constant_override("separation", 8)

func _moresc_chunk_stats() -> void:
    # Base stats remain together on page one, including Luck and Harvesting.
    # DLC/mod stats stay available on subsequent pages without displacing them.
    var base_keys = ["STAT_MAX_HP", "STAT_HP_REGENERATION", "STAT_LIFESTEAL",
        "STAT_PERCENT_DAMAGE", "STAT_MELEE_DAMAGE", "STAT_RANGED_DAMAGE",
        "STAT_ELEMENTAL_DAMAGE", "STAT_ATTACK_SPEED", "STAT_CRIT_CHANCE",
        "STAT_ENGINEERING", "STAT_RANGE", "STAT_ARMOR", "STAT_DODGE",
        "STAT_SPEED", "STAT_LUCK", "STAT_HARVESTING"]
    var ordered: Array = []
    for key in base_keys:
        for stat in primary_stats:
            if stat.key == key:
                ordered.append(stat)
    for stat in primary_stats:
        if not stat in ordered:
            ordered.append(stat)
    primary_stats = ordered
    for i in range(primary_stats.size()):
        _primary_stats.move_child(primary_stats[i], i)
    primary_stats_groups = msc_chunk_nodes(primary_stats, MAX_PRIMARY_STATS_PER_GROUP)
    secondary_stats_groups = msc_chunk_nodes(secondary_stats, MAX_SECONDARY_STATS_PER_GROUP)
    # Invisible duplicated rows inflate the panel and can hide page controls.
    _primary_padding = []
    _secondary_padding = []

func _moresc_connect_carousel() -> void:
    _stats_carousel.connect("page_changed", self, "_on_carousel_page_changed")
    _stats_carousel.connect("arrow_left_pressed", self, "_on_carousel_arrow_pressed")
    _stats_carousel.connect("arrow_right_pressed", self, "_on_carousel_arrow_pressed")
    _moresc_refresh_carousel_for_tab()

func _moresc_refresh_carousel_for_tab() -> void:
    var groups: Array = msc_get_current_groups()
    _stats_carousel.set_tab_and_pages(focused_tab, groups.size())
    msc_apply_current_page_visibility()

# ══════════════════════════════════════════ Method ══════════════════════════════════════════ #
func msc_chunk_nodes(nodes: Array, chunk_size: int) -> Array:
    var result: Array = []
    for i in range(0, nodes.size(), chunk_size):
        result.append(nodes.slice(i, i + chunk_size - 1))

    return result

func msc_set_nodes_visible(nodes: Array, visible: bool):
    for n in nodes:
        n.visible = visible

func msc_get_current_groups() -> Array:
    if focused_tab == Tab.PRIMARY:
        return primary_stats_groups
    else:
        return secondary_stats_groups

func msc_apply_current_page_visibility() -> void:
    if _stats_carousel == null:
        return

    var groups: Array = msc_get_current_groups()
    if groups.empty():
        return

    var page: int = _stats_carousel.get_page()
    var all_stats: Array = primary_stats + secondary_stats + _primary_padding + _secondary_padding
    msc_set_nodes_visible(all_stats, false)
    msc_set_nodes_visible(groups[page], true)
    if focused_tab == Tab.PRIMARY:
        first_primary_stat = groups[page][0]
        last_primary_stat = groups[page][-1]
        set_focus_neighbours()

    for stat in primary_stats:
        if stat.visible:
            stat.enable_focus()
        else:
            stat.disable_focus()

    for filler in _primary_padding + _secondary_padding:
        filler.modulate.a = 0.0
        if filler.has_method("disable_focus"):
            filler.disable_focus()

func msc_grab_focus_on_current_page() -> void:
    var groups: Array = msc_get_current_groups()
    var page: int = _stats_carousel.get_page()
    var page_stats: Array = groups[page]
    var first: PanelContainer = page_stats[0]
    if first in primary_stats:
        first.enable_focus()
        first.call_deferred("grab_focus")

# ══════════════════════════════════════════ Callback ══════════════════════════════════════════ #
func _on_carousel_page_changed(_tab_value: int, _page_index: int) -> void:
    msc_apply_current_page_visibility()
    msc_grab_focus_on_current_page()

func _on_carousel_arrow_pressed() -> void:
    set_focus_neighbours()
