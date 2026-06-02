-- ==========================================
-- 2. DATABASE_CLEAN_CONTENT.SQL
-- PROYECTO: IusZac
-- OBJETIVO: Borrar contenido de la app PRESERVANDO usuarios y perfiles.
-- ==========================================

-- Desactivar temporalmente los triggers (opcional)
SET session_replication_role = 'replica';

-- 1. Borrar tablas de relación y comentarios (Nivel 3)
TRUNCATE TABLE public.mentorship_reviews CASCADE;
TRUNCATE TABLE public.mentorship_enrollments CASCADE;
TRUNCATE TABLE public.forum_comments CASCADE;
TRUNCATE TABLE public.saved_articles CASCADE;

-- 2. Borrar tablas de contenido dinámico (Nivel 2)
TRUNCATE TABLE public.mentorship_sessions CASCADE;
TRUNCATE TABLE public.forum_posts CASCADE;
TRUNCATE TABLE public.legal_updates CASCADE;
TRUNCATE TABLE public.legal_articles CASCADE;

-- 3. Borrar tablas de estructura legal (Nivel 1)
TRUNCATE TABLE public.legal_codes CASCADE;

-- NOTA: NO se toca la tabla public.profiles.

-- Reactivar triggers
SET session_replication_role = 'origin';
