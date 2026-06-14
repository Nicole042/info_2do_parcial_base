# Segundo Parcial — Match-3 (Infografía, I/2026)

## Integrantes
- Nicole Agreda Candia — 88038
- Sara Revollo Mérida — 77931

## Cómo correr el juego
1. Instala [Godot 4.6](https://godotengine.org/download)
2. Abre esta carpeta desde el editor de Godot (botón Import → selecciona el `project.godot`)
3. Presiona `F5` o el botón Play ▶
4. La escena principal es `scenes/game.tscn`

## Mecánicas implementadas

### Base
- **B1** Puntaje que se actualiza en vivo en el HUD con cada combinación
- **B2** Límite de movimientos que disminuye con cada jugada y termina la partida al llegar a 0
- **B3** Pantalla de victoria y derrota con opción de reiniciar presionando R
- **B4** Efectos de sonido para intercambio, combinación y jugada inválida
- **B5** El juego corre sin errores y el bucle base funciona correctamente

### Obligatorias
- **M1** Sistema de 3 niveles con metas distintas, configurados desde archivos `.tres` externos
- **M2** Detección de bloqueo cuando no hay jugadas válidas y rebarajado automático del tablero
- **M3** Piezas especiales: combinación de 4 genera pieza de fila o columna, combinación de 5 genera bomba de color (Rainbow). Al combinar dos piezas especiales entre sí se activan efectos combinados
- **M4** Persistencia de progreso entre sesiones: se guarda el nivel alcanzado y el mejor puntaje en disco

### Bonus
- **Sistema de pistas** — si el jugador no mueve nada por 3 segundos, una pieza parpadea indicando una jugada posible
- **Sacudida de cámara** — al hacer una combinación la cámara vibra dando feedback visual al jugador

## Recursos externos consultados
- [Documentación oficial de Godot 4](https://docs.godotengine.org/en/stable/)
- [GDScript reference — FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html)
- [GDScript reference — JSON](https://docs.godotengine.org/en/stable/classes/class_json.html)
- [GDScript reference — Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html)
