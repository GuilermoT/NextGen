# Memoria Técnica 3: Esquema de Datos Reales y Lógica de Mercado

## 1. Integridad Referencial
* Se creó la tabla `real_players` estableciendo una relación de clave foránea (`REFERENCES`) con `real_clubs`.
* Esto garantiza la integridad referencial: ningún jugador puede existir sin un equipo asignado.
* Se documentó que el proceso de seeding debe seguir un orden jerárquico.
* Si se realiza un `db reset`, es imperativo ejecutar primero la función de equipos y posteriormente la de jugadores para evitar errores de restricción de clave foránea.

## 2. Algoritmos Avanzados y Lógica de Mercado
* Se descartó la asignación aleatoria pura para el valor de mercado para evitar inconsistencias en el juego.
* Se desarrolló un "Algoritmo de Prestigio" que establece una base superior para delanteros y medios respecto a defensas y porteros.
* El algoritmo incluye un multiplicador de x3.5 para jugadores de equipos Top (Madrid, Barça, Atleti) y un bonus del 50% para jugadores en edad "Prime" (22-29 años).
* Se implementó el algoritmo Fisher-Yates en TypeScript para realizar un barajado (Shuffle).
* Esto permite que el mercado de fichajes se pueble de forma aleatoria y equitativa desde el inicio.

## 3. Plan de Escalabilidad
* La función de ingesta gestiona la paginación de la API-Football procesando los datos por *chunks*.
* La Fase Actual (MVP) consta de una ingesta controlada de 60 jugadores (3 páginas de API) para que el equipo de UI trabaje sin riesgo de saturar la API.
* La Fase de Producción realizará un escalado masivo mediante el ajuste del parámetro `pagesToFetch` para alcanzar la totalidad de la base de datos de LaLiga (+500 jugadores).