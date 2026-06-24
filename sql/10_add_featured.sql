-- Script para agregar soporte de publicaciones "Destacadas"
-- Ejecuta este script en el SQL Editor de Supabase

ALTER TABLE public.legal_updates 
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS featured_until TIMESTAMPTZ;

-- Comentario para documentar las columnas
COMMENT ON COLUMN public.legal_updates.is_featured IS 'Indica si la publicación debe aparecer en el carrusel principal';
COMMENT ON COLUMN public.legal_updates.featured_until IS 'Fecha y hora hasta la cual la publicación dejará de ser destacada automáticamente';
