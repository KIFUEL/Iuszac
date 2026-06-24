-- ==========================================
-- SCRIPT DE MIGRACIÓN: REFACTORIZACIÓN A PUBLICATIONS
-- Ejecutar en el SQL Editor de Supabase
-- ==========================================

-- 1. Eliminar la tabla de relaciones de artículos a legal_updates
DROP TABLE IF EXISTS public.legal_update_articles;

-- 2. Eliminar la Foreign Key y la columna article_id de la tabla legal_updates
ALTER TABLE public.legal_updates DROP CONSTRAINT IF EXISTS legal_updates_article_id_fkey;
ALTER TABLE public.legal_updates DROP COLUMN IF EXISTS article_id;

-- 3. Renombrar la tabla legal_updates a publications
ALTER TABLE public.legal_updates RENAME TO publications;

-- 4. Renombrar la constraint de foreign key del autor
ALTER TABLE public.publications RENAME CONSTRAINT legal_updates_author_id_fkey TO publications_author_id_fkey;
ALTER TABLE public.publications RENAME CONSTRAINT legal_updates_pkey TO publications_pkey;

-- 5. Opcional: Renombrar los trigers / policies si existieran y su nombre estuviera anclado a legal_updates (Supabase suele manejarlos por id, pero si hay policies explícitas, tal vez haya que renombrarlas después desde la UI).
