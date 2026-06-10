# Segundo Parcial — Match-3 (Infografía, I/2026)

Proyecto base para el segundo parcial. Recibes un juego **Match-3** funcional pero
incompleto, hecho en **Godot 4.4**, y tu trabajo es convertirlo en un juego completo.

> 📋 **El enunciado completo, la rúbrica y los criterios de evaluación están en
> [`enunciado.md`](enunciado.md). Léelo antes de empezar.**

## Cómo correr el juego

1. Instala [Godot 4.4](https://godotengine.org/download).
2. Abre **esta carpeta** desde el editor de Godot (botón *Import* → selecciona el
   `project.godot`).
3. Presiona `F5` (o el botón *Play* ▶). La escena principal es `scenes/game.tscn`.

Deberías poder intercambiar piezas y ver combinaciones que se destruyen, caen y se
rellenan. Ese núcleo ya está resuelto.

## Por dónde empezar

El núcleo del juego está hecho; lo que falta está marcado en el código con comentarios
`# TODO (PARCIAL · <ítem>)`. Búscalos para saber exactamente dónde conectar cada cosa:

```
grep -rn "TODO (PARCIAL" scripts/
```

Cada marcador corresponde a un ítem de la rúbrica (B1–B5 base, M1–M4 obligatorias).

## Estructura

```
scenes/         escenas: game.tscn (principal), piece.tscn y las piezas de color
scripts/
  grid.gd         toda la lógica del tablero (intercambio, match, destruir, colapsar, rellenar)
  piece.gd        una pieza individual (color, animación de movimiento)
  top_ui.gd       el HUD: etiquetas de puntaje y contador (por conectar)
  level_config.gd andamiaje sugerido para niveles dirigidos por datos (M1/M4)
assets/         sprites de piezas (incluye especiales), fuente, fondo y sonidos
enunciado.md    el enunciado completo con la rúbrica
```

## Qué debes implementar (resumen)

**Base (termina el juego):** puntaje + HUD, límite de movimientos/tiempo, victoria/derrota
con pantalla final y reinicio, sonidos.
**Obligatorias (más allá del tutorial):** sistema de objetivos/niveles, detección de
bloqueo + rebarajado, piezas especiales + combos, niveles dirigidos por datos + persistencia.

Detalle y puntajes en [`enunciado.md`](enunciado.md).

## Entrega

1. Haz un **fork** (o copia a un repo propio) de este proyecto base.
2. Trabaja con **commits frecuentes y descriptivos**: el historial se revisa.
3. En **tu** README, escribe cómo correr el juego, qué mecánicas implementaste y los
   recursos externos que consultaste (con enlaces).
4. Entrega la **URL de tu repositorio** por Moodle antes de la fecha límite.

No subas la carpeta `.godot/` (ya está en `.gitignore`).
