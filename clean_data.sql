-- ==========================================
-- SCRIPT DE LIMPIEZA SELECTIVA (CLEAN DATA)
-- PROYECTO: Iuszac (LawApp)
-- OBJETIVO: Borrar contenido de la app PRESERVANDO los usuarios (perfiles)
-- INSTRUCCIONES: Ejecutar en el SQL Editor de Supabase
-- ==========================================

-- Desactivar temporalmente los triggers (opcional para evitar ruidos de logs)
SET session_replication_role = 'replica';

-- 1. Borrar tablas de relación y comentarios (Tercer nivel)
TRUNCATE TABLE public.mentorship_reviews CASCADE;
TRUNCATE TABLE public.mentorship_enrollments CASCADE;
TRUNCATE TABLE public.forum_comments CASCADE;
TRUNCATE TABLE public.saved_articles CASCADE;

-- 2. Borrar tablas de contenido dinámico (Segundo nivel)
TRUNCATE TABLE public.mentorship_sessions CASCADE;
TRUNCATE TABLE public.forum_posts CASCADE;
TRUNCATE TABLE public.legal_updates CASCADE;
TRUNCATE TABLE public.legal_articles CASCADE;

-- 3. Borrar tablas de estructura legal (Nivel base)
TRUNCATE TABLE public.legal_codes CASCADE;

-- IMPORTANTE: NO se toca la tabla public.profiles para no perder los logins de los usuarios.

-- Reactivar triggers
SET session_replication_role = 'origin';
