# Documentación de Requerimientos: IusZac — Derecho Digital

## 1. Visión General
**IusZac** es una plataforma web integral diseñada para la comunidad legal del estado de Zacatecas (y México en general). Su objetivo es democratizar el acceso a la legislación actualizada, fomentar el debate académico mediante foros estructurados y facilitar la conexión entre estudiantes y abogados experimentados a través de sesiones de mentoría.

---

## 2. Estructura de Pantallas (15 Vistas Principales)

El sistema está diseñado en base a 15 pantallas clave, divididas en módulos funcionales:

### 2.1. Módulo de Autenticación y Onboarding
*   **01. Inicio (Splash/Landing):** Pantalla de bienvenida con el logotipo (balanza), Tagline y accesos directos.
*   **02. Registro de Usuario:** Formulario extendido con 12 campos que incluye datos personales, rol profesional (Estudiante, Docente, Postulante), contexto académico (Institución, Semestre) y configuración inicial de notificaciones.
*   **03. Iniciar Sesión:** Acceso a la plataforma y recuperación de contraseña.

### 2.2. Módulo de Navegación y Contenido Legal
*   **04. Inicio (Home):** Tablero principal con saludo dinámico, acceso rápido al buscador, visualización del "Artículo Destacado" y un carrusel de Códigos Legales.
*   **05. Catálogo de Códigos:** Lista de cuerpos normativos (ej. Constitución, Código Penal) con indicadores de estado ("Vigente", "Actualizado") y conteo de artículos.
*   **06. Detalle de Artículo:** Vista de lectura de un precepto legal. Incluye historial de reformas, insignias de "Reforma Reciente" y formateo dinámico de palabras clave (penas, sanciones).
*   **15. Búsqueda Global:** Interfaz de búsqueda transversal con historial de búsquedas recientes y sugerencias de artículos populares.

### 2.3. Módulo de Alertas de Reforma
*   **07. Alertas (Feed):** Línea de tiempo cronológica agrupada por fecha ("Hoy", "Ayer") que notifica sobre modificaciones de ley, destacando las nuevas con la insignia "NEW".
*   **08. Detalle de Reforma (Comparativo):** Vista especializada que muestra el impacto de una reforma, contrastando el "Texto Anterior" (tachado en rojo) con el "Texto Nuevo" (resaltado en verde).

### 2.4. Módulo de Foros de Discusión
*   **09. Lista de Hilos (Foro):** Espacio de debate organizado en una lista continua. Incluye un buscador inteligente basado en **Hashtags** (ej. `#penal`, `#amparo`) e indicadores visuales de "Asunto Urgente".
*   **10. Detalle de Hilo:** Conversación completa. Permite ver el post original y sus respuestas. Incluye marcas visuales para "Solución Aceptada" en los comentarios.

### 2.5. Módulo de Mentorías
*   **11. Lista de Mentorías:** Directorio de sesiones programadas. Permite filtrar por comunidad ("Apoyo UAZ", "ApoyoZac") y muestra costo (o "Gratis"), cupo disponible y calificación del mentor.
*   **12. Detalle de Mentoría:** Ficha extendida de la sesión que muestra el calendario/horarios disponibles, reseñas de participantes anteriores y la acción de inscripción.

### 2.6. Módulo de Perfil y Preferencias
*   **13. Perfil de Usuario:** Tablero personal que muestra estadísticas de actividad (artículos guardados, aportes al foro), insignias de nivel ("Miembro Pro") y accesos a marcadores.
*   **14. Ajustes:** Panel de configuración con "toggles" granulares para activar/desactivar notificaciones específicas (reformas, foros, correos, mentorías) y opciones de gestión de cuenta (eliminación de datos).

---

## 3. Arquitectura y Modelo de Datos (V3 Supabase)

El sistema utiliza **PostgreSQL** alojado en Supabase, implementando Seguridad a Nivel de Fila (RLS).

### 3.1. Tablas Base
*   **`profiles`**: Extensión de `auth.users`. Almacena nombre, apellidos, rol, institución, semestre y preferencias de alertas. (Se crea automáticamente vía Trigger).
*   **`legal_codes`**: Cuerpos normativos (Ej. Código Penal de Zacatecas).
*   **`legal_articles`**: Artículos individuales pertenecientes a un código.
*   **`saved_articles`**: Tabla pivote para gestionar los marcadores o "bookmarks" de cada usuario.

### 3.2. Tablas de Foros
*   **`forum_posts`**: Hilos de discusión. Incluye campos `is_urgent` (Booleano) y `tags` (Array de texto para hashtags).
*   **`forum_comments`**: Respuestas a los hilos. Incluye campo `is_solution` para destacar la mejor respuesta.

### 3.3. Tablas de Mentorías
*   **`mentorship_sessions`**: Clases o asesorías ofrecidas por mentores. Controla cupos (`available_slots`), precio (`price`) y calendario (`schedule`).
*   **`mentorship_enrollments`**: Registro de usuarios inscritos en una sesión específica.
*   **`mentorship_reviews`**: Sistema de calificación (1 a 5 estrellas) y comentarios sobre las sesiones.

### 3.4. Tablas de Alertas
*   **`legal_updates`**: Registro de reformas. Relacionada opcionalmente a un `legal_article` para habilitar la vista comparativa mediante los campos `old_content` y `new_content`.

---

## 4. Requerimientos No Funcionales Técnicos

### 4.1. Stack Tecnológico
*   **Frontend:** Flutter (Dart) compilado para Web.
*   **Gestión de Estado:** `flutter_riverpod` para el manejo de dependencias reactivas e inyección de servicios.
*   **Enrutamiento:** `go_router` configurado con 5 pestañas principales mediante `ShellRoute` (`/`, `/forum`, `/alerts`, `/mentorship`, `/profile`).

### 4.2. Despliegue y CI/CD
*   **Hosting:** GitHub Pages (`gh-pages`).
*   **Automatización:** GitHub Actions (`deploy.yml`) que compila la versión release inyectando el `base-href` correspondiente al nombre del repositorio.
*   **Autenticación:** URLs de redirección de Supabase Auth ajustadas a la URL de producción en GitHub Pages para garantizar el flujo correcto de los magic links y correos de confirmación.

---
*Documento actualizado y alineado con la especificación integral IusZac (Junio 2026).*
