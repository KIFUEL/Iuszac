-- ==========================================
-- SCRIPT DE PUBLICACIÓN DE PRUEBA: REFORMA (ANTES Y DESPUÉS)
-- Ejecutar en el SQL Editor de Supabase
-- ==========================================

INSERT INTO public.legal_updates (
    id, 
    author_id, 
    title, 
    content, 
    category, 
    status, 
    content_type, 
    tags, 
    image_url, 
    is_featured, 
    old_content,
    new_content,
    published_at,
    created_at
) VALUES 
(
    gen_random_uuid(), 
    '11111111-1111-1111-1111-111111111111', 
    'Reforma a la Ley Federal del Trabajo: Vacaciones Dignas', 
    '[{"insert":"Se ha publicado en el Diario Oficial la reforma a la Ley Federal del Trabajo que duplica los días de vacaciones iniciales para los trabajadores del sector privado.\n"}]', 
    'Reforma', 
    'published', 
    'reforma', 
    ARRAY['laboral', 'vacaciones', 'lft'], 
    null, 
    false, 
    'Los trabajadores que tengan más de un año de servicios disfrutarán de un período anual de vacaciones pagadas, que en ningún caso podrá ser inferior a seis días laborables, y que aumentará en dos días laborables, hasta llegar a doce, por cada año subsecuente de servicios.',
    'Los personas trabajadoras que tengan más de un año de servicios disfrutarán de un periodo anual de vacaciones pagadas, que en ningún caso podrá ser inferior a doce días laborables, y que aumentará en dos días laborables, hasta llegar a veinte, por cada año subsecuente de servicios.',
    timezone('utc'::text, now()), 
    timezone('utc'::text, now())
)
ON CONFLICT (id) DO NOTHING;
