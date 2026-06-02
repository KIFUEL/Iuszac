-- ==========================================
-- SCRIPT DE INICIALIZACIÓN DE LA BASE DE DATOS
-- PROYECTO: LawApp
-- ==========================================

-- 1. Crear extensión para UUID si no está activa
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Crear Tabla de Perfiles (Extensión de auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'mentor', 'user')),
  bio TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar RLS en profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Crear Tabla de Actualizaciones Legales
CREATE TABLE public.legal_updates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Habilitar RLS en legal_updates
ALTER TABLE public.legal_updates ENABLE ROW LEVEL SECURITY;

-- 4. Crear Tabla de Posts del Foro
CREATE TABLE public.forum_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar RLS en forum_posts
ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

-- 5. Crear Tabla de Comentarios del Foro
CREATE TABLE public.forum_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.forum_posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar RLS en forum_comments
ALTER TABLE public.forum_comments ENABLE ROW LEVEL SECURITY;

-- 6. Crear Tabla de Mentores (Información de perfiles con rol mentor)
CREATE TABLE public.mentors (
  id UUID REFERENCES public.profiles(id) ON DELETE CASCADE PRIMARY KEY,
  specialty TEXT NOT NULL,
  whatsapp_number TEXT,
  email_contact TEXT,
  experience_years INT NOT NULL DEFAULT 0,
  is_verified BOOLEAN DEFAULT false NOT NULL
);

-- Habilitar RLS en mentors
ALTER TABLE public.mentors ENABLE ROW LEVEL SECURITY;

-- 7. Trigger para crear automáticamente el perfil de un usuario al registrarse en Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url, role)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Usuario'),
    new.raw_user_meta_data->>'avatar_url',
    'user'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 8. Políticas de Seguridad (RLS - Row Level Security)

-- Políticas para Profiles
CREATE POLICY "Lectura pública de perfiles" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Los usuarios pueden actualizar su propio perfil" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Políticas para Legal Updates
CREATE POLICY "Lectura pública de actualizaciones" ON public.legal_updates
  FOR SELECT USING (true);

CREATE POLICY "Solo administradores pueden crear actualizaciones" ON public.legal_updates
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Solo administradores pueden editar actualizaciones" ON public.legal_updates
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Políticas para Forum Posts
CREATE POLICY "Lectura pública de posts" ON public.forum_posts
  FOR SELECT USING (true);

CREATE POLICY "Cualquier usuario autenticado puede crear posts" ON public.forum_posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden editar sus propios posts" ON public.forum_posts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden borrar sus propios posts" ON public.forum_posts
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas para Forum Comments
CREATE POLICY "Lectura pública de comentarios" ON public.forum_comments
  FOR SELECT USING (true);

CREATE POLICY "Cualquier usuario autenticado puede crear comentarios" ON public.forum_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden editar sus propios comentarios" ON public.forum_comments
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden borrar sus propios comentarios" ON public.forum_comments
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas para Mentors
CREATE POLICY "Lectura pública de mentores" ON public.mentors
  FOR SELECT USING (true);

CREATE POLICY "Solo el mentor dueño de la cuenta puede editar su perfil de mentor" ON public.mentors
  FOR UPDATE USING (auth.uid() = id);
