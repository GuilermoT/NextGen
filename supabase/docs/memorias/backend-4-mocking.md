# Memoria Técnica 4: Estrategia de Mocking y Optimización de Cuota API

## 1. Identificación del Problema
Durante el testeo intensivo del algoritmo de barajado y asignación de valor de mercado, se detectó un consumo acelerado (16%) del *Free Tier* de API-Football. Para garantizar la viabilidad del desarrollo a largo plazo, se hizo imperativo desvincular el entorno de desarrollo local de las llamadas HTTP reales.

## 2. Solución Arquitectónica: El "Golden JSON"
Se ha desarrollado un sistema de simulación de entorno (*Mocking*):
* **Variable de Control:** Se implementó la variable de entorno local `USE_MOCK_API`. Mediante una directiva condicional en la *Edge Function*, el servidor decide si enrutar la petición hacia internet o hacia un archivo local.
* **Estructura Estática:** Se creó el archivo `mock-data.ts` que replica exactamente la estructura de respuesta (`JSON`) de la API real, conteniendo un subconjunto de 8 jugadores de prueba que cubren todas las posiciones (Goalkeeper, Defender, Midfielder, Attacker).

## 3. Resolución de Incidencias Técnicas (`ON CONFLICT`)
* **Error Detectado:** Durante un intento de simular mayor volumen de datos duplicando el array estático local, PostgreSQL arrojó una excepción crítica: `ON CONFLICT DO UPDATE command cannot affect row a second time`.
* **Causa:** La instrucción `upsert` de Supabase procesa las filas por lotes. Al encontrar dos objetos con el mismo identificador (`id`) dentro de la misma transacción antes de hacer el *commit* a la base de datos, el motor previene la colisión por seguridad.
* **Mitigación:** Se corrigió el conjunto de datos de prueba para garantizar identificadores únicos y se estandarizó el uso del comando `supabase db reset` para limpiar el efecto "acumulación" en la base de datos local entre pruebas.