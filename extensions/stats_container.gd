extends "res://ui/menus/shop/stats_container.gd"

const MAX_PRIMARY_STATS_PER_GROUP: int = 17
const MAX_SECONDARY_STATS_PER_GROUP: int = 20

var primary_stats_groups: Array = []
var secondary_stats_groups: Array = []
var _stats_carousel: Container = null

# =========================== Extension =========================== #
func _init() -> void :
    call_deferred("_moresc_create_stats_carousel")

func _ready() -> void :
    _moresc_chunk_stats()
    _moresc_connect_carousel()

func update_tab(tab: int) -> void:
    .update_tab(tab)
    _moresc_refresh_carousel_for_tab()

# =========================== Custom =========================== #
func _moresc_create_stats_carousel() -> void:
    _stats_carousel = load("res://mods-unpacked/Yoko-MoreStatsContainer/extensions/stats_carousel/stats_carousel.tscn").instance()
    $"MarginContainer/VBoxContainer2".add_child(_stats_carousel)

func _moresc_chunk_stats() -> void:
    primary_stats_groups = msc_chunk_nodes(primary_stats, MAX_PRIMARY_STATS_PER_GROUP)
    secondary_stats_groups = msc_chunk_nodes(secondary_stats, MAX_SECONDARY_STATS_PER_GROUP)

func _moresc_connect_carousel() -> void:
    _stats_carousel.connect("page_changed", self, "_on_carousel_page_changed")
    _stats_carousel.connect("arrow_left_pressed", self, "_on_carousel_arrow_pressed")
    _stats_carousel.connect("arrow_right_pressed", self, "_on_carousel_arrow_pressed")
    _moresc_refresh_carousel_for_tab()

func _moresc_refresh_carousel_for_tab() -> void:
    var groups: Array = msc_get_current_groups()
    _stats_carousel.set_tab_and_pages(focused_tab, groups.size())
    msc_apply_current_page_visibility()

# =========================== Method =========================== #
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
    var groups: Array = msc_get_current_groups()
    if groups.empty():
        return

    var page: int = _stats_carousel.get_page()
    var all_stats: Array = primary_stats + secondary_stats
    msc_set_nodes_visible(all_stats, false)
    msc_set_nodes_visible(groups[page], true)

    for stat in primary_stats:
        if stat.visible:
            stat.enable_focus()
        else:
            stat.disable_focus()

func msc_grab_focus_on_current_page() -> void:
    var groups: Array = msc_get_current_groups()
    var page: int = _stats_carousel.get_page()
    var page_stats: Array = groups[page]
    var first: PanelContainer = page_stats[0]
    if first in primary_stats:
        first.enable_focus()
        first.call_deferred("grab_focus")

# =========================== Callback =========================== #
func _on_carousel_page_changed(_tab_value: int, _page_index: int) -> void:
	msc_apply_current_page_visibility()
	msc_grab_focus_on_current_page()

func _on_carousel_arrow_pressed() -> void:
	set_focus_neighbours()
