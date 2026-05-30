# Cambio puntual — Delta numérico en tendencia de clasificación

**Fecha:** 30/05/2026
**Archivo modificado:** `nextgen_fantasy/lib/shared/widgets/ranking_row.dart`

## Qué se cambió

El método privado `_trendIcon()` de `RankingRow` pasó de devolver un `Icon` suelto a devolver un `Row(mainAxisSize: MainAxisSize.min)` que combina el icono de dirección con un `Text` del delta numérico. La animación `.animate().fadeIn(duration: 300.ms)` se trasladó al `Row` completo.

| Caso | Resultado visual | Color |
|------|-----------------|-------|
| `trend > 0` | `↑ +2` (ejemplo) | `AppColors.primaryGreen` |
| `trend < 0` | `↓ -1` (ejemplo) | `AppColors.dangerRed` |
| `trend == 0` | `—` (sin cambio) | `AppColors.textSecondary` |

El caso neutro (`trend == 0`) sigue siendo solo el `Icon(Icons.remove)` porque no hay número significativo que mostrar.

## Comportamiento anterior

Solo se mostraba una flecha de dirección (↑ / ↓ / —). El usuario sabía si había subido o bajado, pero no cuántos puestos.

## Comportamiento nuevo

La flecha va acompañada del número de puestos: `↑ +2`, `↓ -1`. El signo (`+` para subidas, implícito el `-` para bajadas) se añade explícitamente en el `Text` formateando el `String` como `'+$trend'` o `'$trend'` respectivamente, ya que `trend` es negativo para bajadas y Dart lo serializa con el signo.

## Motivación

Aporta información cuantitativa de un vistazo sin cambiar la firma pública de `RankingRow` (`position`, `teamName`, `points`, `trend` siguen igual) ni la lógica de cálculo del delta en `RankingScreen._trend()`.
