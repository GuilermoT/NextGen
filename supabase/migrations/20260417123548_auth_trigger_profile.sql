-- Función que ejecutará Supabase en segundo plano al registrar un usuario
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, avatar_url)
  VALUES (
    new.id,
    -- Extrae el nombre de OAuth (Google/Apple) o, si es registro por email, usa lo que va antes del '@'
    COALESCE(
        new.raw_user_meta_data->>'username',
        new.raw_user_meta_data->>'full_name',
        split_part(new.email, '@', 1)
    ),
    -- Extrae la foto de perfil si el proveedor de OAuth la proporciona
    new.raw_user_meta_data->>'avatar_url'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que vigila la tabla oculta auth.users y dispara la función
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();