-- ⚖ IusZac — Migración v5.0
-- Ejecutar en Supabase SQL Editor

-- ==============================================================================
-- FASE 0.1 y 0.5: Nuevas columnas en la tabla profiles
-- ==============================================================================
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS can_mentor BOOLEAN DEFAULT false NOT NULL,
ADD COLUMN IF NOT EXISTS can_publish BOOLEAN DEFAULT false NOT NULL,
ADD COLUMN IF NOT EXISTS can_moderate BOOLEAN DEFAULT false NOT NULL,
ADD COLUMN IF NOT EXISTS can_manage_users BOOLEAN DEFAULT false NOT NULL,
ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN DEFAULT false NOT NULL,
ADD COLUMN IF NOT EXISTS suspended_until TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS suspension_reason TEXT;

-- ==============================================================================
-- FASE 0.2: Migrar datos existentes
-- ==============================================================================
UPDATE public.profiles 
SET can_mentor = true 
WHERE user_type = 'mentor';

UPDATE public.profiles 
SET can_mentor = true,
    can_publish = true,
    can_moderate = true,
    can_manage_users = true 
WHERE user_type = 'admin';

-- ==============================================================================
-- FASE 0.4: Normalizar user_type
-- ==============================================================================
UPDATE public.profiles 
SET user_type = 'user' 
WHERE user_type = 'mentor';

-- Asegurar que el user_type solo contenga 'user' o 'admin'
-- (Descomentar si es necesario, o hacerlo manualmente)
-- ALTER TABLE public.profiles ADD CONSTRAINT check_user_type_valid CHECK (user_type IN ('user', 'admin'));

-- ==============================================================================
-- FASE 0.6: Campos nuevos en legal_updates
-- ==============================================================================
ALTER TABLE public.legal_updates
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'published' NOT NULL,
ADD COLUMN IF NOT EXISTS content_type TEXT DEFAULT 'reforma' NOT NULL,
ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS source_name TEXT,
ADD COLUMN IF NOT EXISTS source_url TEXT,
ADD COLUMN IF NOT EXISTS event_start TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS event_end TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS event_location TEXT,
ADD COLUMN IF NOT EXISTS event_link TEXT,
ADD COLUMN IF NOT EXISTS deadline TEXT;

-- ==============================================================================
-- FASE 0.7: Nueva tabla legal_update_articles
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.legal_update_articles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    update_id UUID NOT NULL REFERENCES public.legal_updates(id) ON DELETE CASCADE,
    article_id UUID NOT NULL REFERENCES public.legal_articles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Evitar duplicados
ALTER TABLE public.legal_update_articles 
DROP CONSTRAINT IF EXISTS unique_update_article;

ALTER TABLE public.legal_update_articles 
ADD CONSTRAINT unique_update_article UNIQUE (update_id, article_id);

-- Habilitar RLS en la nueva tabla
ALTER TABLE public.legal_update_articles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Cualquiera puede ver articulos vinculados" ON public.legal_update_articles;
CREATE POLICY "Cualquiera puede ver articulos vinculados" ON public.legal_update_articles
FOR SELECT USING (true);

DROP POLICY IF EXISTS "Editores pueden vincular articulos" ON public.legal_update_articles;
CREATE POLICY "Editores pueden vincular articulos" ON public.legal_update_articles
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND can_publish = true
  )
);

-- ==============================================================================
-- FASE 0.8: Actualizar políticas RLS
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can insert legal updates" ON public.legal_updates;
DROP POLICY IF EXISTS "Admins can update legal updates" ON public.legal_updates;
DROP POLICY IF EXISTS "Admins can delete legal updates" ON public.legal_updates;

DROP POLICY IF EXISTS "publisher_insert_legal_updates" ON public.legal_updates;
CREATE POLICY "publisher_insert_legal_updates" ON public.legal_updates
FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND can_publish = true)
);

DROP POLICY IF EXISTS "publisher_update_legal_updates" ON public.legal_updates;
CREATE POLICY "publisher_update_legal_updates" ON public.legal_updates
FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND can_publish = true)
);

DROP POLICY IF EXISTS "moderator_delete_legal_updates" ON public.legal_updates;
CREATE POLICY "moderator_delete_legal_updates" ON public.legal_updates
FOR DELETE USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND can_moderate = true)
);

-- ==============================================================================
-- FASE 0.9: Funciones SECURITY DEFINER
-- ==============================================================================

CREATE OR REPLACE FUNCTION admin_set_permissions(
  target_id UUID, 
  new_can_mentor BOOLEAN, 
  new_can_publish BOOLEAN, 
  new_can_moderate BOOLEAN
) RETURNS void AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND can_manage_users = true) THEN
    RAISE EXCEPTION 'No tienes permisos para gestionar usuarios.';
  END IF;

  UPDATE public.profiles 
  SET can_mentor = new_can_mentor,
      can_publish = new_can_publish,
      can_moderate = new_can_moderate
  WHERE id = target_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION admin_suspend_user(target_user_id UUID, suspend_until TIMESTAMP WITH TIME ZONE, reason TEXT) RETURNS void AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND can_manage_users = true) THEN
    RAISE EXCEPTION 'Acceso denegado';
  END IF;

  UPDATE public.profiles 
  SET is_suspended = true, 
      suspended_until = suspend_until, 
      suspension_reason = reason 
  WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION admin_lift_suspension(target_user_id UUID) RETURNS void AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND can_manage_users = true) THEN
    RAISE EXCEPTION 'Acceso denegado';
  END IF;

  UPDATE public.profiles 
  SET is_suspended = false, 
      suspended_until = NULL, 
      suspension_reason = NULL 
  WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
