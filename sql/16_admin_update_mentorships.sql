-- Permitir a los administradores actualizar cualquier sesión de mentoría
DROP POLICY IF EXISTS "Admins pueden actualizar cualquier sesión" ON public.mentorship_sessions;
CREATE POLICY "Admins pueden actualizar cualquier sesión" ON public.mentorship_sessions
  FOR UPDATE USING (
    (SELECT user_type FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );
