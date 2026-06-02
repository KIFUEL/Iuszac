-- ==========================================
-- SCRIPT DE DATOS SEMILLA (SEED DATA)
-- PROYECTO: Iuszac (LawApp)
-- INSTRUCCIONES: Ejecutar en el SQL Editor de Supabase
-- ==========================================

-- 1. Insertar Códigos Legales
INSERT INTO public.legal_codes (id, name, status) VALUES
  ('a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab', 'Constitución Política de los Estados Unidos Mexicanos', 'Vigente'),
  ('b2c3d4e5-f6a7-4b5c-9d0e-123456789abc', 'Código Penal del Estado de Zacatecas', 'Vigente'),
  ('c3d4e5f6-a7b8-4c5d-0e1f-23456789abcd', 'Ley Federal del Trabajo', 'Actualizado')
ON CONFLICT (id) DO NOTHING;

-- 2. Insertar Artículos Legales
INSERT INTO public.legal_articles (id, code_id, number, title, content, has_recent_reform, summary_reform, last_reform_date, source_official) VALUES
  ('d4e5f6a7-b8c9-4d5e-1f2a-3456789abcde', 'a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab', 'Art. 14', 'Retroactividad, Audiencia y Legalidad', 'A ninguna ley se dará efecto retroactivo en perjuicio de persona alguna. Nadie podrá ser privado de la libertad o de sus propiedades, posesiones o derechos, sino mediante juicio seguido ante los tribunales previamente establecidos.', false, null, '2024-03-22', 'Diario Oficial de la Federación'),
  ('e5f6a7b8-c9d0-4e5f-2a3b-456789abcdef', 'a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab', 'Art. 16', 'Garantía de Legalidad', 'Nadie puede ser molestado en su persona, familia, domicilio, papeles o posesiones, sino en virtud de mandamiento escrito de la autoridad competente, que funde y motive la causa legal del procedimiento.', false, null, '2024-03-22', 'Diario Oficial de la Federación'),
  ('f6a7b8c9-d0e1-4f5a-3b4c-56789abcdef0', 'b2c3d4e5-f6a7-4b5c-9d0e-123456789abc', 'Art. 250', 'Falsificación de Documentos', 'Comete el delito de falsificación de documentos el que altere, modifique o simule un documento verdadero, de modo que pueda resultar perjuicio a alguien. La pena de prisión será de uno a cinco años y multa de cien a doscientas cuotas.', true, 'Se incrementaron las penas mínimas aplicables para prevenir delitos en medios digitales.', '2026-05-15', 'Periódico Oficial del Estado')
ON CONFLICT (id) DO NOTHING;

-- 3. Insertar Alertas de Reforma
INSERT INTO public.legal_updates (id, title, content, category, article_id, old_content, new_content, created_at) VALUES
  ('1b2c3d4e-5f6a-4b5c-9d0e-789abcdef012', 'Reforma al Artículo 250 del CPZ', 'El Congreso del Estado ha aprobado una modificación sustancial a las penas por falsificación de documentos en formatos digitales.', 'Penal', 'f6a7b8c9-d0e1-4f5a-3b4c-56789abcdef0', 'La pena será de seis meses a tres años y multa de cincuenta a cien cuotas.', 'La pena de prisión será de uno a cinco años y multa de cien a doscientas cuotas.', timezone('utc'::text, now()))
ON CONFLICT (id) DO NOTHING;
