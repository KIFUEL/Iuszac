# ⚖  IusZac — Derecho Digital

## Documentación Unificada del Proyecto · Versión 3.0
*Estado real del proyecto — Junio 2026*

---

## 1. Visión General del Proyecto
**IusZac** es una plataforma web y PWA integral diseñada para la comunidad legal del estado de Zacatecas (y de México en general). Su objetivo es democratizar el acceso a la legislación local y federal actualizada, fomentar el debate académico organizado mediante foros de discusión y facilitar la tutoría y conexión entre estudiantes, docentes y abogados postulantes mediante sesiones de mentoría.

La aplicación está completamente desarrollada en **Flutter (Dart)** para la capa de presentación y **Supabase** como backend en la nube (abarcando Base de Datos PostgreSQL, Autenticación de Usuarios y Seguridad a Nivel de Fila - RLS).

---

## 2. Stack Tecnológico e Infraestructura

| **Capa** | **Tecnología** | **Detalles y Funciones** |
| --- | --- | --- |
| **Frontend** | Flutter 3.x (Dart) | Compilado principalmente para la Web (HTML/Canvas) y optimizado para funcionar como PWA. |
| **Estado** | `flutter_riverpod` | Inyección de servicios reactivos a través de Providers, FutureProviders y StreamProviders. |
| **Enrutamiento** | `go_router` | Arquitectura de navegación fluida con subrutas dinámicas y `ShellRoute` para el Main Layout. |
| **Backend** | Supabase (PostgreSQL) | DB relacional con RLS, procedimientos y triggers de base de datos automatizados. |
| **PWA Features** | Custom JS Interop | Captura nativa de `beforeinstallprompt` para activar banners y botones de instalación web. |
| **Estilo y Fuentes**| Google Fonts - Outfit | Tipografía moderna, de lectura ágil y estética premium. |
| **Despliegue** | GitHub Pages | Pipeline automatizado de CI/CD mediante GitHub Actions (`deploy.yml`) al hacer push a `main`. |

---

## 3. Modelo de Datos (Supabase PostgreSQL)

El sistema utiliza las siguientes tablas estructuradas en el esquema público de PostgreSQL con políticas RLS activas:

*   **`profiles`**: Extensión de `auth.users`. Almacena nombre, apellidos, rol, institución, semestre, biografía y preferencias de notificaciones. Se crea automáticamente mediante un trigger de base de datos al registrar un usuario.
*   **`legal_codes`**: Cuerpos normativos del estado (ej. Constitución, Código Penal de Zacatecas, Código Civil).
*   **`legal_articles`**: Artículos individuales pertenecientes a cada código legal.
*   **`saved_articles`**: Marcadores/bookmarks creados por usuarios. *Nota: La tabla persiste en base de datos para retrocompatibilidad, pero la funcionalidad de bookmarks se removió de la interfaz gráfica en la v3.*
*   **`forum_posts`**: Hilos de discusión del foro. Contiene la columna `tags` (Array de textos) para hashtags y el flag `is_urgent`.
*   **`forum_comments`**: Comentarios y respuestas dentro de los hilos de discusión. Cuenta con el flag `is_solution` para marcar la respuesta definitiva.
*   **`legal_updates`**: Registro cronológico de reformas y noticias legales, relacionando opcionalmente un artículo para habilitar contrastes.
*   **`mentorship_sessions`**: Mentorías creadas por docentes o investigadores. Controla cupos, precios y vigencia de expiración.
*   **`mentorship_enrollments`**: Registro de usuarios inscritos en cada sesión de mentoría.
*   **`mentorship_reviews`**: Reseñas y calificaciones de las sesiones.

---

## 4. Estructura y Detalle de Pantallas (20 Vistas)

Todas las vistas de la aplicación se encuentran mapeadas, son responsivas y están conectadas a Supabase:

### 4.1. Módulo de Autenticación & Onboarding

#### **01. Inicio / Splash (Ruta: `/splash` · ✅ Implementado)**
*   Pantalla de bienvenida que muestra el logotipo de balanza (gavel), tagline de IusZac y accesos a login/registro. Redirige al Home automáticamente si la sesión está activa.

#### **02. Registro de Usuario (Ruta: `/register` · ✅ Implementado)**
*   Formulario de 12 campos: nombre, apellidos, rol (Estudiante, Docente, Investigador, etc.), institución, semestre, correo y contraseña. Llama a `signUp()` asociando metadatos de perfil.

#### **03. Iniciar Sesión (Ruta: `/login` · ✅ Implementado)**
*   Pantalla de acceso por email/contraseña. Incluye botón de recuperación de contraseña que envía correos de restablecimiento reales.

---

### 4.2. Módulo de Navegación & Contenido Legal

#### **04. Inicio / Dashboard (Ruta: `/` · ✅ Implementado)**
*   Tablero de bienvenida dinámico (saludo cambia por horario). 
*   **Buscador Global:** Acceso directo a búsquedas transversales.
*   **Banner de PWA:** Notificación inteligente y botón de instalación nativo (visible en web si es instalable y no se ha descartado).
*   **Reformas Recientes:** Carrusel dinámico horizontal para las 3 noticias más nuevas, complementado con una lista vertical inferior para el resto.
*   **Códigos Disponibles:** Carrusel horizontal inferior para navegar por códigos.

#### **05. Catálogo de Códigos (Ruta: `/codes` · ✅ Implementado)**
*   Listado completo de cuerpos normativos con su descripción, estado ("Vigente", "Actualizado") y cantidad de artículos que posee.

#### **06. Listado de Artículos por Código (Ruta: `/codes/:codeId` · ✅ Implementado)**
*   Muestra los artículos pertenecientes a un código legal específico. Cuenta con filtro por número o palabra clave y destaca visualmente los artículos recientemente reformados.

#### **07. Detalle de Artículo (Ruta: `/article/:id` · ✅ Implementado)**
*   Vista de lectura del artículo. Formatea automáticamente palabras clave de penas o sanciones en negrita para facilitar su lectura. Muestra la última fecha de reforma y la fuente oficial. *Nota: Se eliminó el botón de bookmarking por requerimiento.*

#### **08. Búsqueda Global (Ruta: `/search` · ✅ Implementado)**
*   Buscador transversal. Muestra búsquedas recientes en chips y un listado de sugerencias de artículos populares, con resultados dinámicos en vivo.

---

### 4.3. Módulo de Alertas de Reforma

#### **09. Historial de Alertas (Feed) (Ruta: `/alerts` · ✅ Implementado)**
*   Línea de tiempo cronológica de las modificaciones de ley publicadas, obtenidas de la tabla `legal_updates`.

#### **10. Detalle de Reforma Comparativo (Ruta: `/alerts/detail/:id` · ✅ Implementado)**
*   Vista que contrasta semánticamente los cambios en un artículo afectado. Muestra el texto original antes de la reforma (en rojo tachado) frente al nuevo texto vigente (en verde). *Nota: Se eliminó el botón de guardar de esta vista.*

---

### 4.4. Módulo de Foros de Discusión

#### **11. Lista de Hilos (Foro) (Ruta: `/forum` · ✅ Implementado)**
*   Organización de posts legales. Incluye barra de búsqueda reactiva por hashtags (ej. `#penal`, `#amparo`) o palabras clave, avatares con gradientes de color, borde de acento e insignia de "Urgente" cuando aplica.

#### **12. Detalle de Hilo (Ruta: `/forum/:id` · ✅ Implementado)**
*   Muestra el post completo y la lista de comentarios. Destaca los comentarios marcados como "Solución Aceptada" y ofrece un input de respuesta sticky en la parte inferior de la pantalla. El contador de respuestas se actualiza en tiempo real al agregar comentarios.

#### **13. Nueva Publicación de Foro (Ruta: `/forum/new` · ✅ Implementado)**
*   Formulario para redactar un hilo de debate, asignar hashtags y declarar si el asunto es urgente.

---

### 4.5. Módulo de Mentorías

#### **14. Directorio de Mentorías (Ruta: `/mentorship` · ✅ Implementado)**
*   Listado de mentorías segmentadas en tres pestañas: **Todas** (catálogo general), **Mías** (sesiones creadas por el docente/investigador) y **Participo** (sesiones donde el usuario se ha inscrito).
*   Filtra dinámicamente por título o área de especialidad. Las sesiones caducadas se ocultan automáticamente mediante una política de soft-delete de Supabase.

#### **15. Detalle de Mentoría (Ruta: `/mentorship/:id` · ✅ Implementado)**
*   Ficha técnica de la tutoría. Muestra temario, costo (o insignia "Gratis"), cupos restantes y calendario de fechas programadas. Ofrece un flujo directo de inscripción de un solo toque.

#### **16. Nueva Sesión de Mentoría (Ruta: `/mentorship/new` · ✅ Implementado)**
*   Formulario para que docentes e investigadores programen una mentoría fijando título, materia, costo, cupo de alumnos y fecha de expiración.

---

### 4.6. Módulo de Perfil & Preferencias

#### **17. Perfil de Usuario (Ruta: `/profile` · ✅ Implementado)**
*   Hero header con gradiente premium, avatar e iniciales.
*   **Estadísticas de Actividad:** Muestra el contador real de Aportes al Foro y Mentorías. *Nota: Se eliminó la sección de Artículos Guardados y su correspondiente contador de la UI.*
*   **Edición de Perfil:** Modal inferior desplegable para editar nombre, bio, institución y grado/semestre, guardando los cambios directamente en Supabase profiles.

#### **18. Ajustes (Ruta: `/profile/settings` · ✅ Implementado)**
*   **Preferencias de Notificación:** Switches que sincronizan en tiempo real las preferencias (Alertas de Reforma, Resumen Semanal, Actividad de Foro y Mentorías) con Supabase.
*   **Seguridad:** Enlace para enviar correos reales de recuperación y cambiar contraseña. Muestra el email actual del usuario.
*   **Zona de Peligro:** Panel rojo para solicitar la baja e iniciar la confirmación en dos pasos para eliminar permanentemente la cuenta.

---

### 4.7. Módulo de Administración

#### **19. Panel de Administración (Ruta: `/admin` · ✅ Implementado)**
*   Dashboard exclusivo para usuarios con rol `admin`. Muestra métricas reales del sistema (noticias publicadas, posts de foros, cantidad de usuarios) y un listado de las últimas actualizaciones legales con opción de eliminarlas.

#### **20. Formulario: Publicar Noticia Legal (Ruta: `/admin/new-update` · ✅ Implementado)**
*   Formulario de publication para administradores. Permite seleccionar el artículo afectado, redactar un resumen breve, pegar el texto anterior y texto reformado, y programar la fecha de publicación del cambio legal. Muestra una vista previa dinámica en tiempo real.

---

## 5. Proveedores Riverpod (`lib/providers/database_provider.dart`)

El estado dinámico de la aplicación se sustenta en los siguientes proveedores:

| **Provider** | **Tipo** | **Propósito** |
| --- | --- | --- |
| `databaseServiceProvider` | `Provider` | Instancia el servicio de interacción con Supabase. |
| `legalUpdatesProvider` | `FutureProvider` | Lista de reformas y alertas legales vigentes. |
| `forumPostsProvider` | `FutureProvider` | Hilos de discusión del foro (con perfiles de autores y comentarios). |
| `forumCommentsProvider` | `FutureProvider.family` | Respuestas de un hilo específico buscando por su `postId`. |
| `mentorsProvider` | `FutureProvider` | Directorio de mentores autorizados en el sistema. |
| `mentorshipSessionsProvider`| `FutureProvider` | Sesiones de mentoría disponibles y no caducadas. |
| `enrolledSessionsProvider` | `FutureProvider` | Sesiones de mentoría donde está inscrito el usuario. |
| `legalCodesProvider` | `FutureProvider` | Códigos con recuento de artículos via subquery. |
| `articlesByCodeProvider` | `FutureProvider.family` | Artículos de un código de ley específico por `codeId`. |
| `featuredArticleProvider` | `FutureProvider` | Obtiene el primer artículo destacado en el dashboard. |
| `articleDetailProvider` | `FutureProvider.family` | Detalle extendido de un artículo por `articleId` (con su código). |
| `profileStatsProvider` | `FutureProvider` | Estadísticas reales del perfil actual (Aportes y Mentorías). |

---

## 6. Bitácora de Progreso y Hitos Completados

### 🟢 Hitos Recientes del Proyecto (Junio 2026)
*   **Instalación PWA Dinámica:** Configurado script JS y helper Dart condicional para detectar navegadores instalables y habilitar el banner en el Home con botón de acción y descartar.
*   **Corrección en Foros:** Arreglado el contador de respuestas del foro. Modificadas las consultas PostgreSQL en el Backend para recuperar las referencias de comentarios e invalidar el provider de publicaciones al comentar, actualizando la cuenta de manera inmediata en la UI.
*   **Simplificación de UI (Marcadores):** Removido por completo el módulo de artículos guardados (Saved Articles) de las pantallas de perfil (UI y conteo), barra de detalle de artículos y botones en comparativas.
*   **Mantenimiento SQL Unificado:**
    *   `database_init.sql`: Reinicia la base de datos de Supabase desde cero.
    *   `database_clean_content.sql`: Limpia publicaciones, comentarios y mentorías de prueba preservando usuarios registrados.
    *   `database_fix_permissions.sql`: Configura correctamente políticas RLS para evitar errores de permisos.

---

## 7. Roadmap y Funcionalidades Futuras
*   **Soporte Markdown:** Añadir renderizado dinámico de Markdown en los artículos de ley para soportar tablas y viñetas complejas.
*   **Editor Enriquecido en Foro:** Permitir formato de texto (negritas, cursivas, código) al escribir un hilo o responder.
*   **Evidencias en PDF:** Permitir subir documentos PDF en mentorías y foros de discusión.
*   **Modo Oscuro Completo:** Interruptor en Ajustes para cambiar la paleta de colores global al modo oscuro.
