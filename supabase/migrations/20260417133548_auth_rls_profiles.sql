-- Restricciones para Profiles

-- 1. Activamos la seguridad a nivel de fila (Row Level Security)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 2. Política de lectura (SELECT): Solo el dueño puede ver su propio perfil
CREATE POLICY "Los usuarios solo pueden ver su propio perfil"
ON public.profiles FOR SELECT
USING (auth.uid() = id);

-- 3. Política de modificación (UPDATE): Solo el dueño puede editar su nombre o avatar
CREATE POLICY "Los usuarios solo pueden actualizar su propio perfil"
ON public.profiles FOR UPDATE
USING (auth.uid() = id);