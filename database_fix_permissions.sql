-- ==========================================
-- 3. DATABASE_FIX_PERMISSIONS.SQL
-- PROYECTO: IusZac
-- OBJETIVO: Configurar permisos Postgres y políticas RLS definitivas.
-- ==========================================

-- A. PERMISOS DE ESQUEMA POSTGRES
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Configurar permisos por defecto para futuras tablas
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, UPDATE, DELETE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO authenticated;

-- B. POLÍTICAS RLS (Row Level Security)

-- 1. PROFILES
DROP POLICY IF EXISTS "Lectura pública de perfiles" ON public.profiles;
CREATE POLICY "Lectura pública de perfiles" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Usuarios pueden actualizar su propio perfil" ON public.profiles;
CREATE POLICY "Usuarios pueden actualizar su propio perfil" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 2. CONTENIDO LEGAL (Solo lectura para usuarios, admin vía Dashboard)
DROP POLICY IF EXISTS "Lectura pública de códigos" ON public.legal_codes;
CREATE POLICY "Lectura pública de códigos" ON public.legal_codes FOR SELECT USING (true);

DROP POLICY IF EXISTS "Lectura pública de artículos" ON public.legal_articles;
CREATE POLICY "Lectura pública de artículos" ON public.legal_articles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Lectura pública de actualizaciones" ON public.legal_updates;
CREATE POLICY "Lectura pública de actualizaciones" ON public.legal_updates FOR SELECT USING (true);

-- 3. FOROS
DROP POLICY IF EXISTS "Lectura pública de posts" ON public.forum_posts;
CREATE POLICY "Lectura pública de posts" ON public.forum_posts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Cualquier usuario autenticado puede crear posts" ON public.forum_posts;
CREATE POLICY "Cualquier usuario autenticado puede crear posts" ON public.forum_posts FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Los usuarios pueden editar sus propios posts" ON public.forum_posts;
CREATE POLICY "Los usuarios pueden editar sus propios posts" ON public.forum_posts FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Lectura pública de comentarios" ON public.forum_comments;
CREATE POLICY "Lectura pública de comentarios" ON public.forum_comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Cualquier usuario autenticado puede crear comentarios" ON public.forum_comments;
CREATE POLICY "Cualquier usuario autenticado puede crear comentarios" ON public.forum_comments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 4. MENTORÍAS
DROP POLICY IF EXISTS "Lectura pública de sesiones" ON public.mentorship_sessions;
CREATE POLICY "Lectura pública de sesiones" ON public.mentorship_sessions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Usuarios pueden crear sus propias sesiones" ON public.mentorship_sessions;
CREATE POLICY "Usuarios pueden crear sus propias sesiones" ON public.mentorship_sessions FOR INSERT WITH CHECK (auth.uid() = mentor_id);

DROP POLICY IF EXISTS "Mentores pueden editar sus propias sesiones" ON public.mentorship_sessions;
CREATE POLICY "Mentores pueden editar sus propias sesiones" ON public.mentorship_sessions FOR UPDATE USING (auth.uid() = mentor_id);

DROP POLICY IF EXISTS "Usuarios pueden ver sus inscripciones" ON public.mentorship_enrollments;
CREATE POLICY "Usuarios pueden ver sus inscripciones" ON public.mentorship_enrollments FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuarios pueden inscribirse" ON public.mentorship_enrollments;
CREATE POLICY "Usuarios pueden inscribirse" ON public.mentorship_enrollments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 5. MARCADORES
DROP POLICY IF EXISTS "Usuarios pueden ver sus propios guardados" ON public.saved_articles;
CREATE POLICY "Usuarios pueden ver sus propios guardados" ON public.saved_articles FOR SELECT USING (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Usuarios pueden guardar artículos" ON public.saved_articles;
CREATE POLICY "Usuarios pueden guardar artículos" ON public.saved_articles FOR INSERT WITH CHECK (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Usuarios pueden eliminar sus guardados" ON public.saved_articles;
CREATE POLICY "Usuarios pueden eliminar sus guardados" ON public.saved_articles FOR DELETE USING (auth.uid() = profile_id);
