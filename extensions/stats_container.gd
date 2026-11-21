extends "res://ui/menus/shop/stats_container.gd"

const MAX_PRIMARY_STATS_PER_GROUP: int = 16
const MAX_SECONDARY_STATS_PER_GROUP: int = 19

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
    _moresc_lock_stats_height()
    set_process_input(false)

func update_tab(tab: int) -> void:
    .update_tab(tab)
    _moresc_ensure_stats_carousel()
    _moresc_refresh_carousel_for_tab()

func update_player_stats(index: int) -> void:
    .update_player_stats(index)
    _moresc_ensure_stats_carousel()
    _stats_carousel.player_index = index

func _notification(what):
    if what == NOTIFICATION_VISIBILITY_CHANGED:
        call_deferred("set_process_input", false)

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

    var template: Control = last_group[0]
    for _i in range(missing):
        # Padding only reserves layout space; it must not run a real stat's script.
        var filler: Control = Control.new()
        filler.rect_min_size = template.get_combined_minimum_size()
        filler.size_flags_horizontal = template.size_flags_horizontal
        filler.size_flags_vertical = template.size_flags_vertical
        filler.mouse_filter = Control.MOUSE_FILTER_IGNORE
        filler.focus_mode = Control.FOCUS_NONE
        container.add_child(filler)
        last_group.append(filler)
        paddings.append(filler)
    return paddings

func _moresc_lock_stats_height() -> void:
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
    msc_apply_current_page_visibility()

func _moresc_connect_carousel() -> void:
    _stats_carousel.connect("page_changed", self, "_on_carousel_page_changed")
    _stats_carousel.connect("boundary_requested", self, "_on_carousel_boundary_requested")
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
    return _moresc_groups_for_tab(focused_tab)

func _moresc_groups_for_tab(tab: int) -> Array:
    if tab == Tab.PRIMARY:
        return primary_stats_groups
    else:
        return secondary_stats_groups

func msc_apply_current_page_visibility() -> void:
    if _stats_carousel == null:
        return

    var groups: Array = msc_get_current_groups()
    if groups.empty():
        _stats_carousel.set_sequence_edges(false, false)
        return

    var page: int = _stats_carousel.get_page()
    # Snapshot the focused row before it is hidden. Paging only re-anchors that
    # row to the same slot on the new page; it never steals focus from anywhere else.
    var focused_row: Control = _moresc_get_focused_control()
    var focused_slot: int = _moresc_page_slot(focused_row, groups, page)

    var all_stats: Array = primary_stats + secondary_stats + _primary_padding + _secondary_padding
    msc_set_nodes_visible(all_stats, false)
    msc_set_nodes_visible(groups[page], true)
    _moresc_update_sequence_edges(page)

    var found_first: bool = false
    for stat in primary_stats:
        if stat.visible:
            # Only real rows participate in focus navigation, never padding.
            if not found_first:
                first_primary_stat = stat
                found_first = true
            last_primary_stat = stat
            stat.enable_focus()
        else:
            stat.disable_focus()

    set_focus_neighbours()
    _moresc_reanchor_focus(focused_row, focused_slot)

func _moresc_update_sequence_edges(page: int) -> void:
    var has_prev: bool = page > 0
    var has_next: bool = page < _stats_carousel.max_index
    if show_buttons:
        var other_tab = Tab.SECONDARY if focused_tab == Tab.PRIMARY else Tab.PRIMARY
        var has_other_tab: bool = not _moresc_groups_for_tab(other_tab).empty()
        has_prev = has_prev or has_other_tab
        has_next = has_next or has_other_tab

    _stats_carousel.set_sequence_edges(has_prev, has_next)

func _moresc_wrap_to_tab(direction: int) -> void:
    var other_tab = Tab.SECONDARY if focused_tab == Tab.PRIMARY else Tab.PRIMARY
    if _moresc_groups_for_tab(other_tab).empty():
        other_tab = focused_tab

    update_tab(other_tab)
    if direction < 0:
        _stats_carousel.set_page(_stats_carousel.max_index)
    _moresc_after_step()

func _moresc_after_step() -> void:
    msc_apply_current_page_visibility()

func _moresc_get_focused_control() -> Control:
    if _stats_carousel == null:
        return null

    var player_index: int = _stats_carousel.player_index
    if player_index < 0:
        return null

    if RunData.is_coop_run and Utils.get_focus_emulator(player_index) == null:
        return null

    return Utils.get_player_focused_control(self, player_index)

func _moresc_page_slot(control: Control, groups: Array, page: int) -> int:
    # Slot is only meaningful for a row of the page that is currently shown.
    if control == null or page < 0 or page >= groups.size():
        return -1

    return groups[page].find(control)

func _moresc_reanchor_focus(focused_row: Control, focused_slot: int) -> void:
    if focused_row == null or focused_slot < 0:
        return
    if focused_row.visible:
        # The row survived the page change, so its focus was never lost.
        return

    var groups: Array = msc_get_current_groups()
    var page: int = _stats_carousel.get_page()
    if page < 0 or page >= groups.size():
        return

    var group: Array = groups[page]
    for i in range(min(focused_slot, group.size() - 1), -1, -1):
        var candidate: Control = group[i]
        if _moresc_can_take_focus(candidate):
            Utils.focus_player_control(candidate, _stats_carousel.player_index)
            return

func _moresc_can_take_focus(control: Control) -> bool:
    # Only real stat rows qualify: layout padding and the page-turn arrows are
    # never focus targets, and secondary rows stay display-only as in vanilla.
    # is_visible_in_tree() matches the guard inside Utils.focus_player_control(),
    # so a candidate is never silently dropped after being chosen.
    if control == null or not control.is_visible_in_tree():
        return false

    return control.focus_mode != Control.FOCUS_NONE

# ══════════════════════════════════════════ Callback ══════════════════════════════════════════ #
func _on_carousel_page_changed(_tab_value: int, _page_index: int) -> void:
    _moresc_after_step()

func _on_carousel_boundary_requested(direction: int) -> void:
    if not show_buttons:
        return

    _moresc_wrap_to_tab(direction)
