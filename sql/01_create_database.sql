-- =========================================================================
-- 1. CREACIÓN DE LA BASE DE DATOS (01_create_database.sql)
-- PROYECTO: IusZac
-- OBJETIVO: Crear toda la estructura de tablas, extensiones y triggers.
-- =========================================================================

-- A. Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- B. Tabla de Perfiles (Extensión de auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  last_name TEXT,
  avatar_url TEXT,
  user_type TEXT NOT NULL DEFAULT 'user' CHECK (user_type IN ('user', 'mentor', 'admin')),
  label TEXT CHECK (label IN ('Estudiante', 'Docente', 'Postulante', 'Investigador', 'Practicante')),
  institution TEXT,
  semester_degree TEXT,
  bio TEXT,
  phone_whatsapp TEXT,
  is_suspended BOOLEAN NOT NULL DEFAULT false,
  suspended_until TIMESTAMP WITH TIME ZONE,
  suspension_reason TEXT,
  notif_alerts_reforma BOOLEAN DEFAULT true,
  notif_email_resumen BOOLEAN DEFAULT true,
  notif_foro BOOLEAN DEFAULT true,
  notif_mentoria BOOLEAN DEFAULT true,
  rating NUMERIC DEFAULT 0,
  review_count INT DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- C. Trigger para perfiles automáticos al registrarse en Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    full_name, 
    last_name, 
    avatar_url, 
    user_type, 
    label, 
    institution, 
    semester_degree,
    phone_whatsapp,
    is_suspended,
    notif_alerts_reforma,
    notif_email_resumen,
    notif_foro,
    notif_mentoria
  )
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Usuario'),
    new.raw_user_meta_data->>'last_name',
    new.raw_user_meta_data->>'avatar_url',
    COALESCE(new.raw_user_meta_data->>'user_type', 'user'),
    new.raw_user_meta_data->>'label',
    new.raw_user_meta_data->>'institution',
    new.raw_user_meta_data->>'semester_degree',
    new.raw_user_meta_data->>'phone_whatsapp',
    false,
    COALESCE((new.raw_user_meta_data->>'notif_alerts_reforma')::boolean, true),
    COALESCE((new.raw_user_meta_data->>'notif_email_resumen')::boolean, true),
    COALESCE((new.raw_user_meta_data->>'notif_foro')::boolean, true),
    COALESCE((new.raw_user_meta_data->>'notif_mentoria')::boolean, true)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- D. Estructura Legal (Códigos y Artículos)
CREATE TABLE IF NOT EXISTS public.legal_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  short_name TEXT,
  scope TEXT CHECK (scope IN ('federal', 'estatal')),
  description TEXT,
  status TEXT NOT NULL DEFAULT 'Vigente' CHECK (status IN ('Vigente', 'Actualizado')),
  last_reform_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.legal_articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code_id UUID REFERENCES public.legal_codes(id) ON DELETE CASCADE,
  number TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  last_reform_date TIMESTAMP WITH TIME ZONE,
  source_official TEXT,
  summary_reform TEXT,
  has_recent_reform BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- E. Marcadores (Saved Articles - Mantenida para retrocompatibilidad)
CREATE TABLE IF NOT EXISTS public.saved_articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  article_id UUID REFERENCES public.legal_articles(id) ON DELETE CASCADE,
  saved_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE (user_id, article_id)
);

-- F. Reformas y Alertas (Noticias)
CREATE TABLE IF NOT EXISTS public.legal_updates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('Reforma', 'Adición', 'Derogación', 'Corrección', 'Noticia')),
  image_url TEXT,
  published_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  article_id UUID REFERENCES public.legal_articles(id) ON DELETE CASCADE,
  old_content TEXT,
  new_content TEXT
);

-- G. Foros de Discusión
CREATE TABLE IF NOT EXISTS public.forum_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  is_urgent BOOLEAN DEFAULT false,
  tags TEXT[],
  reply_count INT DEFAULT 0,
  is_closed BOOLEAN DEFAULT false,
  closed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.forum_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.forum_posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  is_solution BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Trigger para mantener reply_count actualizado
CREATE OR REPLACE FUNCTION update_reply_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE forum_posts SET reply_count = reply_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE forum_posts SET reply_count = reply_count - 1 WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_reply_count
AFTER INSERT OR DELETE ON forum_comments
FOR EACH ROW EXECUTE FUNCTION update_reply_count();

-- H. Mentorías
CREATE TABLE IF NOT EXISTS public.mentorship_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  specialty TEXT NOT NULL,
  description TEXT NOT NULL,
  price NUMERIC DEFAULT 0,
  available_slots INT DEFAULT 10,
  session_date TIMESTAMP WITH TIME ZONE NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  rating NUMERIC DEFAULT 0,
  review_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.mentorship_enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES public.mentorship_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE (session_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.mentorship_reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES public.mentorship_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- I. Habilitar RLS en todas las tablas
ALTER TABLE public.legal_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forum_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mentorship_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mentorship_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mentorship_reviews ENABLE ROW LEVEL SECURITY;

-- J. Trigger para actualizar calificaciones automáticas
CREATE OR REPLACE FUNCTION public.update_mentorship_ratings()
RETURNS TRIGGER AS $$
DECLARE
  v_session_id UUID;
  v_mentor_id UUID;
BEGIN
  IF TG_OP = 'DELETE' THEN
    v_session_id := OLD.session_id;
  ELSE
    v_session_id := NEW.session_id;
  END IF;

  SELECT mentor_id INTO v_mentor_id FROM public.mentorship_sessions WHERE id = v_session_id;

  UPDATE public.mentorship_sessions
  SET 
    rating = COALESCE((SELECT ROUND(AVG(rating)::numeric, 1) FROM public.mentorship_reviews WHERE session_id = v_session_id), 0),
    review_count = COALESCE((SELECT COUNT(*) FROM public.mentorship_reviews WHERE session_id = v_session_id), 0)
  WHERE id = v_session_id;

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

DROP TRIGGER IF EXISTS trg_mentorship_ratings ON public.mentorship_reviews;
CREATE TRIGGER trg_mentorship_ratings
AFTER INSERT OR UPDATE OR DELETE ON public.mentorship_reviews
FOR EACH ROW EXECUTE FUNCTION public.update_mentorship_ratings();
