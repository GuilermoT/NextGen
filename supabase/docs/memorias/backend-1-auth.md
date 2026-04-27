# Memoria Técnica 1: Autenticación y Seguridad (RLS & Triggers)

## 1. Inicialización y Entidad de Perfiles
* Se inicializó el proyecto de Supabase en local mediante el CLI y se documentaron los comandos de despliegue en un archivo `README_BACKEND.md` independiente.
* Se definió la tabla `profiles` en el esquema `public`, conectando su clave primaria (`id`) directamente a la tabla interna `auth.users` de Supabase con una regla `ON DELETE CASCADE`.
* Por seguridad, las contraseñas e emails nunca residen en la tabla pública de perfiles, sino que son gestionadas encriptadas por el esquema `auth`.

## 2. Automatización de Registros
* Se implementó un sistema de automatización en PostgreSQL que evita la creación manual de perfiles desde el frontend.
* Se programó la función `handle_new_user()` en plpgsql (con nivel de seguridad `SECURITY DEFINER`) acoplada a un Trigger (`AFTER INSERT`) sobre la tabla `auth.users`.
* La función utiliza la instrucción `COALESCE` para extraer inteligentemente el `username`.
* Si el usuario se registra vía OAuth, extrae el nombre de `raw_user_meta_data`.
* Si el registro es mediante correo electrónico tradicional, extrae dinámicamente la cadena de texto anterior al carácter `@` mediante `split_part()`.

## 3. Blindaje de Datos (Row Level Security)
* Se generó una migración específica activando `ENABLE ROW LEVEL SECURITY` en la tabla `public.profiles`.
* Se crearon dos políticas restrictivas (`FOR SELECT` y `FOR UPDATE`) con la condición `USING (auth.uid() = id)`.
* Esto garantiza que un mánager autenticado únicamente tiene permisos de lectura y escritura sobre la fila cuyo `id` coincida con su token de sesión.