extends GdUnitTestSuite


var _backup: PackedByteArray = PackedByteArray()
var _habia_fichero: bool = false
var _config_original: ConfigFile = null
var _locale_original: String = ""
var _volumenes_originales: Array[float] = []


func before_test() -> void:
	_habia_fichero = FileAccess.file_exists(ConfigManager.SETTINGS_PATH)
	if _habia_fichero:
		var fichero: FileAccess = FileAccess.open(ConfigManager.SETTINGS_PATH, FileAccess.READ)
		_backup = fichero.get_buffer(fichero.get_length())
		fichero.close()
		DirAccess.remove_absolute(ConfigManager.SETTINGS_PATH)
	_config_original = ConfigManager.config
	ConfigManager.config = ConfigFile.new()
	_locale_original = TranslationServer.get_locale()
	_volumenes_originales = [
		AudioManager.get_master_volume(),
		AudioManager.get_music_volume(),
		AudioManager.get_sfx_volume(),
	]


func after_test() -> void:
	ConfigManager.config = _config_original
	TranslationServer.set_locale(_locale_original)
	AudioManager.set_master_volume(_volumenes_originales[0])
	AudioManager.set_music_volume(_volumenes_originales[1])
	AudioManager.set_sfx_volume(_volumenes_originales[2])
	if FileAccess.file_exists(ConfigManager.SETTINGS_PATH):
		DirAccess.remove_absolute(ConfigManager.SETTINGS_PATH)
	if _habia_fichero:
		var fichero: FileAccess = FileAccess.open(ConfigManager.SETTINGS_PATH, FileAccess.WRITE)
		fichero.store_buffer(_backup)
		fichero.close()


func test_load_resolution_sin_fichero_usa_default() -> void:
	assert_bool(ConfigManager.load_resolution() == Vector2i(1280, 720)).is_true()


func test_save_resolution_roundtrip() -> void:
	ConfigManager.save_resolution(1920, 1080)
	var releido: ConfigFile = ConfigFile.new()
	assert_int(releido.load(ConfigManager.SETTINGS_PATH)).is_equal(OK)
	assert_int(releido.get_value("video", "width")).is_equal(1920)
	assert_int(releido.get_value("video", "height")).is_equal(1080)
	assert_bool(ConfigManager.load_resolution() == Vector2i(1920, 1080)).is_true()


func test_save_language_persiste_y_aplica_locale() -> void:
	ConfigManager.save_language("en")
	assert_str(TranslationServer.get_locale()).starts_with("en")
	var releido: ConfigFile = ConfigFile.new()
	assert_int(releido.load(ConfigManager.SETTINGS_PATH)).is_equal(OK)
	assert_str(releido.get_value("general", "language")).is_equal("en")


func test_load_settings_reaplica_idioma_guardado() -> void:
	ConfigManager.save_language("en")
	TranslationServer.set_locale("es")
	ConfigManager.load_settings()
	assert_str(TranslationServer.get_locale()).starts_with("en")


func test_save_audio_volumes_roundtrip() -> void:
	AudioManager.set_master_volume(0.5)
	AudioManager.set_music_volume(0.6)
	AudioManager.set_sfx_volume(0.7)
	ConfigManager.save_audio_volumes()
	AudioManager.set_master_volume(1.0)
	AudioManager.set_music_volume(1.0)
	AudioManager.set_sfx_volume(1.0)
	ConfigManager.load_settings()
	assert_float(AudioManager.get_master_volume()).is_equal_approx(0.5, 0.001)
	assert_float(AudioManager.get_music_volume()).is_equal_approx(0.6, 0.001)
	assert_float(AudioManager.get_sfx_volume()).is_equal_approx(0.7, 0.001)
