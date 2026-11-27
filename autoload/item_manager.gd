extends Node

var max_hp: Dictionary = {
	"nombre": "ITEM_MAX_HP",
	"ruta_imagen": "res://images/items/max_hp.png",
	"description": "ITEM_MAX_HP_DESC",
	"apilable": true,
	"descripcion_valor": 20,
	"efecto_adquisicion": func(character: Character) -> void:
		character.max_hp += 20
		character.heal(20),
}
var regen: Dictionary = {
	"nombre": "ITEM_REGEN",
	"ruta_imagen": "res://images/items/regen.png",
	"description": "ITEM_REGEN_DESC",
	"apilable": false,
	"bonos": { "EXCHANGE_HEAL": 2 },
	"descripcion_valor": 2,
}
var sword_damage: Dictionary = {
	"nombre": "ITEM_SWORD_DAMAGE",
	"ruta_imagen": "res://images/items/sword_damage.png",
	"description": "ITEM_SWORD_DAMAGE_DESC",
	"apilable": false,
	"bonos": { "SWORD_DAMAGE": 3 },
	"descripcion_valor": 3,
}
var shield_armor: Dictionary = {
	"nombre": "ITEM_SHIELD_ARMOR",
	"ruta_imagen": "res://images/items/shield_armor.png",
	"description": "ITEM_SHIELD_ARMOR_DESC",
	"apilable": false,
	"bonos": { "SHIELD_ARMOR": 5 },
	"descripcion_valor": 5,
}
var potion_heal: Dictionary = {
	"nombre": "ITEM_POTION_HEAL",
	"ruta_imagen": "res://images/items/potion_heal.png",
	"description": "ITEM_POTION_HEAL_DESC",
	"apilable": false,
	"bonos": { "POTION_HEAL": 5 },
	"descripcion_valor": 5,
}
var magic_damage: Dictionary = {
	"nombre": "ITEM_MAGIC_DAMAGE",
	"ruta_imagen": "res://images/items/magic_damage.png",
	"description": "ITEM_MAGIC_DAMAGE_DESC",
	"apilable": false,
	"bonos": { "MAGIC_DAMAGE": 3 },
	"descripcion_valor": 3,
}

var items_classes: Dictionary = {
	"ITEM_MAX_HP": max_hp,
	"ITEM_REGEN": regen,
	"ITEM_SWORD_DAMAGE": sword_damage,
	"ITEM_SHIELD_ARMOR": shield_armor,
	"ITEM_POTION_HEAL": potion_heal,
	"ITEM_MAGIC_DAMAGE": magic_damage,
}


func create_item(tipo: String) -> ItemData:
	if not items_classes.has(tipo):
		return null
	return ItemData.new(items_classes[tipo])


func get_oferta(personaje: Character) -> Array[ItemData]:
	var pool: Array[ItemData] = []
	for clave: String in items_classes:
		var definicion: Dictionary = items_classes[clave]
		if definicion.apilable or not personaje.has_item(definicion.nombre):
			pool.append(create_item(clave))
	pool.shuffle()
	var oferta: Array[ItemData] = []
	for i: int in range(min(3, pool.size())):
		oferta.append(pool[i])
	return oferta
