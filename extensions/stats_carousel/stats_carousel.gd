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
onready var _page_label: Label = $"%PageLabel"
onready var _left_normal_texture: Texture = arrow_left.texture_normal
onready var _left_focus_texture: Texture = arrow_left.texture_focused
onready var _right_normal_texture: Texture = arrow_right.texture_normal
onready var _right_focus_texture: Texture = arrow_right.texture_focused

var active: bool = true setget _set_active

func _set_active(value):
    active = value
    $MarginContainer.visible = value
    set_process_input(active and is_visible_in_tree())

# ══════════════════════════════════════════ Setter ══════════════════════════════════════════ #

func _set_enable_trigger_buttons(value):
    enable_trigger_buttons = value
    _update_arrows()

func _set_index(value):
    value = int(clamp(value, 0, max_index)) if max_index >= 0 else 0
    index = value
    _update_arrows()
    _update_page_label()

func _set_player_index(value):
    player_index = value
    _update_arrows()

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _ready() -> void:
    _set_index(index)
    _set_active(active)
    _page_label.visible = show_page_label
    # InputService also updates its mode during input dispatch; refresh afterwards.
    UIService.connect("change_device", self, "_update_arrows", [], CONNECT_DEFERRED)

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
        set_process_input(active and is_visible_in_tree())

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func _update_arrows() -> void:
    if not arrow_left or not arrow_right:
        return

    var use_triggers: bool = are_trigger_buttons_active()
    arrow_left.disabled = use_triggers or not _sequence_has_prev
    arrow_left.modulate.a = 0.0 if not _sequence_has_prev else ARROW_ALPHA
    arrow_right.disabled = use_triggers or not _sequence_has_next
    arrow_right.modulate.a = 0.0 if not _sequence_has_next else ARROW_ALPHA

    var left_texture: Texture = null
    var right_texture: Texture = null
    if use_triggers:
        left_texture = CoopService.get_player_key_texture("ltrigger", player_index)
        right_texture = CoopService.get_player_key_texture("rtrigger", player_index)

    if left_texture:
        _set_arrow_texture(arrow_left, left_texture, left_texture)
    else:
        _set_arrow_texture(arrow_left, _left_normal_texture, _left_focus_texture)
    if right_texture:
        _set_arrow_texture(arrow_right, right_texture, right_texture)
    else:
        _set_arrow_texture(arrow_right, _right_normal_texture, _right_focus_texture)

func _update_page_label() -> void:
    if not _page_label:
        return

    var total = max_index + 1
    if total <= 1:
        _page_label.text = ""
    else:
        _page_label.text = label_format % [index + 1, total]

func are_trigger_buttons_active() -> bool:
    return player_index >= 0 and enable_trigger_buttons and Utils.is_player_using_gamepad(player_index)

func _set_arrow_texture(arrow: TextureButton, texture: Texture, focused_texture: Texture) -> void:
    arrow.texture_normal = texture
    arrow.texture_pressed = texture
    arrow.texture_hover = texture
    arrow.texture_disabled = texture
    arrow.texture_focused = focused_texture

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
            return
    else:
        if not _sequence_has_prev:
            return
        if has_prev_page():
            _set_index(index - 1)
            emit_signal("page_changed", tab, index)
            emit_signal("arrow_left_pressed")
            return

    emit_signal("boundary_requested", direction)

# ══════════════════════════════════════════ Callback ══════════════════════════════════════════ #
func _on_ArrowLeft_pressed():
    _request_step(-1)

func _on_ArrowRight_pressed():
    _request_step(1)
