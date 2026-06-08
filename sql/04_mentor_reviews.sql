-- =========================================================================
-- 4. COMENTARIOS Y CALIFICACIONES PARA MENTORES (04_mentor_reviews.sql)
-- PROYECTO: IusZac
-- INSTRUCCIONES: Ejecutar en el SQL Editor de Supabase para actualizar la BD.
-- =========================================================================

-- A. Agregar columnas de calificación y conteo en profiles y mentorship_sessions
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS rating NUMERIC DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS review_count INT DEFAULT 0;

ALTER TABLE public.mentorship_sessions ADD COLUMN IF NOT EXISTS rating NUMERIC DEFAULT 0;
ALTER TABLE public.mentorship_sessions ADD COLUMN IF NOT EXISTS review_count INT DEFAULT 0;

-- B. Función de trigger para calcular calificaciones agregadas automáticamente
CREATE OR REPLACE FUNCTION public.update_mentorship_ratings()
RETURNS TRIGGER AS $$
DECLARE
  v_session_id UUID;
  v_mentor_id UUID;
BEGIN
  -- Determinar el session_id afectado
  IF TG_OP = 'DELETE' THEN
    v_session_id := OLD.session_id;
  ELSE
    v_session_id := NEW.session_id;
  END IF;

  -- Obtener el mentor_id asociado a la sesión
  SELECT mentor_id INTO v_mentor_id FROM public.mentorship_sessions WHERE id = v_session_id;

  -- 1. Actualizar promedio y conteo de la sesión
  UPDATE public.mentorship_sessions
  SET 
    rating = COALESCE((SELECT ROUND(AVG(rating)::numeric, 1) FROM public.mentorship_reviews WHERE session_id = v_session_id), 0),
    review_count = COALESCE((SELECT COUNT(*) FROM public.mentorship_reviews WHERE session_id = v_session_id), 0)
  WHERE id = v_session_id;

  -- 2. Actualizar promedio y conteo total del mentor (en profiles)
  IF v_mentor_id IS NOT NULL THEN
    UPDATE public.profiles
    SET
      rating = COALESCE((
        SELECT ROUND(AVG(r.rating)::numeric, 1)
        FROM public.mentorship_reviews r
        JOIN public.mentorship_sessions s ON r.session_id = s.id
        WHERE s.mentor_id = v_mentor_id
      ), 0),
      review_count = COALESCE((
        SELECT COUNT(r.id)
        FROM public.mentorship_reviews r
        JOIN public.mentorship_sessions s ON r.session_id = s.id
        WHERE s.mentor_id = v_mentor_id
      ), 0)
    WHERE id = v_mentor_id;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- C. Crear trigger en mentorship_reviews
DROP TRIGGER IF EXISTS trg_mentorship_ratings ON public.mentorship_reviews;
CREATE TRIGGER trg_mentorship_ratings
AFTER INSERT OR UPDATE OR DELETE ON public.mentorship_reviews
FOR EACH ROW EXECUTE FUNCTION public.update_mentorship_ratings();
