extends GdUnitTestSuite


var _volumenes_originales: Array[float] = []


func before_test() -> void:
	_volumenes_originales = [
		AudioManager.get_master_volume(),
		AudioManager.get_music_volume(),
		AudioManager.get_sfx_volume(),
	]


func after_test() -> void:
	AudioManager.set_master_volume(_volumenes_originales[0])
	AudioManager.set_music_volume(_volumenes_originales[1])
	AudioManager.set_sfx_volume(_volumenes_originales[2])


func test_volumen_medio_roundtrip_en_los_tres_buses() -> void:
	AudioManager.set_master_volume(0.5)
	AudioManager.set_music_volume(0.5)
	AudioManager.set_sfx_volume(0.5)
	assert_float(AudioManager.get_master_volume()).is_equal_approx(0.5, 0.001)
	assert_float(AudioManager.get_music_volume()).is_equal_approx(0.5, 0.001)
	assert_float(AudioManager.get_sfx_volume()).is_equal_approx(0.5, 0.001)


func test_volumen_uno_es_cero_db_sin_mute() -> void:
	AudioManager.set_master_volume(1.0)
	assert_float(AudioServer.get_bus_volume_db(AudioManager.master_bus_index)).is_equal_approx(0.0, 0.001)
	assert_bool(AudioServer.is_bus_mute(AudioManager.master_bus_index)).is_false()


func test_volumen_bajo_mutea_el_bus() -> void:
	AudioManager.set_master_volume(0.005)
	assert_bool(AudioServer.is_bus_mute(AudioManager.master_bus_index)).is_true()
	AudioManager.set_music_volume(0.0)
	assert_bool(AudioServer.is_bus_mute(AudioManager.music_bus_index)).is_true()
	AudioManager.set_sfx_volume(0.0)
	assert_bool(AudioServer.is_bus_mute(AudioManager.sfx_bus_index)).is_true()


func test_play_sfx_con_stream_null_no_crea_nada() -> void:
	var hijos_antes: int = AudioManager.get_child_count()
	AudioManager.play_sfx(null)
	assert_int(AudioManager.get_child_count()).is_equal(hijos_antes)


func test_play_sfx_crea_player_que_se_libera_al_terminar() -> void:
	var hijos_antes: int = AudioManager.get_child_count()
	AudioManager.play_sfx(load("res://sounds/sword_hit.wav"))
	assert_int(AudioManager.get_child_count()).is_equal(hijos_antes + 1)
	var instancia: AudioStreamPlayer = AudioManager.get_child(hijos_antes) as AudioStreamPlayer
	assert_str(instancia.bus).is_equal("SFX")
	# El driver Dummy de headless no emite finished: se emite manualmente
	instancia.finished.emit()
	assert_bool(instancia.is_queued_for_deletion()).is_true()
