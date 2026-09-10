extends "res://ui/menus/shop/stats_container.gd"

const MAX_PRIMARY_STATS_PER_GROUP: int = 16
const MAX_SECONDARY_STATS_PER_GROUP: int = 16

var primary_stats_groups: Array = []
var secondary_stats_groups: Array = []
var _stats_carousel: Container = null
var _primary_padding: Array = []
var _secondary_padding: Array = []
var _moresc_player_index: int = 0
var _moresc_ready_button: Control = null
var _moresc_ready_focus_before: NodePath = NodePath("")
var _moresc_tab_focus_before: Dictionary = {}

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _ready() -> void:
    _moresc_ensure_stats_carousel()
    _moresc_chunk_stats()
    _moresc_connect_carousel()
    connect("visibility_changed", self, "_moresc_on_visibility_changed")
    # Do not force primary pages to the taller secondary page height.

func update_tab(tab: int) -> void:
    .update_tab(tab)
    _moresc_ensure_stats_carousel()
    _moresc_refresh_carousel_for_tab()

func update_player_stats(player_index: int) -> void:
    _moresc_player_index = player_index
    .update_player_stats(player_index)
    if _stats_carousel != null:
        _stats_carousel.player_index = player_index
        # The enclosing shop carousel owns LB/RB. Page arrows remain focusable
        # with the D-pad and confirm, avoiding two carousels moving at once.
        _stats_carousel.enable_trigger_buttons = false
        _stats_carousel._update_arrows()
        _moresc_link_page_focus()

func set_focus_neighbours() -> void:
    .set_focus_neighbours()
    _moresc_link_page_focus()

func _moresc_link_page_focus() -> void:
    if _stats_carousel == null or _stats_carousel.max_index < 1:
        return
    var left = _stats_carousel.arrow_left
    var right = _stats_carousel.arrow_right
    left.focus_mode = Control.FOCUS_ALL if not left.disabled else Control.FOCUS_NONE
    right.focus_mode = Control.FOCUS_ALL if not right.disabled else Control.FOCUS_NONE
    if focused_tab == Tab.PRIMARY:
        _moresc_restore_ready_focus()
        for stat in primary_stats:
            if stat.visible:
                stat.focus_neighbour_left = stat.get_path_to(left) if not left.disabled else NodePath(".")
                stat.focus_neighbour_right = stat.get_path_to(right) if not right.disabled else NodePath(".")
        for arrow in [left, right]:
            arrow.focus_neighbour_bottom = arrow.get_path_to(first_primary_stat)
    elif is_visible_in_tree():
        # Secondary rows do not expose native stat tooltips/focus. Keep the
        # arrows linked to the enclosing shop's Ready button instead.
        var section = find_parent("CoopShopPlayerContainer*")
        if section != null and section.get("go_button") != null:
            var available = left if not left.disabled else right
            if _moresc_ready_button == null:
                _moresc_ready_button = section.go_button
                _moresc_ready_focus_before = section.go_button.focus_neighbour_bottom
            section.go_button.focus_neighbour_bottom = section.go_button.get_path_to(available)
            for arrow in [left, right]:
                arrow.focus_neighbour_top = arrow.get_path_to(section.go_button)
                arrow.focus_neighbour_bottom = arrow.get_path_to(section.go_button)
        elif show_buttons:
            var available = left if not left.disabled else right
            for tab in [_primary_tab, _secondary_tab]:
                if not _moresc_tab_focus_before.has(tab):
                    _moresc_tab_focus_before[tab] = tab.focus_neighbour_bottom
                tab.focus_neighbour_bottom = tab.get_path_to(available)
            for arrow in [left, right]:
                arrow.focus_neighbour_top = arrow.get_path_to(_secondary_tab)
                arrow.focus_neighbour_bottom = arrow.get_path_to(_secondary_tab)

func _moresc_on_visibility_changed() -> void:
    if is_visible_in_tree():
        call_deferred("_moresc_link_page_focus")
    else:
        _moresc_restore_ready_focus()

func _moresc_restore_ready_focus() -> void:
    for tab in _moresc_tab_focus_before:
        for arrow in [_stats_carousel.arrow_left, _stats_carousel.arrow_right]:
            if tab.focus_neighbour_bottom == tab.get_path_to(arrow):
                tab.focus_neighbour_bottom = _moresc_tab_focus_before[tab]
    _moresc_tab_focus_before.clear()
    if not is_instance_valid(_moresc_ready_button):
        _moresc_ready_button = null
        return
    var path = _moresc_ready_button.focus_neighbour_bottom
    for arrow in [_stats_carousel.arrow_left, _stats_carousel.arrow_right]:
        if path == _moresc_ready_button.get_path_to(arrow):
            _moresc_ready_button.focus_neighbour_bottom = _moresc_ready_focus_before
    _moresc_ready_button = null

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func _moresc_ensure_stats_carousel() -> void:
    if _stats_carousel != null:
        return

    _stats_carousel = load("res://mods-unpacked/Yoko-MoreStatsContainer/extensions/stats_carousel/stats_carousel.tscn").instance()
    _stats_carousel.enable_trigger_buttons = false
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
    _moresc_link_page_focus()

func msc_grab_focus_on_current_page() -> void:
    var groups: Array = msc_get_current_groups()
    var page: int = _stats_carousel.get_page()
    var page_stats: Array = groups[page]
    var first: PanelContainer = page_stats[0]
    if first in primary_stats:
        first.enable_focus()
        Utils.call_deferred("focus_player_control", first, _moresc_player_index)

# ══════════════════════════════════════════ Callback ══════════════════════════════════════════ #
func _on_carousel_page_changed(_tab_value: int, _page_index: int) -> void:
    msc_apply_current_page_visibility()
    msc_grab_focus_on_current_page()

func _on_carousel_arrow_pressed() -> void:
    set_focus_neighbours()
