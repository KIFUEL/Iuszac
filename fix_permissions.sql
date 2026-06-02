-- ==========================================
-- SCRIPT DE REPARACIÓN DE PERMISOS
-- PROYECTO: Iuszac (LawApp)
-- INSTRUCCIONES: Ejecutar en el SQL Editor de Supabase
-- ==========================================

-- 1. Dar acceso al esquema público a los roles de Supabase
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- 2. Dar permiso de LECTURA (SELECT) en todas las tablas a todos
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;

-- 3. Dar permiso de ESCRITURA (INSERT, UPDATE, DELETE) solo a usuarios logueados
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

-- 4. Dar permiso para el uso de secuencias (IDs automáticos)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- 5. CONFIGURACIÓN AUTOMÁTICA PARA EL FUTURO:
-- Esto asegura que las tablas nuevas que crees hereden estos permisos
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, UPDATE, DELETE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO authenticated;

-- 6. Asegurar que el rol de servicio (admin) mantenga control total
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
