-- ==========================================
-- SCRIPT DE PERMISOS PARA MENTORÍAS
-- PROYECTO: Iuszac (LawApp)
-- OBJETIVO: Permitir a los usuarios crear, editar y borrar sus propias sesiones.
-- INSTRUCCIONES: Ejecutar en el SQL Editor de Supabase
-- ==========================================

-- 1. Habilitar la inserción de nuevas mentorías (Solo para usuarios logueados)
-- El mentor_id debe coincidir con el ID del usuario que está enviando la petición
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'mentorship_sessions' AND policyname = 'Usuarios pueden crear sus propias sesiones'
    ) THEN
        CREATE POLICY "Usuarios pueden crear sus propias sesiones" ON public.mentorship_sessions
          FOR INSERT WITH CHECK (auth.uid() = mentor_id);
    END IF;
END $$;

-- 2. Habilitar la edición de sesiones existentes (Solo el dueño puede editar)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'mentorship_sessions' AND policyname = 'Mentores pueden editar sus propias sesiones'
    ) THEN
        CREATE POLICY "Mentores pueden editar sus propias sesiones" ON public.mentorship_sessions
          FOR UPDATE USING (auth.uid() = mentor_id);
    END IF;
END $$;

-- 3. Habilitar la eliminación (Solo el dueño puede borrar)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'mentorship_sessions' AND policyname = 'Mentores pueden borrar sus propias sesiones'
    ) THEN
        CREATE POLICY "Mentores pueden borrar sus propias sesiones" ON public.mentorship_sessions
          FOR DELETE USING (auth.uid() = mentor_id);
    END IF;
END $$;

-- 4. Asegurar que el rol 'authenticated' tenga permisos de escritura en la tabla
GRANT INSERT, UPDATE, DELETE ON public.mentorship_sessions TO authenticated;

-- 5. Dar permiso para el uso de secuencias (si aplica para IDs automáticos)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
