extends GdUnitTestSuite


func _assert_clave_propia(etiqueta: Node, clave: String) -> void:
	var texto: String = etiqueta.text
	var coincide: bool = texto == clave or texto == tr(clave)
	assert_bool(coincide).is_true().append_failure_message("clave esperada: " + clave + ", texto actual: " + texto)


func test_cabeceras_del_overlay_coinciden_con_sus_claves() -> void:
	# Regresion: las cabeceras AUDIO y LANGUAGE llegaron a estar intercambiadas.
	# No se conmuta el locale: la autotraduccion del motor sobre estas claves crudas
	# devuelve textos corruptos de forma no determinista bajo el runner headless.
	_assert_clave_propia(DebugOverlay.video_label, "VIDEO")
	_assert_clave_propia(DebugOverlay.audio_label, "AUDIO")
	_assert_clave_propia(DebugOverlay.lang_label, "LANGUAGE")
	var master: Label = DebugOverlay.get_node("SettingsPanel/SettingsContainer/AudioContainer/MasterContainer/MasterLabel")
	var music: Label = DebugOverlay.get_node("SettingsPanel/SettingsContainer/AudioContainer/MusicContainer/MusicLabel")
	var sfx: Label = DebugOverlay.get_node("SettingsPanel/SettingsContainer/AudioContainer/SFXContainer/SFXLabel")
	_assert_clave_propia(master, "GENERAL")
	_assert_clave_propia(music, "MUSIC")
	_assert_clave_propia(sfx, "SFX")
