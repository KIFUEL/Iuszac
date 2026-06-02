-- ==========================================
-- SCRIPT: AÑADIR EXPIRACIÓN A MENTORÍAS
-- PROYECTO: IusZac
-- OBJETIVO: Permitir que las sesiones caduquen automáticamente.
-- ==========================================

-- 1. Añadir la columna de fecha de expiración
ALTER TABLE public.mentorship_sessions 
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;

-- 2. (Opcional) Establecer una fecha por defecto para las existentes (Ej: 1 mes en el futuro)
UPDATE public.mentorship_sessions 
SET expires_at = created_at + INTERVAL '30 days' 
WHERE expires_at IS NULL;
