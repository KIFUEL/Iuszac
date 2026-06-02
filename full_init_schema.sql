-- ==========================================
-- SCRIPT DE INICIALIZACIÓN COMPLETA V3 (IUSZAC)
-- PROYECTO: Iuszac (LawApp)
-- ESTE SCRIPT CREA TODO DESDE CERO
-- ==========================================

-- 1. Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Tabla de Perfiles (Extensión de auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  last_name TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user',
  bio TEXT,
  institution TEXT,
  semester_degree TEXT,
  alerts_push BOOLEAN DEFAULT true,
  alerts_email BOOLEAN DEFAULT true,
  alerts_forum BOOLEAN DEFAULT true,
  alerts_mentorship BOOLEAN DEFAULT true,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar RLS en profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de perfiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Los usuarios pueden actualizar su propio perfil" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 3. Trigger para crear automáticamente el perfil al registrarse en Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, last_name, avatar_url, role, institution, semester_degree, alerts_push)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Usuario'),
    new.raw_user_meta_data->>'last_name',
    new.raw_user_meta_data->>'avatar_url',
    COALESCE(new.raw_user_meta_data->>'role', 'user'),
    new.raw_user_meta_data->>'institution',
    new.raw_user_meta_data->>'semester_degree',
    COALESCE((new.raw_user_meta_data->>'alerts_push')::boolean, true)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Códigos Legales
CREATE TABLE public.legal_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT, 
  status TEXT NOT NULL DEFAULT 'Vigente' CHECK (status IN ('Vigente', 'Actualizado')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.legal_codes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de códigos" ON public.legal_codes FOR SELECT USING (true);

-- 5. Artículos Legales
CREATE TABLE public.legal_articles (
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

ALTER TABLE public.legal_articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de artículos" ON public.legal_articles FOR SELECT USING (true);

-- 6. Artículos Guardados (Marcadores)
CREATE TABLE public.saved_articles (
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  article_id UUID REFERENCES public.legal_articles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (profile_id, article_id)
);

ALTER TABLE public.saved_articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios pueden ver sus propios guardados" ON public.saved_articles FOR SELECT USING (auth.uid() = profile_id);
CREATE POLICY "Usuarios pueden guardar artículos" ON public.saved_articles FOR INSERT WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "Usuarios pueden eliminar sus guardados" ON public.saved_articles FOR DELETE USING (auth.uid() = profile_id);

-- 7. Actualizaciones Legales (Reformas)
CREATE TABLE public.legal_updates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  article_id UUID REFERENCES public.legal_articles(id) ON DELETE CASCADE,
  old_content TEXT,
  new_content TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

ALTER TABLE public.legal_updates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de actualizaciones" ON public.legal_updates FOR SELECT USING (true);

-- 8. Foros (Publicaciones)
CREATE TABLE public.forum_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  is_urgent BOOLEAN DEFAULT false,
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de posts" ON public.forum_posts FOR SELECT USING (true);
CREATE POLICY "Cualquier usuario autenticado puede crear posts" ON public.forum_posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden editar sus propios posts" ON public.forum_posts FOR UPDATE USING (auth.uid() = user_id);

-- 9. Foros (Comentarios)
CREATE TABLE public.forum_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.forum_posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  is_solution BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.forum_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de comentarios" ON public.forum_comments FOR SELECT USING (true);
CREATE POLICY "Cualquier usuario autenticado puede crear comentarios" ON public.forum_comments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 10. Mentorías (Sesiones)
CREATE TABLE public.mentorship_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  specialty TEXT NOT NULL,
  price NUMERIC DEFAULT 0,
  available_slots INT DEFAULT 10,
  schedule JSONB,
  is_community_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.mentorship_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de sesiones" ON public.mentorship_sessions FOR SELECT USING (true);

-- 11. Mentorías (Inscripciones)
CREATE TABLE public.mentorship_enrollments (
  session_id UUID REFERENCES public.mentorship_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (session_id, user_id)
);

ALTER TABLE public.mentorship_enrollments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios pueden ver sus inscripciones" ON public.mentorship_enrollments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden inscribirse" ON public.mentorship_enrollments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 12. Mentorías (Reseñas)
CREATE TABLE public.mentorship_reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES public.mentorship_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.mentorship_reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de reseñas" ON public.mentorship_reviews FOR SELECT USING (true);
