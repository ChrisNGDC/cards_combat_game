
# Idea general

La idea es que las partidas sean de una duración de 10/15’ (Buscamos que sea rápido y rejugable)
una ronda es hasta que ambos se quedan sin cartas o por efecto de combate
después de una ronda de combate una ronda de tienda, así hasta que la vida de uno de los 2 llegue a 0
para comprar en la tienda hacer solo 1 acción (de momento sin monedas u otro sistema) obtener carta, quitar carta, mejorar carta
Vida de jugador a ver para coordinar con la duración del juego y el daño de cartas


# Cartas

- ✔️ Daño físico (espada hace daño en base a la carta)
  - ✔️ Ataque físico rompe magia $\color{red}{(1)}$
- ✔️ Escudo (anula daño físico, no mejorable)
- ✔️ Daño mágico (ignora escudo, no hace mas daño que la espada,daño depende nivel carta)
  - ✔️ Magia subida de nivel aumento de daño menor que espada subida de nivel $\color{red}{(2)}$
- ✔️ Espejo (rebota el daño mágico, se rompe si recibe daño físico, no mejorable)
- ✔️ Poción (Solo cura si no recibes daño, curación en base al nivel, no supera máximo de vida)

# Items
- ❌ Ítems a introducir que afecten al juego externamente?

# Dificultad

- ✔️ Enemigo ataque al azar dificultad fácil
- ❌ Enemigo que juega en base a las cartas que tienes dificultad normal

# Mazos

- ✔️ Mago
  - ❌ no puede hacer daño físico pero su daño mágico aplica efecto $\color{red}{(3)}$
- ✔️ Luchador
  - ❌ no puede hacer daño magico pero su daño físico es mejor $\color{red}{(4)}$
- ✔️ Tanque
  - ✔️ mayor cantidad de vida y de cartas defensivas

# Mecanicas

- ✔️ Saber que hace le carta al estar encima con el mouse o al hacer click
- ✔️ Que el agarre de cartas sea cada vez que jugas una carta y no cuando terminas la de la mano
- ✔️ Cuando no podes robar carta dar opción de finalizar round o seguir hasta no tener mano

# Espacio para dudas, bugs y errores

| Sección | Referencia | Texto | Respuesta |
| :-----------: | :-----------: | :-----------: |  :-----------: |
| [Sección](#cartas) | $\color{red}{(1)}$ y $\color{red}{(2)}$ | Si la Espada escala mejor que la Magia <br> ¿No deberia de la Magia ganarle a la Espada? |
| [Sección](#mazos) | $\color{red}{(3)}$ | ¿Qué efecto podria tener? |
| [Sección](#mazos) | $\color{red}{(4)}$ | ¿A que se refiere con mejor? |

## Links de Ayuda

> **[Guia de Markdown](https://www.markdownguide.org/cheat-sheet)**
>
> **[Documentacion de Godot](https://docs.godotengine.org/en/stable/)**
