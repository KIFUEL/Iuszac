# Estado del Proyecto: LawApp (Iuszac)

Este documento sirve como bitácora de progreso para asegurar la continuidad del desarrollo por cualquier colaborador o IA.

## 🟢 Completado
- **Planeación Estratégica:** Definición de objetivos, usuarios (personas) y alcance.
- **Documentación Técnica:** Creación de `DOCUMENTATION.md` con requisitos funcionales, no funcionales (responsividad), flujo de navegación y modelo de datos.
- **Estructura Base de Flutter:**
    - Inicialización de carpetas (`core`, `services`, `views`, `widgets`, etc.).
    - Configuración de `pubspec.yaml` con dependencias clave (Supabase, Riverpod, GoRouter).
    - Implementación de Layout principal responsivo (`NavigationRail`).
    - Configuración de tema profesional (Azul/Oro).
    - Esqueleto de las 4 vistas principales (Home, Foro, Mentorías, Perfil).
- **Modelos de Datos:** Creación de clases Dart completas para `Profile`, `LegalUpdate`, `ForumPost`, `ForumComment` y `Mentor` con soporte para relaciones JSON.
- **Ajustes de Responsividad:** Implementación de navegación adaptativa en [main_layout.dart](file:///home/kifuel/Documents/law_app/lib/widgets/main_layout.dart) usando `NavigationRail` (pantallas >= 800px) y `NavigationBar` de Material 3 (pantallas < 800px).
- **Flujo de Autenticación:** Creación de las vistas de [login_view.dart](file:///home/kifuel/Documents/law_app/lib/views/auth/login_view.dart) y [register_view.dart](file:///home/kifuel/Documents/law_app/lib/views/auth/register_view.dart), configuración de redirección de seguridad (Guards) con `GoRouterRefreshStream` en [router.dart](file:///home/kifuel/Documents/law_app/lib/core/router.dart) e integración interactiva en [profile_view.dart](file:///home/kifuel/Documents/law_app/lib/views/profile/profile_view.dart).
- **Servicios de Backend:** Creación de [database_service.dart](file:///home/kifuel/Documents/law_app/lib/services/database_service.dart) y [database_provider.dart](file:///home/kifuel/Documents/law_app/lib/providers/database_provider.dart) para interactuar reactivamente mediante Riverpod con las colecciones de Supabase.
- **Lógica de UI (Actualizaciones y Foro):** Conexión dinámica en tiempo real del feed de noticias en [home_view.dart](file:///home/kifuel/Documents/law_app/lib/views/home/home_view.dart) y del flujo de debates y respuestas en [forum_view.dart](file:///home/kifuel/Documents/law_app/lib/views/forum/forum_view.dart), [new_post_view.dart](file:///home/kifuel/Documents/law_app/lib/views/forum/new_post_view.dart) y [post_detail_view.dart](file:///home/kifuel/Documents/law_app/lib/views/forum/post_detail_view.dart).
- **Git Remote:** Configuración de identidad de Git, creación de claves SSH para conexión segura y primer `push` exitoso a `git@github.com:KIFUEL/Iuszac.git`.
- **Credenciales y Setup de Supabase:** Actualización exitosa de URL y Anon Key en [main.dart](file:///home/kifuel/Documents/law_app/lib/main.dart) y entrega del script SQL para la base de datos.
- **Infraestructura de Despliegue:**
    - Creación de flujo de CI/CD con GitHub Actions (`deploy.yml`) para GitHub Pages.
    - Configuración de `.gitignore`.
    - Script SQL para base de datos Supabase con RLS y Triggers (`supabase_schema.sql`).

## 🟡 En Progreso / Requiere Acción Manual
- **Modo Oscuro:** Implementado soporte adaptativo según el sistema operativo.

## 🔴 Pendiente (Backlog)
1.  **Lógica de UI:**
    - Diseño de tarjetas de mentores con enlaces externos (WhatsApp/Email) en la sección de Mentorías.
2.  **Despliegue Final:** Verificar que GitHub Actions construya y publique la app correctamente en GitHub Pages.

## 🛠️ Notas Técnicas
- **Flutter SDK:** Se intentó instalación local vía `paru`, pero hay conflictos de versiones de Dart en el sistema. Se recomienda que el usuario gestione el SDK localmente.
- **Navegación:** Se usa `go_router`. Las rutas están definidas en `lib/core/router.dart`.
- **Estado:** Se ha configurado `flutter_riverpod` para el manejo de estado global.

---
*Última actualización: 1 de Junio, 2026*
