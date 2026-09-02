extends "res://ui/menus/shop/stats_container.gd"

const MAX_PRIMARY_STATS_PER_GROUP: int = 16
const MAX_SECONDARY_STATS_PER_GROUP: int = 19

var primary_stats_groups: Array = []
var secondary_stats_groups: Array = []
var _stats_carousel: Container = null
var _primary_padding: Array = []
var _secondary_padding: Array = []
var _height_locked: bool = false

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _ready() -> void:
    _moresc_ensure_stats_carousel()
    _moresc_chunk_stats()
    _moresc_connect_carousel()
    _moresc_lock_stats_height()

func update_tab(tab: int) -> void:
    .update_tab(tab)
    _moresc_ensure_stats_carousel()
    _moresc_refresh_carousel_for_tab()

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func _moresc_ensure_stats_carousel() -> void:
    if _stats_carousel != null:
        return

    _stats_carousel = load("res://mods-unpacked/Yoko-MoreStatsContainer/extensions/stats_carousel/stats_carousel.tscn").instance()
    $"MarginContainer/VBoxContainer2".add_child(_stats_carousel)

func _moresc_chunk_stats() -> void:
    primary_stats_groups = msc_chunk_nodes(primary_stats, MAX_PRIMARY_STATS_PER_GROUP)
    secondary_stats_groups = msc_chunk_nodes(secondary_stats, MAX_SECONDARY_STATS_PER_GROUP)

    _primary_padding = _moresc_pad_last_group(_primary_stats, primary_stats_groups, MAX_PRIMARY_STATS_PER_GROUP)
    _secondary_padding = _moresc_pad_last_group(_secondary_stats, secondary_stats_groups, MAX_SECONDARY_STATS_PER_GROUP)

func _moresc_pad_last_group(container: Node, groups: Array, chunk_size: int) -> Array:
    var paddings: Array = []
    if groups.empty():
        return paddings

    var last_group: Array = groups[groups.size() - 1]
    var missing: int = chunk_size - last_group.size()
    if missing <= 0:
        return paddings

    var template: Node = last_group[0]
    for _i in range(missing):
        # Keep layout and script state, but never clone runtime signal connections.
        var filler: Control = template.duplicate(Node.DUPLICATE_SCRIPTS) as Control
        container.add_child(filler)
        _moresc_make_inert(filler)
        last_group.append(filler)
        paddings.append(filler)
    return paddings

func _moresc_make_inert(filler: Control) -> void:
    if filler == null:
        return

    filler.modulate.a = 0.0
    filler.mouse_filter = Control.MOUSE_FILTER_IGNORE
    filler.focus_mode = Control.FOCUS_NONE
    _moresc_clear_labels(filler)
    if filler.has_method("disable_focus"):
        filler.disable_focus()

func _moresc_clear_labels(node: Node) -> void:
    if node is Label:
        node.text = ""

    for child in node.get_children():
        _moresc_clear_labels(child)

func _moresc_lock_stats_height() -> void:
    if _height_locked:
        return

    var containers: Array = [_primary_stats, _secondary_stats]
    var groups_list: Array = [primary_stats_groups, secondary_stats_groups]
    var stats_list: Array = [primary_stats + _primary_padding, secondary_stats + _secondary_padding]
    var locked_height: float = 0.0
    for i in range(containers.size()):
        var groups: Array = groups_list[i]
        if groups.empty():
            continue

        for stat in stats_list[i]:
            stat.visible = false

        for stat in groups[0]:
            stat.visible = true

        locked_height = max(locked_height, (containers[i] as Control).get_combined_minimum_size().y)

    if locked_height <= 0.0:
        return

    (_primary_stats as Control).rect_min_size.y = locked_height
    (_secondary_stats as Control).rect_min_size.y = locked_height
    _height_locked = true
    msc_apply_current_page_visibility()

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
