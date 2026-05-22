# Memoria Técnica 5: Flujo de Datos End-to-End (Arquitectura Sistémica)

Este documento describe la trazabilidad de los datos en NextGen, desde el registro del usuario hasta la visualización de activos reales en la interfaz.

## 1. Capa de Identidad (Auth → Profiles)
El ciclo comienza en **Supabase Auth (GoTrue)**. 
* Cuando un usuario se registra, sus credenciales se almacenan de forma segura en el esquema `auth`.
* **Automatización:** De forma inmediata, el trigger `on_auth_user_created` intercepta el evento y ejecuta la función `handle_new_user`.
* **Resultado:** Se genera automáticamente una fila espejo en `public.profiles`. El `UUID` del usuario actúa como nexo de unión, permitiendo que el sistema reconozca al mánager sin que el frontend tenga que realizar una segunda inserción manual.

## 2. Capa de Inteligencia y Datos Externos (API-Football → DB)
Para que el juego tenga contenido real, se integran datos externos mediante un proceso de *seeding* controlado:
* **Edge Functions:** Las funciones `seed-clubs` y `seed-players` actúan como puente entre la API externa y nuestra base de datos.
* **Transformación:** Los datos crudos de la API se procesan en caliente para asignar valores de mercado dinámicos y aplicar el algoritmo de barajado (*Fisher-Yates*), asegurando que cada despliegue local sea único y equilibrado.
* **Integridad:** Se establecen relaciones de clave foránea entre jugadores y clubes, garantizando que el ecosistema de datos sea coherente.

## 3. Capa de Seguridad y Acceso (RLS → Frontend)
Una vez los datos residen en `public`, entran en juego las políticas de **Row Level Security (RLS)**:
* **Datos Maestros:** Las tablas de equipos y jugadores reales tienen políticas de lectura pública para usuarios autenticados, permitiendo que la App de Flutter consulte el mercado libremente.
* **Datos Privados:** La tabla de perfiles protege la privacidad del mánager mediante la cláusula `auth.uid() = id`, permitiendo que la interfaz solo cargue la información pertinente al usuario en sesión.

## 4. Visualización Final (Visible Data)
El flujo concluye cuando el cliente (Flutter) realiza una consulta vía REST/PostgREST. Gracias a la arquitectura implementada, la App recibe un JSON listo para ser parseado, con URLs de imágenes de alta calidad (CDN de API-Football) y estructuras de datos estandarizadas, cerrando así el ciclo de vida del dato en NextGen.