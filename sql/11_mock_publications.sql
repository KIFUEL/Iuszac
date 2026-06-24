-- ==========================================
-- SCRIPT DE PUBLICACIONES DE PRUEBA
-- Ejecutar en el SQL Editor de Supabase
-- ==========================================

-- NOTA: Asumimos que el usuario '11111111-1111-1111-1111-111111111111' existe 
-- (fue creado en seed_data.sql). Si no existe, puedes borrar la columna author_id
-- y dejar que asigne el tuyo si tienes un trigger, o cambiar el ID por el tuyo propio.

-- Eliminar la restricción de categoría para permitir Eventos y Convocatorias creados desde la UI
ALTER TABLE public.legal_updates DROP CONSTRAINT IF EXISTS legal_updates_category_check;

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
    featured_until,
    event_start,
    event_end,
    event_location,
    event_cost,
    deadline,
    published_at,
    created_at
) VALUES 
-- 1. NOTICIA DESTACADA
(
    gen_random_uuid(), 
    '11111111-1111-1111-1111-111111111111', 
    'Nueva Ley de Movilidad Sostenible en Zacatecas', 
    '[{"insert":"El Congreso del Estado ha aprobado por unanimidad la nueva Ley de Movilidad Sostenible. Esta iniciativa busca reducir las emisiones de carbono y promover el uso de bicicletas y transporte público masivo. "},{"attributes":{"bold":true},"insert":"La ley entrará en vigor a partir del próximo mes."},{"insert":"\n"}]', 
    'Noticia', 
    'published', 
    'noticia', 
    ARRAY['movilidad', 'medioambiente', 'zacatecas'], 
    'https://images.unsplash.com/photo-1518005020951-eccb494ad742?q=80&w=1000&auto=format&fit=crop', 
    true, 
    timezone('utc'::text, now() + interval '30 days'),
    null, null, null, null, null,
    timezone('utc'::text, now()), 
    timezone('utc'::text, now())
),

-- 2. NOTICIA NORMAL
(
    gen_random_uuid(), 
    '11111111-1111-1111-1111-111111111111', 
    'La SCJN resuelve amparo histórico sobre derecho al agua', 
    '[{"insert":"La Suprema Court de Justicia de la Nación emitió un fallo que sienta jurisprudencia sobre el acceso al agua potable como un derecho humano inalienable, obligando a los municipios a garantizar el suministro en zonas marginadas.\n"}]', 
    'Noticia', 
    'published', 
    'noticia', 
    ARRAY['scjn', 'derechoshumanos', 'agua'], 
    'https://images.unsplash.com/photo-1589998059171-988d887df646?q=80&w=1000&auto=format&fit=crop', 
    false, 
    null,
    null, null, null, null, null,
    timezone('utc'::text, now() - interval '1 day'), 
    timezone('utc'::text, now() - interval '1 day')
),

-- 3. EVENTO DESTACADO
(
    gen_random_uuid(), 
    '11111111-1111-1111-1111-111111111111', 
    'Congreso Internacional de Derecho Penal 2026', 
    '[{"insert":"Únete a los más grandes exponentes del derecho penal en este congreso de 3 días donde discutiremos sobre el sistema acusatorio, compliance penal y los retos de la cibercriminalidad en el siglo XXI.\n"}]', 
    'Evento', 
    'published', 
    'evento', 
    ARRAY['congreso', 'derechopenal', 'cibercrimen'], 
    'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?q=80&w=1000&auto=format&fit=crop', 
    true, 
    timezone('utc'::text, now() + interval '15 days'),
    timezone('utc'::text, now() + interval '20 days'),
    timezone('utc'::text, now() + interval '23 days'),
    'Auditorio Principal UAZ',
    '$1,500 MXN',
    null,
    timezone('utc'::text, now()), 
    timezone('utc'::text, now())
),

-- 4. CONVOCATORIA
(
    gen_random_uuid(), 
    '11111111-1111-1111-1111-111111111111', 
    'Convocatoria: Revista de Investigaciones Jurídicas', 
    '[{"insert":"La Facultad de Derecho invita a estudiantes e investigadores a enviar sus artículos para la edición de Otoño de la Revista de Investigaciones Jurídicas. Se aceptan temáticas libres enfocadas en derecho público.\n"}]', 
    'Convocatoria', 
    'published', 
    'convocatoria', 
    ARRAY['revista', 'investigacion', 'articulos'], 
    'https://images.unsplash.com/photo-1455390582262-044cdead27d8?q=80&w=1000&auto=format&fit=crop', 
    false, 
    null,
    null, null, null, null,
    timezone('utc'::text, now() + interval '10 days'), -- deadline
    timezone('utc'::text, now() - interval '2 days'), 
    timezone('utc'::text, now() - interval '2 days')
),

-- 5. REFORMA (SIN IMAGEN)
(
    gen_random_uuid(), 
    '11111111-1111-1111-1111-111111111111', 
    'Modificación al Código Fiscal de la Federación', 
    '[{"insert":"Se aprueban diversas disposiciones del Código Fiscal en materia de facturación electrónica y buzón tributario. Los contribuyentes tendrán 60 días para actualizar sus datos de contacto.\n"}]', 
    'Reforma', 
    'published', 
    'reforma', 
    ARRAY['fiscal', 'impuestos', 'sat'], 
    null, 
    false, 
    null,
    null, null, null, null, null,
    timezone('utc'::text, now() - interval '5 hours'), 
    timezone('utc'::text, now() - interval '5 hours')
)
ON CONFLICT (id) DO NOTHING;
