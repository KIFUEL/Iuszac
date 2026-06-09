-- ⚖ IusZac — Sincronización Automática de Permisos para Administradores
-- Ejecutar en el Editor SQL de Supabase para evitar desincronización de permisos.

-- 1. Crear función que sincroniza los permisos si el tipo de usuario es 'admin'
CREATE OR REPLACE FUNCTION public.sync_admin_permissions()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_type = 'admin' THEN
    NEW.can_mentor := true;
    NEW.can_publish := true;
    NEW.can_moderate := true;
    NEW.can_manage_users := true;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Crear trigger BEFORE INSERT o UPDATE en public.profiles
DROP TRIGGER IF EXISTS trg_sync_admin_permissions ON public.profiles;
CREATE TRIGGER trg_sync_admin_permissions
  BEFORE INSERT OR UPDATE OF user_type ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_admin_permissions();

-- 3. Ejecutar una actualización única para corregir cualquier perfil desincronizado actual
UPDATE public.profiles
SET can_mentor = true,
    can_publish = true,
    can_moderate = true,
    can_manage_users = true
WHERE user_type = 'admin' 
  AND (can_mentor = false OR can_publish = false OR can_moderate = false OR can_manage_users = false);
