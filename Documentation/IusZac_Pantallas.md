**⚖  IusZac — Derecho Digital**

**Documentación de Pantallas · Versión 2.0**

*Estado real del proyecto — Junio 2026*

────────────────────────────────────────────────────────────────────────────────

**Leyenda de estado de implementación**

**✅ Implementado: **Funcionalidad completa y conectada a Supabase

**⚠️ Parcial: **UI construida pero sin lógica de backend completa

**🔲 Pendiente: **Definida en spec pero no iniciada

**Resumen Ejecutivo del Proyecto**

IusZac es una plataforma web integral para la comunidad legal de Zacatecas. Desarrollada en Flutter (Dart) con backend Supabase (PostgreSQL + Auth + RLS). Estado actual: 10 de 15 pantallas implementadas o parcialmente implementadas.

| **Módulo** | **Pantallas** | **Estado General** |
| --- | --- | --- |
| Autenticación & Onboarding | 3 pantallas | ✅ Implementado |
| Navegación & Contenido Legal | 5 pantallas | ✅ Implementado |
| Alertas de Reforma | 2 pantallas | ⚠️ Parcial |
| Foros de Discusión | 2 pantallas | ✅ Implementado |
| Mentorías | 2 pantallas | ⚠️ Parcial |
| Perfil & Ajustes | 2 pantallas | ✅ Implementado |
| Panel de Administración | 2 pantallas | ✅ Implementado |

**Stack Tecnológico**

| **Capa** | **Tecnología** | **Detalle** |
| --- | --- | --- |
| Frontend | Flutter 3.x (Dart) | Compilado para Web (HTML/Canvas) |
| Estado | flutter_riverpod | FutureProvider, Provider, AsyncNotifier |
| Enrutamiento | go_router | ShellRoute con 5 tabs principales |
| Backend | Supabase (PostgreSQL) | RLS habilitado, Auth con triggers |
| UI Fonts | Google Fonts — Outfit | Tipografía moderna, legal feel |
| Despliegue | GitHub Pages + GitHub Actions | Auto-build on push a main |
| Auth | Supabase Auth | Email/Password + Reset Password |

**Modelo de Datos (Supabase)**

| **Tabla** | **Propósito** | **Campos Clave** |
| --- | --- | --- |
| profiles | Perfil extendido del usuario | id, full_name, last_name, role, institution, semester_degree, bio, notif_* |
| legal_codes | Cuerpos normativos | id, name, status, description |
| legal_articles | Artículos de cada código | id, code_id, number, title, content, old_content, new_content |
| saved_articles | Bookmarks del usuario | id, user_id, article_id, saved_at |
| forum_posts | Hilos del foro | id, user_id, title, content, tags[], is_urgent, reply_count |
| forum_comments | Respuestas a hilos | id, post_id, user_id, content, is_solution |
| legal_updates | Alertas de reforma | id, article_id, old_content, new_content, published_at |
| mentorship_sessions | Sesiones ofrecidas | id, mentor_id, title, specialty, price, available_slots, expires_at |
| mentorship_enrollments | Inscripciones | id, session_id, user_id |
| mentorship_reviews | Calificaciones de sesiones | id, session_id, user_id, rating, comment |

**Detalle de Pantallas**

**Pantalla 01  ·  Inicio / Splash / Landing**

**Sección: Autenticación    ***Ruta: /splash    ***✅ Implementado**

Pantalla de bienvenida con logotipo (gavel), tagline de IusZac y accesos directos a Iniciar Sesión y Registrarse.

**📌 Notas de implementación: ***Usa GoRouter con redirect: si el usuario ya tiene sesión activa se redirige automáticamente a /home.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Logotipo / Ícono | Visual | Sí | Ícono gavel_rounded con color primary en fondo con gradiente navy |
| Tagline | Texto | Sí | 'Derecho al alcance de todos' |
| Botón Ingresar | Botón primario | Sí | Navega a /login |
| Botón Registrarse | Botón secundario | Sí | Navega a /register |

**Pantalla 02  ·  Registro de Usuario**

**Sección: Autenticación    ***Ruta: /register    ***✅ Implementado**

Formulario multi-campo para crear una cuenta nueva. Conectado a Supabase Auth con creación automática de perfil vía trigger de base de datos.

**📌 Notas de implementación: ***El trigger on_auth_user_created crea el registro en 'profiles' automáticamente al registrarse. Los metadatos se pasan via data: {} en el signUp.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Nombre(s) | Input texto | Sí | Min. 2 caracteres |
| Apellidos | Input texto | Sí | Min. 2 caracteres |
| Correo electrónico | Input email | Sí | Formato válido, único en sistema |
| Contraseña | Input password | Sí | Min. 6 caracteres, oculto con toggle |
| Rol | Dropdown | Sí | Estudiante / Docente / Postulante / Investigador |
| Institución | Input texto | No | Ej. UAZ Unidad Académica de Derecho |
| Semestre / Grado | Input texto | No | Ej. 5to Semestre o Licenciatura |
| Suscribir alertas | Checkbox | No | Por defecto activado — guarda en notif_alerts_reforma |
| Botón Registrarse | Botón primario | Sí | Ejecuta signUp(); muestra spinner mientras carga |
| Link a Login | Enlace | Sí | ¿Ya tienes cuenta? Inicia sesión |

**Pantalla 03  ·  Iniciar Sesión**

**Sección: Autenticación    ***Ruta: /login    ***✅ Implementado**

Formulario de login con email/contraseña. Diseño de tarjeta flotante con gradiente radial de fondo.

**📌 Notas de implementación: ***Recuperación de contraseña implementada: envía email real con resetPasswordForEmail de Supabase.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Ícono/Logo | Visual | Sí | Ícono 80px en círculo con primaryContainer + glow |
| Título IusZac | Texto | Sí | letterSpacing: 2, color primary |
| Correo electrónico | Input email | Sí | Validado con validator |
| Contraseña | Input password | Sí | Oculto; toggle visible |
| ¿Olvidaste contraseña? | Enlace | No | Envía email de recuperación real |
| Botón Ingresar | Botón gradiente | Sí | Spinner mientras autentica; muestra error si falla |
| Link a Registro | Enlace subrayado | Sí | Navega a /register |

**Pantalla 04  ·  Inicio (Home / Dashboard)**

**Sección: Contenido Legal    ***Ruta: /    ***⚠️ Parcial**

Tablero principal con saludo dinámico y buscador global. Presenta las noticias y reformas en un carrusel horizontal PageView para las 3 más recientes (con etiqueta NUEVO en rojo si tienen menos de 24 horas) y una lista vertical inferior para las demás noticias. La parte inferior tiene un carrusel horizontal de códigos disponibles.

**📌 Notas de implementación: ***El feed de noticias consume legalUpdatesProvider. Las noticias más recientes van al carrusel, y el resto se listan de forma vertical abajo. Cada entrada presenta metadatos, categoría y botón de redirección al artículo afectado o al detalle comparativo.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Saludo dinámico | SliverAppBar | Sí | Buenos días, tardes o noches más nombre del usuario |
| Badge notificaciones | Ícono con badge | No | Alerta de notificaciones pendientes |
| Buscador global | Barra de búsqueda | Sí | Navega a /search |
| Carrusel de Reformas | PageView horizontal | Sí | Las 3 noticias de reformas más recientes en páginas deslizables |
| Etiqueta NUEVO | Badge rojo | No | Etiqueta visible si la noticia tiene menos de 24 horas |
| Nombre/Categoría | Metadato | Sí | Chips con la categoría de la reforma (ej. Penal, Constitucional) |
| Fecha del cambio | Metadato | Sí | Fecha de publicación del cambio (dd/MM/yyyy) |
| Botón Ver artículo/cambios | Botón outlined/text | Sí | Redirige al detalle del artículo o comparativo |
| Sección Más Noticias | Lista vertical | No | Listado de las noticias restantes (a partir de la 4a en adelante) |
| Carrusel de Códigos | ListView horizontal | Sí | Carrusel inferior con los códigos legales y cantidad de artículos |

**Boceto de referencia (Wireframe)**

┌─────────────────────────────────────────┐
│  Buenos días  [nombre]     🔔 3          │
├─────────────────────────────────────────┤
│  🔍  Busca artículos códigos o foros    │
├─────────────────────────────────────────┤
│  Cambios Recientes                      │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  Código Penal  Art. 250          │   │
│  │  Se modifica la pena mínima de   │   │
│  │  prisión para delitos de fraude   │   │
│  │                                  │   │
│  │  03 junio 2026    [Ver artículo] │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  Constitución  Art. 14           │   │
│  │  Adición al párrafo cuarto sobre │   │
│  │  garantías procesales            │   │
│  │                                  │   │
│  │  01 junio 2026    [Ver artículo] │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Códigos Disponibles          Ver todos │
│  [CP Zac] [CPF] [Const] [C Civil]      │
└─────────────────────────────────────────┘

**Pantalla 05  ·  Catálogo de Códigos**

**Sección: Contenido Legal    ***Ruta: /codes    ***🔲 Pendiente**

Lista completa de cuerpos normativos con indicadores de estado y contador de artículos. Accesible desde 'Ver todos' en el Home.

**📌 Notas de implementación: ***La tabla legal_codes existe y tiene datos. La vista de lista aún no está creada. El provider legalCodesProvider ya está implementado y devuelve article_count.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Lista de códigos | ListView | Sí | Nombre, status badge, conteo de artículos |
| Badge de estado | Chip | Sí | Vigente (verde) / Actualizado (azul) |
| Buscador inline | Input | No | Filtro por nombre del código |
| Tap en código | Navegación | Sí | Abre Detalle de Artículos del código |

**Pantalla 06  ·  Detalle de Artículo**

**Sección: Contenido Legal    ***Ruta: /codes/:codeId/articles/:articleId    ***🔲 Pendiente**

Vista de lectura de un precepto legal con historial de reformas y acción de guardar en bookmarks.

**📌 Notas de implementación: ***El provider articleDetailProvider está implementado y consulta legal_articles JOIN legal_codes. El botón guardar debe llamar a saveArticle() del DatabaseService. La vista aún no existe.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Número y título | Encabezado | Sí | Código + Art. número: título |
| Texto del artículo | Cuerpo | Sí | Contenido completo con line-height 1.6 |
| Badge Reforma Reciente | Chip | No | Si existe registro en legal_updates |
| Botón Guardar | Ícono bookmark | Sí | Llama a saveArticle(); isArticleSavedProvider para estado |
| Fuente oficial | Metadato | No | Referencia al Periódico Oficial |

**Pantalla 15  ·  Búsqueda Global**

**Sección: Contenido Legal    ***Ruta: /search    ***🔲 Pendiente**

Interfaz de búsqueda transversal de artículos, códigos y foros. Accesible desde el Home.

**📌 Notas de implementación: ***El buscador del Home ya navega a /search. La ruta existe en go_router pero la vista de resultados está pendiente de implementar.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Input de búsqueda | Campo activo | Sí | Foco automático al entrar |
| Búsquedas recientes | Lista | No | Últimas 5; permite borrar |
| Artículos populares | Sugerencias | Sí | Top artículos consultados |
| Resultados en vivo | Lista dinámica | Sí | Desde el 2do carácter |
| Botón cancelar | Enlace | Sí | Limpia y regresa al Home |

**Pantalla 07  ·  Alertas de Reforma (Feed)**

**Sección: Alertas    ***Ruta: /alerts    ***⚠️ Parcial**

Línea de tiempo cronológica de reformas legales. Datos reales desde la tabla legal_updates consultados vía legalUpdatesProvider.

**📌 Notas de implementación: ***El provider legalUpdatesProvider está implementado. Falta: agrupación por fecha ('Hoy', 'Ayer'), badge NEW para alertas recientes y vista comparativa completa.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Timeline de reformas | ListView | Sí | Datos reales desde legal_updates |
| Tarjeta de reforma | Card | Sí | Título, código afectado, fecha, tipo de cambio |
| Badge NEW | Chip | No | Para alertas de menos de 24h (pendiente) |
| Agrupación por fecha | Encabezados | No | 'Hoy', 'Ayer', fecha específica (pendiente) |
| Tap en alerta | Navegación | Sí | Abre Detalle de Reforma comparativo |

**Pantalla 08  ·  Detalle de Reforma (Comparativo)**

**Sección: Alertas    ***Ruta: /alerts/:updateId    ***🔲 Pendiente**

Vista especializada que contrasta el texto anterior (rojo tachado) con el texto nuevo (verde resaltado) de una reforma legal.

**📌 Notas de implementación: ***La tabla legal_updates tiene campos old_content y new_content. El model LegalUpdate ya los mapea. La vista comparativa está pendiente.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Botón regresar | Navegación | Sí | Vuelve al historial de alertas |
| Identificador | Encabezado | Sí | Código + número de artículo + nombre |
| Texto anterior | Bloque rojo | Sí | Texto tachado o con fondo rojo claro |
| Texto nuevo | Bloque verde | Sí | Nuevo texto con fondo verde claro |
| Fuente oficial | Metadato | No | Referencia al Periódico Oficial o SCJN |
| Botón guardar artículo | Ícono | Sí | Guarda via saveArticle() |

**Pantalla 09  ·  Foro de Dudas (Lista de Hilos)**

**Sección: Foros    ***Ruta: /forum    ***✅ Implementado**

Lista de posts del foro con búsqueda por hashtag y filtrado en tiempo real. Banner motivacional, avatares con gradiente y FAB con gradiente.

**📌 Notas de implementación: ***forumPostsProvider consulta forum_posts JOIN profiles. Búsqueda filtra por tags[] y título simultáneamente. reply_count mostrado por tarjeta.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Banner motivacional | Container | Sí | Texto italic con primaryContainer bg |
| Buscador por hashtag | LawTextField | Sí | Filtra tags[] y título; reactivo con setState |
| Tarjeta de hilo | InkWell + Card | Sí | Author (avatar gradiente), semestre, fecha, tags, título, snippet, reply_count |
| Badge URGENTE | Chip rojo | No | is_urgent == true en forum_posts |
| Acento lateral | Borde 4px | Sí | primaryContainer en borde izquierdo de cada card |
| FAB Nueva publicación | Gradiente | Sí | LinearGradient primary→secondary con glow |
| Botón refrescar | IconButton | Sí | ref.invalidate(forumPostsProvider) |

**Pantalla 10  ·  Detalle de Hilo (Foro)**

**Sección: Foros    ***Ruta: /forum/:postId    ***✅ Implementado**

Vista completa de un hilo con la publicación original y sus respuestas. Barra de envío de comentario sticky en la parte inferior.

**📌 Notas de implementación: ***forumCommentsProvider(postId) carga comentarios en tiempo real. createComment() inserta en forum_comments. is_solution destaca la mejor respuesta.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Tarjeta del post | Container | Sí | Autor (avatar gradiente), semestre, fecha, tags pill, título, divider, contenido |
| Barra urgente | Gradiente 4px | No | Aparece si is_urgent == true (rojo→naranja) |
| Badge URGENTE | Chip | No | Visible en header del post si is_urgent |
| Tags como pills | Containers | Sí | Fondo secondaryContainer, texto '#tag' |
| Sección Respuestas | Título + borde | Sí | Borde izquierdo de acento primary |
| Estado vacío | Icono + texto | Sí | chat_bubble_outline con mensaje animado |
| Tarjeta de comentario | Container | Sí | Avatar gradiente, autor, fecha, contenido, botón Útil |
| Badge Solución Aceptada | Chip verde | No | is_solution == true en forum_comments |
| Input de respuesta | LawTextField | Sí | Sticky al fondo; mín. 1 carácter |
| Botón enviar | FAB gradiente | Sí | Spinner mientras carga; llama createComment() |

**Pantalla 16  ·  Panel de Administración (Admin Dashboard)**

**Sección: Administración    ***Ruta: /admin    ***🔲 Pendiente**

Pantalla exclusiva para usuarios con rol Administrador. Muestra un tablero con acceso rápido a las herramientas de gestión de contenido: publicar noticias/cambios legales, gestionar artículos y revisar actividad reciente de la plataforma. No aparece en la navegación principal de usuarios normales.

**📌 Notas de implementación: ***El acceso se controla verificando profile.role == Administrador al cargar la ruta. Si el rol no coincide, GoRouter redirige a /. En Supabase, las políticas RLS para INSERT en legal_updates y legal_articles solo deben permitir el rol Administrador. Se recomienda usar una ruta protegida separada fuera del ShellRoute principal.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Verificación de rol | Guard de ruta | Sí | Redirige a / si role != Administrador |
| Encabezado admin | Header destacado | Sí | Título Panel de Administración con ícono shield |
| Tarjeta Publicar Noticia | Acción rápida | Sí | Navega a /admin/new-update para crear cambio legal |
| Tarjeta Gestionar Códigos | Acción rápida | No | Navega a gestión de legal_codes y legal_articles |
| Resumen de actividad | Estadísticas | Sí | Total de noticias publicadas, foros activos, usuarios registrados |
| Lista de noticias recientes | ListView | Sí | Últimas 5 noticias publicadas con opción de editar o eliminar |
| Botón Nueva Noticia | FAB | Sí | Navega a /admin/new-update |

**Boceto de referencia (Wireframe)**

┌──────────────────────────────────────────┐
│  🛡  Panel de Administración             │
├──────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────────┐ │
│  │ 📰 Publicar  │  │ 📚 Gestionar     │ │
│  │   Noticia    │  │    Códigos       │ │
│  └──────────────┘  └──────────────────┘ │
│                                          │
│  Actividad                               │
│  Noticias: 42   Foros: 18   Usuarios: 95 │
│                                          │
│  Publicaciones Recientes                 │
│  ┌──────────────────────────────────┐    │
│  │  Art. 250 CP · 03 jun 2026  ✏ 🗑 │    │
│  │  Art. 14 Const · 01 jun 2026 ✏ 🗑│    │
│  └──────────────────────────────────┘    │
│                                    [+]   │
└──────────────────────────────────────────┘

**Pantalla 17  ·  Formulario: Nueva Noticia / Cambio Legal**

**Sección: Administración    ***Ruta: /admin/new-update    ***🔲 Pendiente**

Formulario para que el administrador publique una nueva noticia de cambio legal. El admin selecciona el artículo afectado, escribe el resumen del cambio, pega el texto anterior y el texto nuevo (para la vista comparativa) y define la fecha de publicación. Al publicar, el registro aparece en el Home (feed de noticias) y en el módulo de Alertas.

**📌 Notas de implementación: ***El INSERT a legal_updates debe incluir: article_id (FK a legal_articles), summary (resumen del cambio para el feed), old_content (texto anterior para comparativo), new_content (texto nuevo para comparativo), published_at (fecha seleccionada por el admin). La tabla legal_updates ya existe en Supabase con estos campos. RLS debe permitir INSERT solo a Administrador.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Selector de Artículo | Dropdown buscable | Sí | Lista de legal_articles con búsqueda por nombre o código |
| Resumen del cambio | TextArea | Sí | Descripción breve que aparece en el feed máx 3 líneas sin puntuación excesiva |
| Texto anterior | TextArea | No | old_content: texto original del artículo antes de la reforma |
| Texto nuevo | TextArea | No | new_content: texto del artículo después de la reforma |
| Fecha de publicación | DatePicker | Sí | published_at; por defecto hoy; permite retroactivos |
| Tipo de cambio | Dropdown | No | Reforma Adición Derogación o Corrección |
| Botón Publicar | Botón primario | Sí | INSERT en legal_updates; invalida legalUpdatesProvider; redirige a /admin |
| Botón Cancelar | Botón secundario | Sí | Regresa a /admin sin guardar |
| Vista previa | Card preview | No | Muestra cómo se verá la tarjeta en el feed antes de publicar |

**Boceto de referencia (Wireframe)**

┌──────────────────────────────────────────┐
│  ← Nueva Noticia / Cambio Legal          │
├──────────────────────────────────────────┤
│  Artículo afectado                        │
│  [ Buscar artículo...            ▼ ]     │
│                                          │
│  Resumen del cambio                      │
│  ┌──────────────────────────────────┐    │
│  │  Se modifica la pena mínima...   │    │
│  └──────────────────────────────────┘    │
│                                          │
│  Texto anterior (opcional)               │
│  ┌──────────────────────────────────┐    │
│  │  Texto original del artículo     │    │
│  └──────────────────────────────────┘    │
│                                          │
│  Texto nuevo (opcional)                  │
│  ┌──────────────────────────────────┐    │
│  │  Texto reformado del artículo    │    │
│  └──────────────────────────────────┘    │
│                                          │
│  Fecha de publicación   Tipo de cambio   │
│  [ 03/06/2026 ]        [ Reforma ▼ ]    │
│                                          │
│  Vista previa del feed                   │
│  ┌──────────────────────────────────┐    │
│  │  Código Penal  Art. 250           │    │
│  │  Se modifica la pena mínima...   │    │
│  │  03 junio 2026   [Ver artículo]  │    │
│  └──────────────────────────────────┘    │
│                                          │
│  [Cancelar]          [Publicar Cambio]   │
└──────────────────────────────────────────┘

**Pantalla 11  ·  Mentorías (Lista de Sesiones)**

**Sección: Mentorías    ***Ruta: /mentorship    ***⚠️ Parcial**

Directorio de sesiones con 3 tabs: Todas, Mías (creadas por el usuario) y Participo (sesiones inscritas). Búsqueda por título o materia.

**📌 Notas de implementación: ***mentorshipSessionsProvider y enrolledSessionsProvider conectados a Supabase. Falta: filtro por comunidad (UAZ/ZAC), badge de verificado, ordenamiento por rating.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Tabs | TabBar 3 tabs | Sí | Todas / Mías / Participo |
| Buscador | LawTextField | Sí | Filtra por title y specialty |
| Tarjeta de sesión | LawCard | Sí | Mentor avatar, título, especialidad, rating, precio, cupo, badge verificado |
| Badge Gratis | Chip verde | No | Si price == 0 |
| Badge Cupo | Chip | No | available_slots > 0 |
| Botón Inscribirme | Botón | Sí | Llama enrollInSession(); pendiente UI de confirmación |
| FAB Nueva sesión | FloatingActionButton | Sí | Navega a /mentorship/new |
| Filtro comunidad | Selector | No | UAZ / ApoyoZac — PENDIENTE implementar |

**Pantalla 12  ·  Detalle de Mentoría**

**Sección: Mentorías    ***Ruta: /mentorship/:sessionId    ***🔲 Pendiente**

Ficha extendida de una sesión: calendario, reseñas y confirmación de inscripción.

**📌 Notas de implementación: ***mentorship_reviews existe en la DB pero no hay provider ni vista implementada aún.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Encabezado | Card | Sí | Título, mentor, institución, rating |
| Descripción | Cuerpo | Sí | Objetivos y temas |
| Calendario | Lista fechas | Sí | Días y horarios de cada sesión |
| Precio | Metadato | Sí | Gratis o MXN |
| Cupo disponible | Contador | Sí | Se deshabilita si = 0 |
| Botón Inscribirme | Botón primario | Sí | enrollInSession(); deshab. si cupo = 0 |
| Lista de espera | Botón alternativo | No | Si cupo = 0, cambia a 'Lista de espera' |
| Reseñas | Lista | No | mentorship_reviews — pendiente |

**Pantalla 13  ·  Perfil de Usuario**

**Sección: Perfil    ***Ruta: /profile    ***✅ Implementado**

Vista personal con hero header de gradiente, estadísticas reales desde Supabase, lista de artículos guardados con opción de eliminar, menú de opciones y botón de editar perfil con bottom sheet.

**📌 Notas de implementación: ***profileStatsProvider hace 3 queries paralelas a saved_articles, forum_posts y mentorship_enrollments. savedArticlesProvider retorna los artículos con JOIN a legal_articles. updateProfile() persiste en Supabase.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Hero header | SliverAppBar 240px | Sí | Gradiente navy→gold; avatar con borde blanco + sombra |
| Nombre completo | Texto blanco | Sí | full_name + last_name del perfil |
| Rol e institución | Texto white70 | Sí | role · institution |
| Ícono verificado | Icon | No | Si role == Docente o Investigador |
| Bio | Texto italic | No | Máx. 2 líneas en el header; viene de profiles.bio |
| Badge Miembro Pro | Chip gradiente | No | Con ícono workspace_premium |
| Estadísticas reales | 3 Cards | Sí | Guardados, Aportes, Mentorías — conteos reales DB |
| Artículos Guardados | Lista | Sí | JOIN saved_articles → legal_articles; botón eliminar bookmark |
| Estado vacío guardados | Card | Sí | Mensaje si no hay artículos guardados |
| Botón Editar Perfil | Bottom Sheet | Sí | Edita nombre, apellidos, bio, institución, semestre; persiste en DB |
| Botón Ajustes | IconButton | Sí | Navega a /profile/settings |
| Menú de opciones | Card agrupada | Sí | Notificaciones, Editar Perfil, Privacidad, Ayuda |
| Cerrar Sesión | Botón rojo | Sí | Diálogo de confirmación + FilledButton destructivo |

**Pantalla 14  ·  Ajustes**

**Sección: Perfil    ***Ruta: /profile/settings    ***✅ Implementado**

Panel de configuración con toggles de notificaciones que leen y escriben en Supabase, cambio de contraseña real y confirmación de eliminación de cuenta.

**📌 Notas de implementación: ***Todos los toggles leen su valor inicial de profiles.notif_*. El botón Guardar Preferencias hace UPDATE en Supabase. Cambiar contraseña llama a resetPasswordForEmail().*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Toggle Alertas de Reforma | SwitchListTile | Sí | Lee/escribe notif_alerts_reforma en profiles |
| Toggle Resumen Semanal | SwitchListTile | Sí | Lee/escribe notif_email_resumen en profiles |
| Toggle Actividad Foro | SwitchListTile | Sí | Lee/escribe notif_foro en profiles |
| Toggle Recordatorios Mentoría | SwitchListTile | Sí | Lee/escribe notif_mentoria en profiles |
| Botón Guardar Preferencias | LawButton | Sí | UPDATE a Supabase; spinner mientras guarda; SnackBar confirmación |
| Cambiar Contraseña | ListTile | Sí | Envía email real de recuperación (resetPasswordForEmail) |
| Correo electrónico | ListTile | Sí | Muestra email del usuario actual (read-only) |
| Zona de Peligro | Container rojo | Sí | Botón eliminar cuenta con confirmación en 2 pasos |
| Diálogo eliminar | AlertDialog | Sí | Confirmación + FilledButton destructivo |

**Pantalla 18  ·  Listado de Artículos por Código**

**Sección: Contenido Legal    ***Ruta: /codes/:codeId    ***✅ Implementado**

Muestra todos los artículos de ley que pertenecen a un código legal específico seleccionado (ej: Código Penal). Incluye una barra de búsqueda inline para filtrar artículos por número o palabra clave y destaca artículos recientemente reformados.

**📌 Notas de implementación: ***Consume articlesByCodeProvider(codeId) que ejecuta getArticlesByCode en la base de datos de Supabase. Filtra localmente por número de artículo y título. Al presionar un artículo, navega a /article/:id.*

**Campos y elementos de interfaz**

| **Campo / Elemento** | **Tipo** | **Requerido** | **Descripción / Validación** |
| --- | --- | --- | --- |
| Título del Código | AppBar title | Sí | Nombre del código legal (ej. Código Penal del Estado de Zacatecas) |
| Buscador de artículos | Input search | Sí | Filtrado en tiempo real por número de artículo o palabras clave |
| Lista de artículos | ListView | Sí | Listado completo de artículos ordenados por número |
| Número de artículo | Badge | Sí | Badge destacado con el número del artículo (ej. Art. 250) |
| Título de artículo | Texto principal | Sí | Nombre descriptivo del artículo (ej. Falsificación de Documentos) |
| Snippet de contenido | Texto secundario | Sí | Primeras líneas del contenido legal del artículo |
| Insignia Reformado | Badge amber | No | Etiqueta visible si hasRecentReform es true |
| Chevron navegación | Ícono | Sí | Ícono de navegación que lleva al detalle del artículo |

**Flujos de Navegación**

**Flujo de Autenticación**

1. Usuario abre la app → /splash

2. Si tiene sesión activa → redirect automático a /  (Home)

3. Si no tiene cuenta → /register → signUp() → /  (Home)

4. Si ya tiene cuenta → /login → signIn() → /  (Home)

5. Recuperación de contraseña: /login → resetPasswordForEmail() → email enviado

**Flujo Principal (5 Tabs via ShellRoute)**

/  (Inicio) → /codes (pendiente) → /codes/:codeId/articles/:articleId (pendiente)

/forum → /forum/:postId → /forum/new

/alerts → /alerts/:updateId (pendiente vista comparativa)

/mentorship → /mentorship/:sessionId (pendiente) → /mentorship/new

/profile → /profile/settings

**Accesos Globales**

• Buscador global: accesible desde el ícono de lupa en el Home (/search)

• NavigationBar (mobile): visible en todas las pantallas de nivel principal

• NavigationRail (desktop ≥800px): extendido en pantallas ≥1100px con etiquetas

**Providers Riverpod Disponibles**

| **Provider** | **Tipo** | **Fuente** | **Descripción** |
| --- | --- | --- | --- |
| authServiceProvider | Provider | AuthService | Instancia del servicio de autenticación |
| authStateProvider | StreamProvider<AuthState> | Supabase Auth | Stream del estado de sesión en tiempo real |
| currentUserProvider | Provider<User?> | Supabase Auth | Usuario autenticado actual |
| userProfileProvider | FutureProvider<Profile?> | profiles | Perfil extendido del usuario actual |
| profileUpdateProvider | Provider<DatabaseService> | DatabaseService | Para llamar updateProfile() y updateNotificationPreferences() |
| legalUpdatesProvider | FutureProvider<List> | legal_updates | Alertas de reforma con JOIN a profiles |
| forumPostsProvider | FutureProvider<List> | forum_posts | Todos los hilos del foro con JOIN a profiles |
| forumCommentsProvider | FutureProvider.family<List> | forum_comments | Comentarios de un hilo específico por postId |
| mentorshipSessionsProvider | FutureProvider<List> | mentorship_sessions | Sesiones activas (no vencidas) con JOIN al mentor |
| enrolledSessionsProvider | FutureProvider<List> | mentorship_enrollments | Sesiones donde el usuario está inscrito |
| legalCodesProvider | FutureProvider<List> | legal_codes | Códigos con conteo de artículos via subquery |
| featuredArticleProvider | FutureProvider<LegalArticle?> | legal_articles | Primer artículo de la DB como destacado |
| articleDetailProvider | FutureProvider.family | legal_articles | Artículo específico por articleId con JOIN al código |
| profileStatsProvider | FutureProvider<Map> | 3 tablas | Conteo real: saved_articles, forum_posts, enrollments |
| savedArticlesProvider | FutureProvider<List> | saved_articles | Bookmarks del usuario con JOIN a legal_articles |
| isArticleSavedProvider | FutureProvider.family<bool> | saved_articles | Verifica si un artículo específico está guardado |
| mentorsProvider | FutureProvider<List> | mentors | Directorio de mentores disponibles |
| databaseServiceProvider | Provider<DatabaseService> | DatabaseService | Instancia del servicio de base de datos |

**Roadmap — Funcionalidades Pendientes**

| **#** | **Funcionalidad** | **Pantalla** | **Prioridad** |
| --- | --- | --- | --- |
| 1 | Agregar rol Administrador en tabla profiles de Supabase | 16-17 | Alta |
| 2 | Guard de ruta /admin: redirige si role != Administrador | 16 | Alta |
| 3 | Panel de Administración: dashboard con acciones rápidas y stats | 16 | Alta |
| 4 | Formulario publicar noticia/cambio legal con vista previa | 17 | Alta |
| 5 | RLS en Supabase: INSERT en legal_updates solo para Administrador | 17 | Alta |
| 6 | Rediseñar Home: feed de noticias desde legal_updates (cambio + fecha + botón ver artículo) | 04 | Alta |
| 7 | Vista Catálogo de Códigos (/codes) | 05 | Alta |
| 8 | Vista Detalle de Artículo con bookmark real | 06 | Alta |
| 9 | Búsqueda Global con resultados en tiempo real | 15 | Alta |
| 10 | Vista Detalle de Reforma comparativa (rojo/verde) | 08 | Media |
| 11 | Agrupación por fecha en Feed de Alertas | 07 | Media |
| 12 | Badge NEW para alertas de menos de 24h | 07 | Media |
| 13 | Vista Detalle de Mentoría (/mentorship/:id) | 12 | Media |
| 14 | Editar y eliminar noticias desde el panel admin | 16 | Media |
| 15 | Sistema de reseñas de mentorías | 12 | Baja |
| 16 | Filtro por comunidad en Mentorías (UAZ/ApoyoZac) | 11 | Baja |
| 17 | Badge de docente verificado en respuestas del Foro | 09 | Baja |
| 18 | Contador de notificaciones real (Supabase real-time) | 04 | Media |
| 19 | Eliminación de cuenta (endpoint Supabase) | 14 | Media |
| 20 | Modo oscuro completo con switch en Ajustes | 14 | Baja |

────────────────────────────────────────────────────────────────────────────────

*IusZac  ·  Documentación de Pantallas v2.0  ·  Zacatecas, Junio 2026*