-- Agregar columna para llevar el registro de cuándo fue la última vez que el usuario vio las alertas
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_read_alerts_at TIMESTAMP WITH TIME ZONE DEFAULT '2000-01-01 00:00:00+00';
