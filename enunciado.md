# Segundo Parcial — Match-3 (Infografía, I/2026)

**Modalidad:** proyecto para casa, individual. **Plazo y fecha de entrega:** se publican en Moodle.
**Motor:** Godot 4.6. **Entrega:** URL de tu repositorio (ver *Entrega* al final).

---

## 1. Contexto

Recibes un juego **Match-3** funcional pero incompleto. El núcleo del juego ya está
resuelto: la grilla, el intercambio de piezas por deslizamiento, la detección de
combinaciones de 3 o más, la destrucción, la caída por gravedad, el rellenado y la
resolución de combos en cascada. Puedes abrir el proyecto en Godot 4.6 y jugar de
inmediato.

Lo que **no** está hecho es lo que convierte ese núcleo en un juego de verdad:
puntaje, objetivos, condiciones de victoria/derrota, piezas especiales y manejo de
tableros sin jugadas posibles. Ese es tu trabajo.

> **Aviso de honestidad académica (léelo).** El proyecto base sigue de cerca un
> tutorial público muy conocido de Match-3 en Godot. Los *episodios siguientes* de
> ese tutorial implementan exactamente los huecos que te dejamos (puntaje, contador,
> game over, piezas especiales). Puedes consultar recursos —y **debes citarlos** en tu
> README—, pero **limitarte a completar lo que hace el tutorial tiene un tope de 50/100**
> (ver *Regla de tope* en la sección de evaluación). El valor de tu entrega está en las
> mecánicas originales que el tutorial no cubre. El plagio entre compañeros y el
> "volcado único" de todo el código en un solo commit al final se penalizan.

---

## 2. Qué se te entrega

- `scripts/grid.gd` — toda la lógica del tablero (intercambio, match, destruir,
  colapsar, rellenar, cascada). Tiene marcadores `# TODO (PARCIAL):` en cada punto
  donde debes conectar tu trabajo.
- `scripts/piece.gd` — una pieza: su `color`, la animación `move()` y `dim()`.
- `scripts/top_ui.gd` — etiquetas de puntaje y contador, ya creadas pero sin conectar.
- `scenes/` — la escena `game.tscn` y las piezas de cada color.
- `assets/` — sprites de piezas (incluye **piezas especiales**: `Row`, `Column`,
  `Adjacent`, `Rainbow`), fuente, fondo y un paquete de **sonidos** (`Match 3 Sounds.zip`,
  aún sin extraer).

**Cómo ejecutarlo:** abre esta carpeta en el editor de Godot 4.6 y presiona `F5`
(o el botón *Play*). La escena principal es `scenes/game.tscn`.

---

## 3. Requisitos base — "termina el juego" (45 pts)

Esto es lo mínimo para tener un juego completo. Hecho con pulcritud te acerca al
tope de 50, pero **por sí solo no aprueba con holgura** (ver regla de tope).

| # | Requisito | Pts | Criterio de aceptación |
|---|---|---:|---|
| B1 | Puntaje + HUD | 10 | cada combinación suma puntaje; las etiquetas de `top_ui` se actualizan en vivo |
| B2 | Límite de movimientos (o tiempo) + contador | 8 | el contador disminuye con cada jugada; al llegar a 0 termina la partida |
| B3 | Victoria / derrota + pantalla final + reinicio | 15 | hay estados explícitos de ganar y perder; se muestra una pantalla; se puede volver a jugar |
| B4 | Efectos de sonido | 7 | sonidos de intercambio, combinación y jugada inválida, usando el paquete provisto |
| B5 | Corre limpio y jugable | 5 | sin errores en la consola; el bucle base sigue funcionando |

---

## 4. Mecánicas obligatorias — más allá del tutorial (45 pts)

Las **cuatro** son obligatorias. Aquí está el grueso de tu nota y lo que distingue
tu trabajo de una copia del tutorial.

### M1. Sistema de objetivos / niveles — 15 pts
- Al menos **2 o 3 niveles** con **metas distintas** entre sí. Ejemplos válidos:
  alcanzar un puntaje objetivo en N movimientos; recolectar N piezas de un color
  determinado; despejar casillas especiales.
- La configuración de cada nivel debe vivir en **datos**, no incrustada en el código
  (un `Resource` de Godot, un `.json` o `.tres` por nivel).
- *Aceptación:* se puede cambiar una meta editando solo datos; el HUD muestra la meta
  y el progreso; cumplir/ fallar la meta dispara victoria/derrota del nivel.

### M2. Detección de bloqueo + rebarajado — 10 pts
- Detectar cuando **no quedan jugadas válidas**: recorrer todos los intercambios
  posibles del tablero y comprobar si alguno produce una combinación.
- Si no hay ninguna, **rebarajar** (o reinyectar piezas) hasta que exista al menos
  una jugada posible.
- *Aceptación:* fuerza un tablero sin jugadas (puedes dejar un modo de prueba) y el
  juego lo detecta y lo resuelve sin intervención del jugador.

### M3. Piezas especiales + combinación — 14 pts
- Combinación de **4 en línea → pieza de línea** (limpia toda la fila o columna).
- Combinación de **5 → bomba de color** (elimina todas las piezas de un color).
- **Al menos un efecto de combinación** al intercambiar dos piezas especiales entre sí.
- Usa los sprites ya provistos (`Row`, `Column`, `Adjacent`, `Rainbow`).
- *Aceptación:* crear, activar y combinar especiales funciona y se ve; los efectos
  reingresan correctamente al ciclo de destruir/colapsar/rellenar.

### M4. Niveles data-driven / persistencia — 6 pts
- **Guardar progreso** entre sesiones: nivel alcanzado y **mejor puntaje**.
- La definición de niveles de M1 debe cargarse desde archivos externos.
- *Aceptación:* cierras y reabres el juego y conserva el progreso y el récord.

---

## 5. Bonus (tope 10 pts)

Suma solo si los requisitos base y obligatorios están sólidos. Ejemplos:
- Sistema de **pistas** (resaltar una jugada posible).
- **Tipos extra** de piezas especiales o efectos de combinación adicionales.
- **Partículas / juice**: feedback visual, sacudidas de cámara, animaciones de combo.
- **Tema / arte propio** que reemplace los assets base.
- Modo **semilla diaria** (tablero reproducible por fecha).

---

## 6. Evaluación

**Total:** 90 pts de requisitos + 10 pts de bonus = **100**.

| Bloque | Pts |
|---|---:|
| Base ("termina el juego") | 45 |
| Mecánicas obligatorias (M1–M4) | 45 |
| Bonus | 10 (tope) |

**Regla de tope:** si tu entrega **no implementa ninguna** de las cuatro mecánicas
obligatorias (es decir, solo completaste los stubs del estilo del tutorial), tu nota
**no supera 50/100**, sin importar cuán pulido esté lo demás.

**Calidad e integridad** (pueden bajar la nota): historial de commits con "volcado
único" de último momento, similitud alta con la entrega de otro compañero, o código
calcado del tutorial público sin aporte propio. Cita en tu README todo recurso externo
que hayas usado.

---

## 7. Entrega

1. Haz un **fork** (o copia a un repo propio) de este proyecto base.
2. Trabaja con **commits frecuentes y descriptivos**: el historial cuenta y se revisa.
3. En el **README** de tu repo, escribe: cómo correr el juego, qué mecánicas
   implementaste, y la lista de recursos externos consultados (con enlaces).
4. Entrega la **URL de tu repositorio** por Moodle antes de la fecha límite.

Asegúrate de que el proyecto **abra y corra en Godot 4.6 sin errores** en una
máquina limpia (no subas la carpeta `.godot/`).
