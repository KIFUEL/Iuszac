-- ==========================================
-- SCRIPT DE DATOS SEMILLA (SEED DATA)
-- PROYECTO: Iuszac (LawApp)
-- INSTRUCCIONES: Ejecutar en el SQL Editor de Supabase
-- ==========================================

-- 1. Insertar Códigos Legales
INSERT INTO public.legal_codes (id, name, short_name, scope, description, status, last_reform_date) VALUES
  ('a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab', 'Constitución Política de los Estados Unidos Mexicanos', 'Const.', 'federal', 'Ley fundamental del Estado mexicano', 'Vigente', '2024-03-22'),
  ('b2c3d4e5-f6a7-4b5c-9d0e-123456789abc', 'Código Penal del Estado de Zacatecas', 'CPEZ', 'estatal', 'Normativa penal aplicable en el Estado de Zacatecas', 'Vigente', '2026-05-15'),
  ('c3d4e5f6-a7b8-4c5d-0e1f-23456789abcd', 'Ley Federal del Trabajo', 'LFT', 'federal', 'Regulación de las relaciones laborales y derechos obreros', 'Actualizado', '2025-10-10')
ON CONFLICT (id) DO NOTHING;

-- 2. Insertar Artículos Legales
INSERT INTO public.legal_articles (id, code_id, number, title, content, has_recent_reform, summary_reform, last_reform_date, source_official) VALUES
  ('d4e5f6a7-b8c9-4d5e-1f2a-3456789abcde', 'a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab', 'Art. 14', 'Retroactividad, Audiencia y Legalidad', 'A ninguna ley se dará efecto retroactivo en perjuicio de persona alguna. Nadie podrá ser privado de la libertad o de sus propiedades, posesiones o derechos, sino mediante juicio seguido ante los tribunales previamente establecidos.', false, null, '2024-03-22', 'Diario Oficial de la Federación'),
  ('e5f6a7b8-c9d0-4e5f-2a3b-456789abcdef', 'a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab', 'Art. 16', 'Garantía de Legalidad', 'Nadie puede ser molestado en su persona, familia, domicilio, papeles o posesiones, sino en virtud de mandamiento escrito de la autoridad competente, que funde y motive la causa legal del procedimiento.', false, null, '2024-03-22', 'Diario Oficial de la Federación'),
  ('f6a7b8c9-d0e1-4f5a-3b4c-56789abcdef0', 'b2c3d4e5-f6a7-4b5c-9d0e-123456789abc', 'Art. 250', 'Falsificación de Documentos', 'Comete el delito de falsificación de documentos el que altere, modifique o simule un documento verdadero, de modo que pueda resultar perjuicio a alguien. La pena de prisión será de uno a cinco años y multa de cien a doscientas cuotas.', true, 'Se incrementaron las penas mínimas aplicables para prevenir delitos en medios digitales.', '2026-05-15', 'Periódico Oficial del Estado')
ON CONFLICT (id) DO NOTHING;

-- 3. Insertar Alertas de Reforma (con categoría válida del enum)
INSERT INTO public.legal_updates (id, title, content, category, article_id, old_content, new_content, published_at, created_at) VALUES
  ('1b2c3d4e-5f6a-4b5c-9d0e-789abcdef012', 'Reforma al Artículo 250 del CPZ', 'El Congreso del Estado ha aprobado una modificación sustancial a las penas por falsificación de documentos en formatos digitales.', 'Reforma', 'f6a7b8c9-d0e1-4f5a-3b4c-56789abcdef0', 'La pena será de seis meses a tres años y multa de cincuenta a cien cuotas.', 'La pena de prisión será de uno a cinco años y multa de cien a doscientas cuotas.', '2026-05-15', timezone('utc'::text, now()))
ON CONFLICT (id) DO NOTHING;

-- 4. Insertar Usuarios de Prueba en auth.users (Los perfiles se crearán automáticamente por el trigger)
-- Nota: La contraseña hash es dummy, en entorno real se usa auth de Supabase.
INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES
  ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mentor1@iuszac.com', '$2a$10$dummyhash', timezone('utc'::text, now()), '{"full_name": "Dr. Juan Perez", "label": "Docente", "user_type": "mentor", "institution": "UAZ Derecho"}', timezone('utc'::text, now()), timezone('utc'::text, now())),
  ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'estudiante1@iuszac.com', '$2a$10$dummyhash', timezone('utc'::text, now()), '{"full_name": "Ana Gomez", "label": "Estudiante", "user_type": "user", "semester_degree": "5to semestre"}', timezone('utc'::text, now()), timezone('utc'::text, now()))
ON CONFLICT (id) DO NOTHING;

-- 5. Insertar Sesiones de Mentoría
INSERT INTO public.mentorship_sessions (id, mentor_id, title, specialty, description, price, available_slots, session_date, expires_at, created_at) VALUES
  ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Taller Práctico de Amparo Indirecto', 'Derecho Constitucional', 'Sesión intensiva sobre la redacción de demandas de amparo indirecto con enfoque en los juzgados locales.', 200, 5, timezone('utc'::text, now() + interval '5 days'), timezone('utc'::text, now() + interval '5 days'), timezone('utc'::text, now())),
  ('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'Introducción a la Teoría del Delito', 'Derecho Penal', 'Mentoria para estudiantes de primeros semestres sobre los elementos positivos y negativos del delito. (Sesión ya impartida).', 0, 10, timezone('utc'::text, now() - interval '2 days'), timezone('utc'::text, now() - interval '2 days'), timezone('utc'::text, now()))
ON CONFLICT (id) DO NOTHING;

-- 6. Inscribir al estudiante en ambas mentorías
INSERT INTO public.mentorship_enrollments (id, session_id, user_id, enrolled_at) VALUES
  ('55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', timezone('utc'::text, now())),
  ('66666666-6666-6666-6666-666666666666', '44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', timezone('utc'::text, now()))
ON CONFLICT (id) DO NOTHING;

-- 7. Agregar una reseña a la mentoría que ya fue impartida (para activar el trigger de promedios)
INSERT INTO public.mentorship_reviews (id, session_id, user_id, rating, comment, created_at) VALUES
  ('77777777-7777-7777-7777-777777777777', '44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 5, 'Excelente mentor, la explicación fue muy clara y los ejemplos muy didácticos.', timezone('utc'::text, now()))
ON CONFLICT (id) DO NOTHING;
