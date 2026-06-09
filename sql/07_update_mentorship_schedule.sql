-- ⚖ IusZac — Migración v7.0 (Actualización de Mentorías y Corrección de RLS)
-- Ejecutar en Supabase SQL Editor para añadir soporte a horarios recurrentes y corregir RLS

-- 1. Añadir columna 'schedule' para almacenar horarios en formato JSONB (ej: {"days": ["Lunes", "Miércoles"], "startTime": "16:00", "endTime": "18:00"})
ALTER TABLE public.mentorship_sessions ADD COLUMN IF NOT EXISTS schedule JSONB;

-- 2. Hacer 'session_date' opcional, ya que ahora el horario se define mediante la columna 'schedule'
ALTER TABLE public.mentorship_sessions ALTER COLUMN session_date DROP NOT NULL;

-- 3. Corregir política RLS de inserción: usar 'can_mentor' en lugar del 'user_type' antiguo ('mentor')
-- Esto soluciona el error PostgrestException 42501 al publicar mentorías.
DROP POLICY IF EXISTS "Solo mentores pueden crear sesiones" ON public.mentorship_sessions;
CREATE POLICY "Solo mentores pueden crear sesiones" ON public.mentorship_sessions 
  FOR INSERT WITH CHECK (
    auth.uid() = mentor_id AND 
    (SELECT can_mentor FROM public.profiles WHERE id = auth.uid()) = true
  );

-- 4. Actualizar política RLS de edición: utilizar 'expires_at' en lugar de 'session_date'
DROP POLICY IF EXISTS "Mentores pueden actualizar sus propias sesiones activas" ON public.mentorship_sessions;
CREATE POLICY "Mentores pueden actualizar sus propias sesiones activas" ON public.mentorship_sessions 
  FOR UPDATE USING (
    auth.uid() = mentor_id AND 
    (expires_at IS NULL OR expires_at > NOW())
  );
