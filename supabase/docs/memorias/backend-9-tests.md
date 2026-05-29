# Memoria Técnica 9: Estrategia de Testing Automatizado

## 1. Propósito
Garantizar la integridad continua del motor económico del juego mediante
tests automatizados que se ejecutan directamente contra la base de datos.
Cualquier cambio futuro en migraciones o RPCs que rompa una restricción
existente será detectado inmediatamente antes de llegar a producción.

## 2. Herramienta: pgTAP
pgTAP es la librería de testing nativa de PostgreSQL, integrada en el
CLI de Supabase mediante `supabase test db`. Permite escribir tests en
SQL puro que se ejecutan dentro de transacciones revertidas, dejando
los datos intactos tras cada ejecución.

## 3. Arquitectura de Tests

### Archivo 01: Restricciones Pasivas (`01_market_constraints_test.sql`)
Verifica que las constraints de la base de datos bloquean operaciones
maliciosas independientemente del frontend. 3 tests:

- **Test 1.1 `budget_non_negative`:** Un UPDATE que deje el saldo en
  negativo es rechazado con error PostgreSQL 23514 (CHECK violation).
- **Test 1.2 `unique_user_team`:** Un usuario no puede tener dos equipos
  simultáneamente. Rechazado con error 23505 (UNIQUE violation).
- **Test 1.3 `unique_player_ownership`:** El mismo jugador no puede
  pertenecer a dos equipos. Rechazado con error 23505 (UNIQUE violation).

### Archivo 02: Lógica Activa (`02_market_rpcs_test.sql`)
Verifica el comportamiento de las RPCs del motor de mercado simulando
una sesión de usuario real mediante `set_config('request.jwt.claims')`
para que `auth.uid()` resuelva correctamente. 7 tests:

- **Test 2.1A:** Compra exitosa — jugador insertado en `user_players`
  y budget descontado exactamente.
- **Test 2.1B:** Compra bloqueada por presupuesto insuficiente.
- **Test 2.2A:** Venta exitosa — jugador eliminado de `user_players`.
- **Test 2.2B:** Jugador eliminado correctamente tras la venta.
- **Test 2.3B:** Alineación con menos de 11 jugadores bloqueada.

## 4. Decisión Técnica: Simulación de Auth
Las RPCs usan `auth.uid()` para verificar la propiedad del equipo. En
el entorno de test no existe sesión JWT real, por lo que se inyecta el
UID del usuario de prueba mediante:

```sql
SELECT set_config(
  'request.jwt.claims',
  '{"sub": "UUID_DEL_USUARIO"}',
  true
);
```

Esto replica exactamente el mecanismo interno que usa Supabase para
resolver `auth.uid()` en producción.

## 5. Prevención de Regresiones
Cada vez que se ejecute `supabase test db`, los 10 tests validan
simultáneamente que:
- Las constraints económicas siguen activas
- Las RPCs de compra y venta operan atómicamente
- La validación de alineaciones rechaza datos incorrectos

Si una migración futura modifica accidentalmente alguna restricción,
la suite completa falla antes de que el error llegue al frontend.