-- 1. Tabla de Perfiles (Espejo de auth.users)
-- Esta tabla contendrá la información pública de los mánagers.
CREATE TABLE public.profiles (
    -- El ID debe ser UUID para coincidir con el sistema de Auth de Supabase
    id uuid NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    -- El nombre de usuario es obligatorio y único para evitar duplicados en la liga
    username text NOT NULL UNIQUE,
    -- La URL del avatar es opcional inicialmente
    avatar_url text NULL,
    -- Marca de tiempo automática para saber cuándo se unió el usuario
    created_at timestamptz NOT NULL DEFAULT now(),

    -- Restricción de seguridad: El nombre de usuario debe tener al menos 3 caracteres
    CONSTRAINT username_length CHECK (char_length(username) >= 3)
);
