# Fase 4 — UI Gamification

**Rama:** `feature/ui-gamification-flutter`
**Fecha de cierre:** 2026-05-14
**Autor:** GuilermoT

## Qué se implementó

### PodiumWidget (`lib/features/gamification/presentation/widgets/podium_widget.dart`)

Se añade un `CircleAvatar` con las iniciales del nombre de equipo en cada posición
del podio, situado encima del emoji de medalla. Cambios:

- Se añade el método privado estático `_initials(String name)` a la clase `PodiumWidget`.
  Divide el nombre por espacios, descarta fragmentos vacíos, toma las dos primeras
  palabras y concatena su primera letra en mayúscula.
- En el `Column` de cada posición, antes del `Text(medals[i], ...)`, se inserta:
  ```dart
  CircleAvatar(
    radius: 20,
    backgroundColor: color.withValues(alpha: 0.2),
    child: Text(
      _initials(entry['name'] as String),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: color,
      ),
    ),
  ),
  const SizedBox(height: 4),
  ```
  El `color` es el mismo local de cada posición (plata / dorado / bronce), por lo
  que el fondo semitransparente y el texto heredan el tinte de su puesto.

La lógica de animación (`.animate().fadeIn().slideY()` con delays escalonados)
y el orden de `displayOrder` (2-1-3) no se modificaron.

## Decisiones técnicas

### CircleAvatar sobre Text plano

`CircleAvatar` es el widget semántico de Flutter para representar identidades
visuales circulares. Centra su `child` automáticamente sin necesidad de un
`Container` con `BoxDecoration` + `borderRadius` + `alignment`. Además, su
propiedad `backgroundImage` permite añadir un logo real de equipo en fases
futuras sin tocar la estructura del widget: basta con asignar `backgroundImage`
y el avatar lo mostrará en lugar del Text de iniciales.

### Cálculo de iniciales

```dart
static String _initials(String name) {
  final words = name.trim().split(' ').where((w) => w.isNotEmpty).take(2);
  return words.map((w) => w[0].toUpperCase()).join();
}
```

- `trim()` elimina espacios exteriores antes de dividir.
- `where((w) => w.isNotEmpty)` descarta múltiples espacios consecutivos.
- `take(2)` limita a dos palabras (máximo dos iniciales).
- `map((w) => w[0].toUpperCase())` extrae y capitaliza la primera letra.
- El resultado para "Real Madrid" es `RM`; para "Atlético" es `A`.

Se declaró `static` porque no accede a ningún estado de instancia ni al
contexto de build; mantenerlo estático hace explícito que es una función pura.

## Archivos modificados

- `lib/features/gamification/presentation/widgets/podium_widget.dart` — CircleAvatar con iniciales y método `_initials`

## Commits de esta fase

- `feat(gamification): add team initials CircleAvatar to podium_widget`
- `docs(memorias): add fase-4-ui-gamification memory`
