extends CanvasLayer

@onready var FPS_counter: Label = $Container/FPSLabel
@onready var settings_button: TextureButton = $Container/SettingsButton
@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var video_label: RichTextLabel = $SettingsPanel/SettingsContainer/VideoContainer/VideoLabel
@onready var res_button: Button = $SettingsPanel/SettingsContainer/VideoContainer/ResolutionContainer/ResolutionButton
@onready var fullscreen_button: Button = $SettingsPanel/SettingsContainer/VideoContainer/ResolutionContainer/FullscreenButton
@onready var audio_label: RichTextLabel = $SettingsPanel/SettingsContainer/AudioContainer/AudioLabel
@onready var master_slider: HSlider = $SettingsPanel/SettingsContainer/AudioContainer/MasterContainer/MasterSlider
@onready var master_slider_value: Label = $SettingsPanel/SettingsContainer/AudioContainer/MasterContainer/ValueLabel
@onready var lang_label: RichTextLabel = $SettingsPanel/SettingsContainer/LanguageContainer/LanguageLabel
@onready var lang_button: Button = $SettingsPanel/SettingsContainer/LanguageContainer/LanguageButton


var resolutions: Dictionary = {
	"1152x648": Vector2i(1152, 648),
	"1280x720": Vector2i(1280, 720),
	"1366x768": Vector2i(1366, 768),
	"1536x864": Vector2i(1536, 864),
	"1600x900": Vector2i(1600, 900),
	"1920x1080": Vector2i(1920, 1080)
}

func _ready() -> void:
	if OS.has_feature("web"):
		res_button.disabled = true
	else:
		_fill_resolution_options()

	var is_full: bool = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	var current_locale: String = TranslationServer.get_locale()
	
	if current_locale.begins_with("es"):
		lang_button.selected = 1
	else:
		lang_button.selected = 0

	fullscreen_button.button_pressed = is_full
	res_button.disabled = is_full

	video_label.bbcode_text = "[b][u]" + tr("VIDEO") + "[/u][/b]"
	lang_label.bbcode_text = "[b][u]" + tr("LANGUAGE") + "[/u][/b]"
	audio_label.bbcode_text = "[b][u]" + tr("AUDIO") + "[/u][/b]"

	master_slider.value = 100

	res_button.item_selected.connect(_on_resolution_selected)
	lang_button.item_selected.connect(_on_language_selected)
	fullscreen_button.toggled.connect(_on_fullscreen_toggled)


func _fill_resolution_options() -> void:
	res_button.clear()
	for res_text: String in resolutions.keys():
		res_button.add_item(res_text)

	var current_res: Vector2i = ConfigManager.load_resolution()
	for i: int in res_button.item_count:
		if resolutions.values()[i] == current_res:
			res_button.selected = i
			set_resolution(current_res)
			break


func _on_resolution_selected(index: int) -> void:
	var selected_res_text: String = res_button.get_item_text(index)
	var target_size: Vector2i = resolutions[selected_res_text]

	set_resolution(target_size)

func set_resolution(resolution: Vector2i) -> void:
	DisplayServer.window_set_size(resolution)
	var screen_center: Vector2i = DisplayServer.screen_get_position() + Vector2i(DisplayServer.screen_get_size() / 2.0)
	DisplayServer.window_set_position(screen_center - Vector2i(resolution / 2.0))
	ConfigManager.save_resolution(resolution.x, resolution.y)

func _on_fullscreen_toggled(is_pressed: bool) -> void:
	ConfigManager.save_fullscreen(is_pressed)
	res_button.disabled = is_pressed

func _process(_delta: float) -> void:
	FPS_counter.text = "FPS: " + str(Engine.get_frames_per_second())


func _on_settings_button_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(settings_button, "self_modulate", Color(0, 0, 0, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_settings_button_mouse_exited() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(settings_button, "self_modulate", Color(1, 1, 1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_settings_button_pressed() -> void:
	settings_panel.show()
	settings_button.hide()
	get_tree().paused = true

func _on_close_button_pressed() -> void:
	settings_button.show()
	settings_panel.hide()
	get_tree().paused = false

func _on_language_selected(index: int) -> void:
	match index:
		0:
			ConfigManager.save_language("en")
		1:
			ConfigManager.save_language("es")
	lang_label.bbcode_text = "[b][u]" + tr("LANGUAGE") + "[/u][/b]"
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	_on_close_button_pressed()
	if get_tree().current_scene.name != "MainMenu":
		SceneLoader.load_scene("res://scenes/main_menu.tscn")


func _on_master_slider_value_changed(value: float) -> void:
	master_slider_value.text = str(int(value))
