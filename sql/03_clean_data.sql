-- =========================================================================
-- 3. LIMPIEZA DE DATOS PRESERVANDO USUARIOS (03_clean_data.sql)
-- PROYECTO: IusZac
-- OBJETIVO: Limpiar el contenido legal, foros y mentorías de la app,
--            pero PRESERVANDO las cuentas de usuario registradas.
-- =========================================================================

-- Desactivar temporalmente los triggers para agilizar el borrado
SET session_replication_role = 'replica';

-- A. Limpieza de tablas pivote y tablas de relación (Nivel 3)
TRUNCATE TABLE public.mentorship_reviews CASCADE;
TRUNCATE TABLE public.mentorship_enrollments CASCADE;
TRUNCATE TABLE public.forum_comments CASCADE;
TRUNCATE TABLE public.saved_articles CASCADE;

-- B. Limpieza de contenido dinámico y aportaciones (Nivel 2)
TRUNCATE TABLE public.mentorship_sessions CASCADE;
TRUNCATE TABLE public.forum_posts CASCADE;
TRUNCATE TABLE public.legal_updates CASCADE;
TRUNCATE TABLE public.legal_articles CASCADE;

-- C. Limpieza de estructura legal base (Nivel 1)
TRUNCATE TABLE public.legal_codes CASCADE;

-- NOTA: NO se toca la tabla public.profiles ni auth.users para no perder registros de cuentas.

-- Reactivar triggers
SET session_replication_role = 'origin';
