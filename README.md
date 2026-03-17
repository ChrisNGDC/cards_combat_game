
# Idea general

La idea es que las partidas sean de una duración de 10/15’ (Buscamos que sea rápido y rejugable)
una ronda es hasta que ambos se quedan sin cartas o por efecto de combate
después de una ronda de combate una ronda de tienda, así hasta que la vida de uno de los 2 llegue a 0
para comprar en la tienda hacer solo 1 acción (de momento sin monedas u otro sistema) obtener carta, quitar carta, mejorar carta
Vida de jugador a ver para coordinar con la duración del juego y el daño de cartas

# Referencias

- 🔴 No implementado
- 🟠 Implementado pero con dudas/errores
- 🟡 Implementado en parte
- 🟢 Implementado
- #️⃣ Referencia de dudas/errores

# Cartas

- 🟢 Espada (daño fisico en base al nivel)
  - 🟠 Ataque físico rompe magia 1️⃣
- 🟢 Escudo (bloquea daño fisico segun su nivel)
- 🟢 Magia (ignora escudo, no hace mas daño que la espada,daño depende nivel carta)
  - 🟠 Magia subida de nivel aumento de daño menor que espada subida de nivel 2️⃣
- 🟢 Espejo (rebota el daño mágico, se rompe si recibe daño físico, no mejorable)
- 🟢 Poción (Solo cura si no recibes daño, curación en base al nivel, no supera máximo de vida)

# Items

- 🔴 Ítems a introducir que afecten al juego externamente? 3️⃣

# Dificultad

- 🟢 Dificultad facil elige una carta de manera aleatoria
- 🟡 Dificultad normal toma en cuenta las cartas del  mazo del jugador
- 🟡 Dificultad dificil toma en cuenta las cartas de la mano del jugador

# Mazos

- 🟢 Mago (centrado en la magia)
- 🟢 Luchador (centrado en la espada)
- 🟢 Tanque (mayor cantidad de vida y de cartas defensivas)
- 🟢 Paladin (mezcla entre el luchador y el mago)

# Mecanicas

- 🟢 Saber que hace le carta al estar encima con el mouse o al hacer click
- 🟢 Que el agarre de cartas sea cada vez que jugas una carta y no cuando terminas la de la mano
- 🟢 Cuando no podes robar carta dar opción de finalizar round o seguir hasta no tener mano
- 🟢 Permitir ver las cartas pertenecientes a un mazo antes de seleccionarlo

# Espacio para dudas, bugs y errores

| Sección | Referencia | Texto | Respuesta |
| :-----------: | :-----------: | :-----------: |  :-----------: |
| [Cartas](#cartas) | 1️⃣ y 2️⃣ | Si la Espada escala mejor que la Magia <br> ¿No deberia de la Magia ganarle a la Espada? |
| [Items](#item) | 3️⃣ | ¿Para el jugador o el mazo? |

## Links de Ayuda

[Guia de Markdown](https://www.markdownguide.org/cheatsheet)

[Documentación de Godot](https://docs.godotengine.org/en/stable/)
