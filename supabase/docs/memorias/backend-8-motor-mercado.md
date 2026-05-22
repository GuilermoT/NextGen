# Memoria Técnica 8: Motor de Mercado

## 1. Propósito
Implementación del núcleo económico del juego. Esta fase cubre todas las
operaciones de mercado: fichajes, ventas, fluctuación de precios y validación
de alineaciones. Toda la lógica crítica reside en el servidor (RPCs con
SECURITY DEFINER) para que el cliente nunca pueda manipular datos económicos
directamente.

## 2. Decisiones Arquitectónicas

### 2.1 RPCs con SECURITY DEFINER
Todas las funciones de negocio se ejecutan con los privilegios del sistema,
no del usuario. Esto significa que aunque RLS bloquee la escritura directa
sobre `user_players` y `user_teams` desde el cliente, las RPCs pueden operar
con total control. El frontend solo llama a la función; nunca toca las tablas
directamente.

### 2.2 Atomicidad de Transacciones
Tanto `buy_player` como `sell_player` ejecutan múltiples operaciones (lectura,
inserción/borrado, actualización de presupuesto) dentro de una única
transacción PostgreSQL. Si cualquier paso falla, toda la operación se revierte
automáticamente. Esto elimina estados inconsistentes como "jugador fichado
pero presupuesto no descontado".

### 2.3 CHECK `budget >= 0`
Añadido como restricción de base de datos en `user_teams`, no como validación
de aplicación. Actúa como red de seguridad final: aunque la RPC falle en su
validación previa, PostgreSQL rechazará cualquier UPDATE que deje el
presupuesto en negativo.

### 2.4 Límite de Plantilla (25 jugadores)
Validado dentro de `buy_player` antes de la inserción. Se eligió el número 25
como estándar UEFA de plantilla oficial. Este valor puede ajustarse en la RPC
sin necesidad de nueva migración.

### 2.5 Precio de Compra vs Valor de Mercado
`purchase_price` en `user_players` registra el precio pagado en el momento
del fichaje. El `market_value` en `real_players` fluctúa con el tiempo. Esta
separación permite calcular plusvalías y minusvalías en futuras pantallas de
estadísticas.

## 3. Cron Job de Fluctuación

### Configuración
- **Frecuencia:** Diaria a las 3:00 AM (`0 3 * * *`)
- **Variación:** +/- 10% aleatorio sobre el valor actual
- **Suelo mínimo:** 500.000 € para evitar jugadores sin valor de mercado

### Justificación del Horario
Las 3:00 AM minimizan el impacto sobre usuarios activos. La variación del
10% está calibrada para generar dinamismo sin provocar colapsos económicos
que arruinen la experiencia de juego.

## 4. RPC `validate_lineup`
Actúa como guardián del 11 titular. Antes de que la app guarde una
alineación, el servidor verifica que los 11 UUIDs enviados pertenecen
realmente al equipo del mánager autenticado. Devuelve `TRUE` si es válida
o lanza una excepción descriptiva indicando cuántos jugadores son inválidos.

## 5. Guía de Integración para Flutter

### Fichaje
```dart
await supabase.rpc('buy_player', params: {
  'p_team_id': teamId,
  'p_player_id': playerId,
});
```

### Venta
```dart
await supabase.rpc('sell_player', params: {
  'p_team_id': teamId,
  'p_player_id': playerId,
});
```

### Validar Alineación
```dart
await supabase.rpc('validate_lineup', params: {
  'p_team_id': teamId,
  'p_player_ids': listOf11PlayerIds,
});
```

### Importante
Capturad siempre las excepciones. Las RPCs lanzan mensajes descriptivos
que podéis mostrar directamente en la UI (presupuesto insuficiente,
plantilla completa, jugador no encontrado, etc.).