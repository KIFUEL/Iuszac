-- ==========================================
-- SCRIPT DE ACTUALIZACIÓN DE ESQUEMA V2
-- PROYECTO: Iuszac (LawApp)
-- ALINEACIÓN CON IUSZAC_PANTALLAS.DOCX
-- ==========================================

-- 1. Actualizar Tabla de Perfiles con nuevos campos
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS last_name TEXT,
ADD COLUMN IF NOT EXISTS institution TEXT,
ADD COLUMN IF NOT EXISTS semester_degree TEXT,
ADD COLUMN IF NOT EXISTS alerts_push BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS alerts_email BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS alerts_forum BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS alerts_mentorship BOOLEAN DEFAULT true;

-- 2. Crear Tabla de Códigos Legales (Ej: Código Penal, Constitución)
CREATE TABLE IF NOT EXISTS public.legal_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT, 
  status TEXT NOT NULL DEFAULT 'Vigente' CHECK (status IN ('Vigente', 'Actualizado')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar RLS en legal_codes
ALTER TABLE public.legal_codes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de códigos" ON public.legal_codes FOR SELECT USING (true);

-- 3. Crear Tabla de Artículos Legales
CREATE TABLE IF NOT EXISTS public.legal_articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code_id UUID REFERENCES public.legal_codes(id) ON DELETE CASCADE,
  number TEXT NOT NULL, -- Ej: 'Art. 250'
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  last_reform_date TIMESTAMP WITH TIME ZONE,
  source_official TEXT, -- Periódico Oficial / SCJN
  summary_reform TEXT,
  has_recent_reform BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar RLS en legal_articles
ALTER TABLE public.legal_articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de artículos" ON public.legal_articles FOR SELECT USING (true);

-- 4. Crear Tabla de Artículos Guardados (Bookmarks / Marcadores)
CREATE TABLE IF NOT EXISTS public.saved_articles (
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  article_id UUID REFERENCES public.legal_articles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (profile_id, article_id)
);

-- Habilitar RLS en saved_articles
ALTER TABLE public.saved_articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios pueden ver sus propios guardados" ON public.saved_articles FOR SELECT USING (auth.uid() = profile_id);
CREATE POLICY "Usuarios pueden guardar artículos" ON public.saved_articles FOR INSERT WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "Usuarios pueden eliminar sus guardados" ON public.saved_articles FOR DELETE USING (auth.uid() = profile_id);

-- 5. Actualizar Tabla de Reformas (Legal Updates) para Comparativo
ALTER TABLE public.legal_updates 
ADD COLUMN IF NOT EXISTS article_id UUID REFERENCES public.legal_articles(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS old_content TEXT,
ADD COLUMN IF NOT EXISTS new_content TEXT;

-- 6. Crear Tabla de Sesiones de Mentoría
CREATE TABLE IF NOT EXISTS public.mentorship_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mentor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  specialty TEXT NOT NULL,
  price NUMERIC DEFAULT 0,
  available_slots INT DEFAULT 10,
  schedule JSONB, -- Días y horas programadas
  is_community_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar RLS en mentorship_sessions
ALTER TABLE public.mentorship_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de sesiones" ON public.mentorship_sessions FOR SELECT USING (true);

-- 7. Crear Tabla de Inscripciones a Mentorías
CREATE TABLE IF NOT EXISTS public.mentorship_enrollments (
  session_id UUID REFERENCES public.mentorship_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (session_id, user_id)
);

-- Habilitar RLS en mentorship_enrollments
ALTER TABLE public.mentorship_enrollments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios pueden ver sus inscripciones" ON public.mentorship_enrollments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden inscribirse" ON public.mentorship_enrollments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 8. Crear Tabla de Reseñas de Mentoría
CREATE TABLE IF NOT EXISTS public.mentorship_reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES public.mentorship_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar RLS en mentorship_reviews
ALTER TABLE public.mentorship_reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de reseñas" ON public.mentorship_reviews FOR SELECT USING (true);
CREATE POLICY "Usuarios pueden reseñar sus sesiones inscritas" ON public.mentorship_reviews FOR INSERT WITH CHECK (
  auth.uid() = user_id AND EXISTS (
    SELECT 1 FROM public.mentorship_enrollments 
    WHERE session_id = mentorship_reviews.session_id AND user_id = auth.uid()
  )
);

-- 9. Actualización Adicional para Foros
ALTER TABLE public.forum_posts 
ADD COLUMN IF NOT EXISTS is_urgent BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS tags TEXT[]; -- Materias: #Constitucional, #Penal, etc.

ALTER TABLE public.forum_comments
ADD COLUMN IF NOT EXISTS is_solution BOOLEAN DEFAULT false;
