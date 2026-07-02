-- Add is_active column to mentorship_sessions
ALTER TABLE public.mentorship_sessions ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
