class_name StatsCarousel
extends Container

const ARROW_ALPHA := 0.9

signal page_changed(tab, page_index)
signal arrow_left_pressed()
signal arrow_right_pressed()
signal boundary_requested(direction)

export var enable_trigger_buttons: bool = true setget _set_enable_trigger_buttons
export var show_page_label: bool = true
export var label_format: String = "%d / %d"

var index: int = 0 setget _set_index
var tab: int = 0
var max_index: int = -1
var player_index: int = -1 setget _set_player_index
var _sequence_has_prev: bool = true
var _sequence_has_next: bool = true

onready var arrow_left: TextureButton = $"%ArrowLeft"
onready var arrow_right: TextureButton = $"%ArrowRight"
onready var _headings: CenterContainer = $"%Headings"
onready var _page_label: Label = $"%PageLabel"

var active: bool = true setget _set_active

func _set_active(value):
    active = value
    $MarginContainer.visible = value

# ══════════════════════════════════════════ Setter ══════════════════════════════════════════ #

func _set_enable_trigger_buttons(value):
    enable_trigger_buttons = value
    if not is_inside_tree():
        return

    _try_activate_trigger_buttons()

func _set_index(value):
    value = int(clamp(value, 0, max_index)) if max_index >= 0 else 0
    index = value
    _update_arrows()
    _update_page_label()
    _try_activate_trigger_buttons()

func _set_player_index(value):
    player_index = value
    if value < 0:
        return

    _try_activate_trigger_buttons()

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _ready() -> void:
    _set_enable_trigger_buttons(enable_trigger_buttons)
    _set_index(index)
    _set_player_index(player_index)
    _set_active(active)
    set_process_input(false)

    if _headings and !_page_label:
        for child in _headings.get_children():
            if child is Label:
                _page_label = child
                break

        if !_page_label:
            var lbl := Label.new()
            lbl.name = "PageLabel"
            lbl.align = Label.ALIGN_CENTER
            _headings.add_child(lbl)
            _page_label = lbl

    _page_label.visible = show_page_label

func _input(event: InputEvent) -> void:
    if !active or !enable_trigger_buttons or player_index < 0:
        return

    if !Utils.is_player_using_gamepad(player_index):
        return

    if Utils.is_player_action_pressed(event, player_index, "ltrigger"):
        _request_step(-1)
    elif Utils.is_player_action_pressed(event, player_index, "rtrigger"):
        _request_step(1)

func _notification(what):
    if what == NOTIFICATION_VISIBILITY_CHANGED:
        set_process_input(is_visible_in_tree())

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func _update_arrows() -> void:
    if not arrow_left or not arrow_right:
        return

    arrow_left.disabled = not _sequence_has_prev
    arrow_left.modulate.a = 0.0 if not _sequence_has_prev else ARROW_ALPHA
    arrow_right.disabled = not _sequence_has_next
    arrow_right.modulate.a = 0.0 if not _sequence_has_next else ARROW_ALPHA

func _update_page_label() -> void:
    if not _page_label:
        return

    var total = max_index + 1
    if total <= 1:
        _page_label.text = ""
    else:
        _page_label.text = label_format % [index + 1, total]

func are_trigger_buttons_active() -> bool:
    return Utils.is_player_using_gamepad(player_index) and enable_trigger_buttons

func _set_arrow_texture(arrow: TextureButton, texture: Texture) -> void:
    arrow.texture_normal = texture
    arrow.texture_pressed = texture
    arrow.texture_hover = texture
    arrow.texture_disabled = texture
    arrow.texture_focused = texture

func _try_activate_trigger_buttons() -> void:
    if not are_trigger_buttons_active():
        return

    arrow_left.disabled = true
    arrow_right.disabled = true
    var ltrigger_texture = CoopService.get_player_key_texture("ltrigger", player_index)
    if ltrigger_texture:
        _set_arrow_texture(arrow_left, ltrigger_texture)
    var rtrigger_texture = CoopService.get_player_key_texture("rtrigger", player_index)
    if rtrigger_texture:
        _set_arrow_texture(arrow_right, rtrigger_texture)

# ══════════════════════════════════════════ Method ══════════════════════════════════════════ #
func set_tab_and_pages(tab_value: int, total_pages: int) -> void:
    tab = tab_value
    max_index = max(total_pages - 1, 0) as int
    _set_index(0)

func set_page(page_index: int) -> void:
    _set_index(page_index)

func set_sequence_edges(has_prev: bool, has_next: bool) -> void:
    _sequence_has_prev = has_prev
    _sequence_has_next = has_next
    _update_arrows()
    _try_activate_trigger_buttons()

func get_page() -> int:
    return index

func has_prev_page() -> bool:
    return index > 0

func has_next_page() -> bool:
    return index < max_index

func _request_step(direction: int) -> void:
    if not active:
        return

    if direction > 0:
        if not _sequence_has_next:
            return
        if has_next_page():
            _set_index(index + 1)
            emit_signal("page_changed", tab, index)
            emit_signal("arrow_right_pressed")
            if index == max_index and not arrow_left.disabled:
                arrow_left.call_deferred("grab_focus")
            return
    else:
        if not _sequence_has_prev:
            return
        if has_prev_page():
            _set_index(index - 1)
            emit_signal("page_changed", tab, index)
            emit_signal("arrow_left_pressed")
            if index == 0 and not arrow_right.disabled:
                arrow_right.call_deferred("grab_focus")
            return

    emit_signal("boundary_requested", direction)

# ══════════════════════════════════════════ Callback ══════════════════════════════════════════ #
func _on_ArrowLeft_pressed():
    _request_step(-1)

func _on_ArrowRight_pressed():
    _request_step(1)
