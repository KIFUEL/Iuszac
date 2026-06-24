-- Añadir la columna event_cost para permitir indicar si un evento es gratuito o tiene un precio
ALTER TABLE public.legal_updates
ADD COLUMN IF NOT EXISTS event_cost TEXT;
