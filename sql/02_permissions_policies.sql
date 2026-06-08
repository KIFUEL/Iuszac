-- =========================================================================
-- 2. PERMISOS Y POLÍTICAS RLS (02_permissions_policies.sql)
-- PROYECTO: IusZac
-- OBJETIVO: Configurar permisos Postgres y políticas RLS definitivas.
-- =========================================================================

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

-- 1. PERFILES (profiles)
DROP POLICY IF EXISTS "Lectura pública de perfiles" ON public.profiles;
CREATE POLICY "Lectura pública de perfiles" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Usuarios pueden actualizar su propio perfil" ON public.profiles;
CREATE POLICY "Usuarios pueden actualizar su propio perfil" ON public.profiles 
  FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admins pueden actualizar cualquier perfil" ON public.profiles;
CREATE POLICY "Admins pueden actualizar cualquier perfil" ON public.profiles 
  FOR UPDATE USING (
    (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

-- 2. CONTENIDO LEGAL (codes y articles)
DROP POLICY IF EXISTS "Lectura pública de códigos" ON public.legal_codes;
CREATE POLICY "Lectura pública de códigos" ON public.legal_codes FOR SELECT USING (true);

DROP POLICY IF EXISTS "Lectura pública de artículos" ON public.legal_articles;
CREATE POLICY "Lectura pública de artículos" ON public.legal_articles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Solo admins pueden modificar códigos" ON public.legal_codes;
CREATE POLICY "Solo admins pueden modificar códigos" ON public.legal_codes 
  FOR ALL USING ((SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'admin');

DROP POLICY IF EXISTS "Solo admins pueden modificar artículos" ON public.legal_articles;
CREATE POLICY "Solo admins pueden modificar artículos" ON public.legal_articles 
  FOR ALL USING ((SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- 3. REFORMAS Y NOTICIAS (legal_updates)
DROP POLICY IF EXISTS "Lectura pública de actualizaciones" ON public.legal_updates;
CREATE POLICY "Lectura pública de actualizaciones" ON public.legal_updates FOR SELECT USING (true);

-- Permisos exclusivos para administradores en legal_updates
DROP POLICY IF EXISTS "Solo admins pueden modificar actualizaciones" ON public.legal_updates;
CREATE POLICY "Solo admins pueden modificar actualizaciones" ON public.legal_updates 
  FOR ALL USING (
    (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'admin'
  )
  WITH CHECK (
    (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

-- 4. FOROS (forum_posts y forum_comments)
DROP POLICY IF EXISTS "Lectura pública de posts" ON public.forum_posts;
CREATE POLICY "Lectura pública de posts" ON public.forum_posts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Cualquier usuario autenticado puede crear posts" ON public.forum_posts;
CREATE POLICY "Cualquier usuario autenticado puede crear posts" ON public.forum_posts 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Los usuarios pueden editar sus propios posts si no están cerrados" ON public.forum_posts;
CREATE POLICY "Los usuarios pueden editar sus propios posts si no están cerrados" ON public.forum_posts 
  FOR UPDATE USING (auth.uid() = user_id AND is_closed = false);

DROP POLICY IF EXISTS "Los usuarios o admins pueden borrar posts" ON public.forum_posts;
CREATE POLICY "Los usuarios o admins pueden borrar posts" ON public.forum_posts 
  FOR DELETE USING (auth.uid() = user_id OR (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- Comments
DROP POLICY IF EXISTS "Lectura pública de comentarios" ON public.forum_comments;
CREATE POLICY "Lectura pública de comentarios" ON public.forum_comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Cualquier usuario autenticado puede crear comentarios si el post no está cerrado" ON public.forum_comments;
CREATE POLICY "Cualquier usuario autenticado puede crear comentarios si el post no está cerrado" ON public.forum_comments 
  FOR INSERT WITH CHECK (auth.uid() = user_id AND (SELECT is_closed FROM public.forum_posts WHERE id = post_id) = false);

DROP POLICY IF EXISTS "Los usuarios pueden editar sus propios comentarios si el post no está cerrado" ON public.forum_comments;
CREATE POLICY "Los usuarios pueden editar sus propios comentarios si el post no está cerrado" ON public.forum_comments 
  FOR UPDATE USING (auth.uid() = user_id AND (SELECT is_closed FROM public.forum_posts WHERE id = post_id) = false);

DROP POLICY IF EXISTS "Los usuarios o admins pueden borrar comentarios" ON public.forum_comments;
CREATE POLICY "Los usuarios o admins pueden borrar comentarios" ON public.forum_comments 
  FOR DELETE USING (auth.uid() = user_id OR (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- 5. MENTORÍAS
DROP POLICY IF EXISTS "Lectura pública de sesiones" ON public.mentorship_sessions;
CREATE POLICY "Lectura pública de sesiones" ON public.mentorship_sessions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Solo mentores pueden crear sesiones" ON public.mentorship_sessions;
CREATE POLICY "Solo mentores pueden crear sesiones" ON public.mentorship_sessions 
  FOR INSERT WITH CHECK (
    auth.uid() = mentor_id AND 
    (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'mentor'
  );

DROP POLICY IF EXISTS "Mentores pueden actualizar sus propias sesiones activas" ON public.mentorship_sessions;
CREATE POLICY "Mentores pueden actualizar sus propias sesiones activas" ON public.mentorship_sessions 
  FOR UPDATE USING (auth.uid() = mentor_id AND session_date > NOW());

DROP POLICY IF EXISTS "Mentores o admins pueden borrar sesiones" ON public.mentorship_sessions;
CREATE POLICY "Mentores o admins pueden borrar sesiones" ON public.mentorship_sessions 
  FOR DELETE USING (auth.uid() = mentor_id OR (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- Inscripciones
DROP POLICY IF EXISTS "Lectura de inscripciones" ON public.mentorship_enrollments;
CREATE POLICY "Lectura de inscripciones" ON public.mentorship_enrollments 
  FOR SELECT USING (auth.uid() = user_id OR (SELECT mentor_id FROM public.mentorship_sessions WHERE id = session_id) = auth.uid());

DROP POLICY IF EXISTS "Usuarios pueden inscribirse" ON public.mentorship_enrollments;
CREATE POLICY "Usuarios pueden inscribirse" ON public.mentorship_enrollments 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuarios pueden desinscribirse" ON public.mentorship_enrollments;
CREATE POLICY "Usuarios pueden desinscribirse" ON public.mentorship_enrollments 
  FOR DELETE USING (auth.uid() = user_id);

-- Reseñas
DROP POLICY IF EXISTS "Lectura pública de reseñas" ON public.mentorship_reviews;
CREATE POLICY "Lectura pública de reseñas" ON public.mentorship_reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "Usuarios inscritos pueden calificar" ON public.mentorship_reviews;
CREATE POLICY "Usuarios inscritos pueden calificar" ON public.mentorship_reviews 
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND 
    EXISTS (SELECT 1 FROM public.mentorship_enrollments WHERE session_id = mentorship_reviews.session_id AND user_id = auth.uid())
  );

-- 6. MARCADORES (saved_articles - retrocompatibilidad)
DROP POLICY IF EXISTS "Usuarios pueden ver sus propios guardados" ON public.saved_articles;
CREATE POLICY "Usuarios pueden ver sus propios guardados" ON public.saved_articles FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuarios pueden guardar artículos" ON public.saved_articles;
CREATE POLICY "Usuarios pueden guardar artículos" ON public.saved_articles FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuarios pueden eliminar sus guardados" ON public.saved_articles;
CREATE POLICY "Usuarios pueden eliminar sus guardados" ON public.saved_articles FOR DELETE USING (auth.uid() = user_id);


-- C. FUNCIONES CON SECURITY DEFINER (Administración)

-- 1. Función para suspender a un usuario
CREATE OR REPLACE FUNCTION public.admin_suspend_user(
  target_user_id UUID,
  suspend_until   TIMESTAMP WITH TIME ZONE,
  reason          TEXT
)
RETURNS VOID AS $$
BEGIN
  -- Verificar que quien ejecuta la función sea admin
  IF (SELECT user_type FROM public.profiles WHERE id = auth.uid()) != 'admin' THEN
    RAISE EXCEPTION 'Solo los administradores pueden suspender usuarios.';
  END IF;

  UPDATE public.profiles SET
    is_suspended      = true,
    suspended_until   = suspend_until,
    suspension_reason = reason,
    updated_at        = NOW()
  WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Función para levantar la suspensión a un usuario
CREATE OR REPLACE FUNCTION public.admin_lift_suspension(target_user_id UUID)
RETURNS VOID AS $$
BEGIN
  -- Verificar que quien ejecuta la función sea admin
  IF (SELECT user_type FROM public.profiles WHERE id = auth.uid()) != 'admin' THEN
    RAISE EXCEPTION 'Solo los administradores pueden levantar suspensiones.';
  END IF;

  UPDATE public.profiles SET
    is_suspended      = false,
    suspended_until   = NULL,
    suspension_reason = NULL,
    updated_at        = NOW()
  WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
