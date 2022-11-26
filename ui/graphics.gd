extends Popuppable

const file = "user://graphics.settings"
const SaveLoad := preload("res://addons/remap/private/SaveLoadUtils.gd") # so what its private, im using gdscript

enum {FULLSCREEN, BORDERLESS_FS, WINDOWED}
const map := {
  FULLSCREEN: DisplayServer.WINDOW_MODE_FULLSCREEN,
  WINDOWED: DisplayServer.WINDOW_MODE_WINDOWED,
}
const default_settings_data := {
  window = WINDOWED,
  vsync = false,
}

@onready var vsync: CheckBox = $"%vsyncbutton"
@onready var window: CaretOptionButton = $"%windowbutton"

var ignore_set_settings := false
var has_loaded := false

var settings := default_settings_data

func save() -> void:
  SaveLoad.save(file, settings)

func _ready() -> void:
  var lod := SaveLoad.load_file(file)
  settings = lod if dict_cmp(lod, default_settings_data) else default_settings_data # check if the keys and vaue types are correct
  has_loaded = true
  update_button_visuals()

static func dict_cmp(d1: Dictionary, d2: Dictionary) -> bool:
  return (
    len(d1) == len(d2)
    and sort(d1.keys()) == sort(d2.keys())
    and value_types(d1.values()) == value_types(d2.values())
  )

static func sort(arr: Array) -> Array:
  arr.sort()
  return arr

static func value_types(arr: Array) -> Array:
  var types = []
  for value in arr:
    types.append(typeof(value))
  types.sort()
  return types

func update_button_visuals():
  ignore_set_settings = true
  vsync.button_pressed = settings.vsync
  window.current_option = settings.window
  ignore_set_settings = false

func update_window():
  if settings.window == BORDERLESS_FS:
    DisplayServer.window_set_mode(map[FULLSCREEN])
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
  else:
    DisplayServer.window_set_mode(map[settings.window])

func update_vsync():
  var vsync_mode := DisplayServer.VSYNC_DISABLED if not settings.vsync else DisplayServer.VSYNC_ENABLED
  DisplayServer.window_set_vsync_mode(vsync_mode)

func _on_vsync_toggled(button_pressed: bool) -> void:
  if not has_loaded: return
  if not ignore_set_settings:
    settings.vsync = button_pressed
    save()
  update_vsync()

func _on_window_mode_changed(current_option: int) -> void:
  if not has_loaded: return
  if not ignore_set_settings:
    settings.window = current_option
    save()
  update_window()
