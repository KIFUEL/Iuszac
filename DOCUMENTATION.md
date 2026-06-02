# Documentación del Proyecto: LawApp (Flutter + Supabase)

## 1. Visión General
**LawApp** es una plataforma web diseñada para centralizar la actualización legal, el debate jurídico y el acceso a mentorías profesionales. El objetivo es proporcionar una herramienta moderna y eficiente tanto para estudiantes de derecho como para abogados en ejercicio.

---

## 2. Personas de Usuario (User Personas)

### A. El Estudiante / Pasante
*   **Necesidad:** Encontrar actualizaciones de leyes rápidamente para sus estudios y plantear dudas sobre casos prácticos en el foro.
*   **Uso principal:** Sección de Actualizaciones y Foro.

### B. El Abogado Mentor
*   **Necesidad:** Compartir su experiencia, construir marca personal y conectar con potenciales colaboradores o alumnos.
*   **Uso principal:** Perfil de Mentoría y publicación de artículos en Actualizaciones.

### C. El Abogado General
*   **Necesidad:** Mantenerse al día con reformas legales y discutir estrategias jurídicas con colegas en un entorno profesional.
*   **Uso principal:** Foro y Actualizaciones.

---

## 3. Especificaciones de Funcionalidades (Features)

### 3.1. Módulo de Actualizaciones Legales
*   **Feed de Noticias:** Lista cronológica de reformas, artículos y noticias.
*   **Categorización:** Filtrado por rama del derecho (Civil, Penal, Laboral, etc.).
*   **Detalle:** Vista completa del artículo con formato enriquecido (Markdown/HTML).

### 3.2. Módulo de Foro
*   **Hilos de Discusión:** Capacidad de crear posts con título y descripción.
*   **Interacción:** Comentarios en tiempo real y sistema de "votos" o "likes" (opcional).
*   **Buscador:** Búsqueda por palabras clave en los títulos de los posts.

### 3.3. Módulo de Mentorías
*   **Directorio:** Tarjetas de perfil con foto, especialidad y años de experiencia.
*   **Contacto:** Botones directos a WhatsApp, Email o enlace de agendamiento (Calendly).
*   **Validación:** Distintivo de "Mentor Verificado".

### 3.4. Perfil de Usuario
*   **Gestión de Datos:** Nombre, foto, biografía y rol.
*   **Historial:** Lista de posts creados por el usuario en el foro.

---

## 4. Requerimientos No Funcionales (NFRs)

### 4.1. Seguridad y Privacidad
*   **Protección de Datos:** Toda la comunicación debe ser vía HTTPS.
*   **Control de Acceso (RLS):** Las políticas de seguridad de nivel de fila en Supabase deben garantizar que un usuario solo pueda editar su propio contenido (posts, perfil).
*   **Autenticación Robusta:** Uso de Supabase Auth para manejo seguro de contraseñas y sesiones.

### 4.2. Rendimiento y Disponibilidad
*   **Tiempo de Carga:** La aplicación debe cargar la estructura básica en menos de 2 segundos en conexiones estándar.
*   **Optimización de Imágenes:** Las fotos de perfil y documentos deben ser optimizados/comprimidos antes de subirse a Supabase Storage.
*   **Disponibilidad:** Aprovechar la infraestructura de Supabase (AWS/GCP) para asegurar un uptime del 99.9%.

### 4.3. Escalabilidad y Mantenibilidad
*   **Código Limpio:** Uso de arquitectura de capas en Flutter (Services, Models, Providers) para facilitar la adición de nuevas funciones.
*   **Documentación de Código:** Comentarios en funciones críticas y uso de nombres de variables semánticos.
*   **Escalabilidad de DB:** Diseño de tablas normalizado para permitir el crecimiento de la base de usuarios sin degradación de rendimiento.

### 4.4. Usabilidad (UX/UI) y Responsividad Detallada
*   **Adaptabilidad de Navegación:** 
    *   **Desktop/Tablet (> 800px):** Uso de `NavigationRail` lateral para maximizar el espacio de lectura horizontal.
    *   **Mobile (< 800px):** Transición automática a `BottomNavigationBar` para facilitar el uso con una sola mano.
*   **Layouts Fluidos:**
    *   **Grillas Adaptativas:** Las secciones de "Actualizaciones" y "Mentorías" usarán un `SliverGrid` que cambie de 3 columnas (Desktop) a 1 columna (Mobile).
    *   **Contenedores Max-Width:** En pantallas muy anchas, el contenido central tendrá un ancho máximo (ej. 1200px) para evitar líneas de texto demasiado largas que dificulten la lectura legal.
*   **Tipografía Escala:** Uso de tamaños de fuente relativos para asegurar que los documentos legales sean legibles sin necesidad de hacer zoom.
*   **Feedback Táctil:** Botones y elementos interactivos con áreas de toque mínimas de 48x48dp para usuarios móviles.

---

## 5. Flujo de Navegación (User Journey)

### 5.1. Estado de Autenticación
*   **Usuario no autenticado:** Es redirigido automáticamente a la pantalla de **Login**. Tiene opción de ir a **Registro**.
*   **Usuario autenticado:** Accede directamente al **Dashboard (Actualizaciones)**.

### 5.2. Navegación Principal (Nivel 0)
El usuario siempre tiene acceso a las 4 secciones principales mediante el menú lateral/inferior:
1.  **Actualizaciones** (`/`)
2.  **Foro** (`/forum`)
3.  **Mentorías** (`/mentorship`)
4.  **Perfil** (`/profile`)

### 5.3. Flujos Específicos (Nivel 1 y 2)

#### A. Flujo de Actualización Legal:
1.  `Actualizaciones (Lista)` -> Clic en una noticia -> `Detalle de Noticia` (`/updates/:id`).
2.  `Detalle de Noticia` -> Botón "Volver" -> `Actualizaciones (Lista)`.

#### B. Flujo de Participación en Foro:
1.  `Foro (Lista)` -> Botón "+" -> `Crear Post` (`/forum/new`).
2.  `Foro (Lista)` -> Clic en un post -> `Hilo de Discusión` (`/forum/:id`).
3.  `Hilo de Discusión` -> Caja de texto -> `Publicar Comentario` (Acción).

#### C. Flujo de Contacto con Mentor:
1.  `Mentorías (Lista)` -> Clic en Tarjeta de Mentor -> `Perfil de Mentor` (`/mentorship/:id`).
2.  `Perfil de Mentor` -> Clic en "Contactar por WhatsApp" -> Abre aplicación externa.
3.  `Perfil de Mentor` -> Clic en "Enviar Email" -> Abre cliente de correo.

#### D. Flujo de Perfil:
1.  `Perfil` -> Botón "Editar" -> `Formulario de Edición` (Modal o pantalla `/profile/edit`).
2.  `Perfil` -> Botón "Cerrar Sesión" -> Redirección a `Login`.

---

## 6. Modelo de Datos (Base de Datos Supabase)

Utilizaremos PostgreSQL en Supabase. A continuación, el detalle de las tablas y sus relaciones.

### 6.1. Tabla: `profiles`
Extensión de la tabla `auth.users` para guardar información pública del usuario.
*   `id`: `uuid` (Primary Key, Foreign Key a `auth.users`)
*   `full_name`: `text` (Nombre completo)
*   `avatar_url`: `text` (Enlace a la imagen en Storage)
*   `role`: `text` (Enum: 'admin', 'mentor', 'user')
*   `bio`: `text` (Breve descripción profesional)
*   `updated_at`: `timestamp with time zone`

### 6.2. Tabla: `legal_updates`
*   `id`: `uuid` (Primary Key, default: `gen_random_uuid()`)
*   `title`: `text` (Título de la reforma o noticia)
*   `content`: `text` (Cuerpo de la noticia en Markdown)
*   `category`: `text` (Ej: 'Penal', 'Civil', 'Constitucional')
*   `image_url`: `text` (Imagen destacada)
*   `created_at`: `timestamp with time zone` (default: `now()`)
*   `author_id`: `uuid` (Foreign Key a `profiles.id`)

### 6.3. Tabla: `forum_posts`
*   `id`: `uuid` (Primary Key)
*   `title`: `text`
*   `content`: `text`
*   `user_id`: `uuid` (Foreign Key a `profiles.id`)
*   `created_at`: `timestamp with time zone`

### 6.4. Tabla: `forum_comments`
*   `id`: `uuid` (Primary Key)
*   `post_id`: `uuid` (Foreign Key a `forum_posts.id`, cascade delete)
*   `user_id`: `uuid` (Foreign Key a `profiles.id`)
*   `content`: `text`
*   `created_at`: `timestamp with time zone`

### 6.5. Tabla: `mentors`
Información extendida solo para usuarios con rol de mentor.
*   `id`: `uuid` (Primary Key, Foreign Key a `profiles.id`)
*   `specialty`: `text` (Ej: 'Derecho Corporativo')
*   `whatsapp_number`: `text`
*   `email_contact`: `text`
*   `experience_years`: `int`
*   `is_verified`: `boolean` (default: `false`)

---

## 7. Políticas de Seguridad (RLS)

*   **Lectura Pública:** Todas las tablas serán legibles por usuarios autenticados.
*   **Escritura Restringida:**
    *   `legal_updates`: Solo usuarios con rol 'admin'.
    *   `forum_posts` / `comments`: El usuario solo puede editar/borrar si `user_id == auth.uid()`.
    *   `profiles`: El usuario solo puede editar su propio perfil (`id == auth.uid()`).

---

## 8. Requerimientos Técnicos

### Frontend (Flutter Web)
*   **Navegación:** `go_router` para URLs limpias (ej: `/forum/post/123`).
*   **Estado:** `Riverpod` para una gestión reactiva y desacoplada.
*   **Diseño:** Adaptativo (Desktop first, pero funcional en móviles).

### Backend (Supabase)
*   **Auth:** Manejo de sesiones persistentes.
*   **DB:** PostgreSQL con relaciones íntegras.
*   **Storage:** Almacenamiento de fotos de perfil y documentos legales.
*   **Realtime:** Actualización instantánea de nuevos mensajes en el foro.

---

## 9. Estrategia de Despliegue (GitHub Pages)

### 9.1. Flujo de Trabajo
1.  **Repositorio:** El código se alojará en un repositorio de GitHub.
2.  **Automatización (CI/CD):** Usaremos **GitHub Actions**. Crearemos un archivo `.github/workflows/deploy.yml` que:
    *   Instale Flutter.
    *   Ejecute `flutter build web --release --base-href /nombre-del-repo/`.
    *   Suba los archivos a la rama `gh-pages`.

### 9.2. Manejo de Rutas (SPA Fix)
Para evitar errores 404 al recargar la página en rutas secundarias (ej: `/forum`):
*   Implementaremos un script `404.html` en la carpeta `web/` que redirija las peticiones al `index.html` principal, manteniendo la ruta original en el historial de navegación.

---

## 10. Hoja de Ruta (Roadmap) Actualizada
1.  **Semana 1:** Definición de requerimientos y diseño de base de datos (SQL).
2.  **Semana 2:** Setup de Flutter, Auth y Navegación Base.
3.  **Semana 3:** Implementación del Foro y Actualizaciones (Lectura/Escritura).
4.  **Semana 4:** Módulo de Mentorías y Perfil de Usuario.
5.  **Semana 5:** Pulido de UI/UX, Testing y Despliegue en Netlify/Vercel.

---

## 6. Glosario de Términos
*   **RLS (Row Level Security):** Reglas de Supabase que determinan quién puede leer o escribir en cada fila.
*   **Widget:** La unidad básica de construcción en Flutter.
*   **Provider:** Objeto que encapsula el estado y lo expone a la UI.
