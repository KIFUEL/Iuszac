# ⚖ IusZac — Plan de Tareas v5.0
*Migración de permisos + módulo de publicaciones + suspensión de usuarios*
*Generado: Junio 2026*

---

> **Convención de estado:**
> - `[ ]` Pendiente
> - `[~]` En progreso
> - `[x]` Completado

---

## FASE 0 · Migración de Base de Datos (Supabase)

> Ejecutar en Supabase SQL Editor. No tocar Flutter hasta completar esta fase.
> Ejecutar los pasos en orden. Verificar el Paso 3 antes de continuar.

### 0.1 Columnas de permisos en `profiles`
- [ ] Agregar columna `can_mentor BOOLEAN DEFAULT false NOT NULL`
- [ ] Agregar columna `can_publish BOOLEAN DEFAULT false NOT NULL`
- [ ] Agregar columna `can_moderate BOOLEAN DEFAULT false NOT NULL`
- [ ] Agregar columna `can_manage_users BOOLEAN DEFAULT false NOT NULL`

### 0.2 Migrar datos existentes
- [ ] `UPDATE profiles SET can_mentor = true WHERE user_type = 'mentor'`
- [ ] `UPDATE profiles SET can_mentor, can_publish, can_moderate, can_manage_users = true WHERE user_type = 'admin'`

### 0.3 Verificar migración (no continuar si falla)
- [ ] Confirmar que ningún mentor quedó sin `can_mentor = true`
- [ ] Confirmar que ningún admin quedó sin `can_manage_users = true`

### 0.4 Normalizar `user_type`
- [ ] `UPDATE profiles SET user_type = 'user' WHERE user_type = 'mentor'`
- [ ] Agregar constraint `CHECK (user_type IN ('user', 'admin'))`

### 0.5 Columnas de suspensión en `profiles`
- [ ] Agregar columna `is_suspended BOOLEAN DEFAULT false NOT NULL`
- [ ] Agregar columna `suspended_until TIMESTAMP`
- [ ] Agregar columna `suspension_reason TEXT`

### 0.6 Campos nuevos en `legal_updates`
- [ ] Agregar columna `status TEXT DEFAULT 'published' NOT NULL`
- [ ] Agregar columna `content_type TEXT DEFAULT 'reforma' NOT NULL`
- [ ] Agregar columna `tags TEXT[] DEFAULT '{}'`
- [ ] Agregar columna `source_name TEXT`
- [ ] Agregar columna `source_url TEXT`
- [ ] Agregar columna `event_start TIMESTAMP`
- [ ] Agregar columna `event_end TIMESTAMP`
- [ ] Agregar columna `event_location TEXT`
- [ ] Agregar columna `event_link TEXT`
- [ ] Agregar columna `deadline TEXT`

### 0.7 Nueva tabla `legal_update_articles`
- [ ] Crear tabla con campos: `id`, `update_id FK`, `article_id FK`
- [ ] Agregar constraint `UNIQUE(update_id, article_id)`
- [ ] Agregar `ON DELETE CASCADE` en ambas FK

### 0.8 Actualizar políticas RLS
- [ ] Eliminar política `admin_insert_legal_updates`
- [ ] Crear política `publisher_insert_legal_updates` usando `can_publish = true`
- [ ] Actualizar política de UPDATE en `legal_updates` para `can_publish`
- [ ] Actualizar política de DELETE en `legal_updates` para `can_moderate`
- [ ] Crear política para que solo `can_manage_users` modifique campos de permisos y suspensión

### 0.9 Funciones SECURITY DEFINER
- [ ] Crear función `admin_set_permissions(target_id, can_mentor, can_publish, can_moderate)`
- [ ] Crear función `admin_suspend_user(target_id, suspend_until, reason)`
- [ ] Crear función `admin_lift_suspension(target_id)`
- [ ] Probar cada función desde SQL Editor con un usuario de prueba

---

## FASE 1 · Modelo de Datos en Flutter

> Solo modificar el modelo `Profile` y su provider. No tocar pantallas todavía.

### 1.1 Actualizar clase `Profile`
- [ ] Agregar campo `canMentor bool`
- [ ] Agregar campo `canPublish bool`
- [ ] Agregar campo `canModerate bool`
- [ ] Agregar campo `canManageUsers bool`
- [ ] Agregar campo `isSuspended bool`
- [ ] Agregar campo `suspendedUntil DateTime?`
- [ ] Agregar campo `suspensionReason String?`
- [ ] Agregar getter `bool get isAdmin => userType == 'admin'`
- [ ] Agregar getter `bool get isActivelySuspended => isSuspended && (suspendedUntil?.isAfter(DateTime.now()) ?? false)`
- [ ] Actualizar `fromJson()` para leer los campos nuevos
- [ ] Actualizar `toJson()` si aplica

### 1.2 Actualizar `userProfileProvider`
- [ ] Confirmar que el SELECT en Supabase incluye todos los campos nuevos
- [ ] Verificar que la app compila sin errores después del cambio de modelo

---

## FASE 2 · Guards y Lógica de Permisos en Flutter

> El compilador de Dart señalará exactamente los lugares a corregir tras la Fase 1.

### 2.1 Reemplazar comparaciones de `user_type`
- [ ] `profile.userType == 'mentor'` → `profile.canMentor`
- [ ] `profile.userType == 'admin'` → `profile.canManageUsers` (o el permiso específico según el contexto)
- [ ] Revisar que no queden referencias a `user_type == 'mentor'` en el código

### 2.2 Actualizar guards de GoRouter
- [ ] Guard de `/mentorship/new` → `profile.canMentor`
- [ ] Guard de `/mentorship/edit/:id` → `profile.canMentor`
- [ ] Guard de `/admin/new-update` → `profile.canPublish`
- [ ] Guard de `/admin/moderation` → `profile.canModerate`
- [ ] Guard de `/admin/mentors` (renombrar a `/admin/users`) → `profile.canManageUsers`
- [ ] Guard de `/admin/suspend/:userId` → `profile.canManageUsers`
- [ ] Guard global de suspensión → si `profile.isActivelySuspended` redirigir a `/suspended`

### 2.3 Actualizar visibilidad de elementos UI
- [ ] FAB de nueva mentoría → visible si `canMentor`
- [ ] Botón de publicar noticia en el home/admin → visible si `canPublish`
- [ ] Opciones de moderación en posts/comentarios → visible si `canModerate`
- [ ] Menú de gestión de usuarios → visible si `canManageUsers`

---

## FASE 3 · Pantalla de Gestión de Usuarios (reemplaza `/admin/mentors`)

### 3.1 Renombrar y reestructurar la pantalla
- [ ] Cambiar ruta de `/admin/mentors` a `/admin/users`
- [ ] Actualizar referencias en GoRouter y en el panel de administración

### 3.2 Listado de usuarios
- [ ] Implementar buscador por nombre, apellido o correo
- [ ] Agregar filtros: Todos / Con permisos / Suspendidos
- [ ] Mostrar chips de permisos activos por tarjeta (🎓 Mentor, 📰 Editor, 🛡 Moderador)
- [ ] Mostrar badge "SUSPENDIDO" con días restantes si aplica
- [ ] Botón "Editar" por tarjeta que abre el bottom sheet de permisos

### 3.3 Bottom sheet de edición de permisos
- [ ] Toggle para `can_mentor` con label "Puede publicar mentorías"
- [ ] Toggle para `can_publish` con label "Puede publicar noticias"
- [ ] Toggle para `can_moderate` con label "Puede moderar contenido"
- [ ] Botón "Suspender usuario" que navega a `/admin/suspend/:userId`
- [ ] Botón "Guardar cambios" que llama `admin_set_permissions()`
- [ ] Diálogo de confirmación antes de guardar

### 3.4 Providers nuevos
- [ ] Crear `allUsersProvider` (lista paginada de todos los perfiles)
- [ ] Crear `suspendedUsersProvider` (perfiles con suspensión activa)

---

## FASE 4 · Módulo de Publicación de Noticias Mejorado

### 4.1 Formulario dinámico por tipo de contenido
- [ ] Implementar selector de tipo: Reforma / Noticia / Evento / Convocatoria
- [ ] Mostrar/ocultar sección "Artículo vinculado" solo para Reforma
- [ ] Mostrar/ocultar sección "Texto anterior / Texto nuevo" solo para Reforma
- [ ] Mostrar/ocultar campos "Fecha inicio", "Fecha fin", "Lugar", "Enlace de registro" solo para Evento
- [ ] Mostrar/ocultar campo "Fecha límite" y "Requisitos" solo para Convocatoria
- [ ] Mostrar/ocultar campos "Fuente" y "URL fuente" para Reforma, Noticia y Convocatoria

### 4.2 Campos comunes a todos los tipos
- [ ] Campo Título (obligatorio)
- [ ] Campo Imagen de portada (URL, opcional)
- [ ] Campo Tags separados por coma → parsear a `TEXT[]`
- [ ] Editor de texto enriquecido para el cuerpo (`flutter_quill` o equivalente)
  - [ ] Soporte para negrita
  - [ ] Soporte para cursiva
  - [ ] Soporte para listas
  - [ ] Soporte para enlaces

### 4.3 Sistema de estado de publicación
- [ ] Selector "Borrador / Publicar ahora / Programar"
- [ ] DateTimePicker para fecha programada (visible solo si se elige "Programar")
- [ ] Guardar `status = 'draft'` si se elige borrador
- [ ] Guardar `status = 'scheduled'` con `published_at` futuro si se programa
- [ ] Guardar `status = 'published'` con `published_at = NOW()` si se publica directo

### 4.4 Acceso a la pantalla
- [ ] Guard de ruta: accesible si `canPublish = true` (no solo admins)
- [ ] Agregar acceso desde el panel de admin
- [ ] Agregar acceso desde el perfil de usuarios con `can_publish`

### 4.5 Providers nuevos o actualizados
- [ ] Actualizar `legalUpdatesProvider` para filtrar `status = 'published'` en el feed público
- [ ] Crear `myDraftsProvider` para que el editor vea sus borradores
- [ ] Crear `scheduledUpdatesProvider` para que el admin vea publicaciones programadas

---

## FASE 5 · Suspensión de Usuarios

### 5.1 Pantalla 23 · Formulario de suspensión (`/admin/suspend/:userId`)
- [ ] Mostrar info del usuario (nombre, correo, tipo, etiqueta)
- [ ] Radio buttons de duración: 1, 3, 7, 15, 30 días o personalizado
- [ ] DatePicker de fecha fin (calculado automáticamente, editable en modo personalizado)
- [ ] Validar que la fecha fin no sea pasada
- [ ] Campo de motivo (obligatorio, mínimo 10 caracteres)
- [ ] Botón "Aplicar Suspensión" con diálogo de confirmación → llama `admin_suspend_user()`
- [ ] Botón "Levantar Suspensión" visible si el usuario ya tiene suspensión activa → llama `admin_lift_suspension()`
- [ ] Invalidar providers tras aplicar o levantar suspensión

### 5.2 Pantalla 24 · Aviso de cuenta suspendida (`/suspended`)
- [ ] Pantalla sin ShellRoute (sin barra de navegación)
- [ ] Mostrar ícono de restricción
- [ ] Mostrar `suspended_until` formateada en español
- [ ] Mostrar `suspension_reason`
- [ ] Único botón: "Cerrar sesión" → `signOut()` + navegar a `/splash`

### 5.3 Guard de suspensión en GoRouter
- [ ] Al cargar `userProfileProvider`, verificar `isActivelySuspended`
- [ ] Si activo, ejecutar `signOut()` automático y redirigir a `/suspended`
- [ ] Si `suspended_until <= NOW()`, limpiar suspensión automáticamente (UPDATE en Supabase o verificación en `signIn`)

---

## FASE 6 · Actualizar Documentación

- [ ] Actualizar `DOCUMENTATION.md` a v5.0 con el nuevo sistema de permisos
- [ ] Reemplazar todas las referencias a `user_type = 'mentor'` por `can_mentor`
- [ ] Documentar la tabla de permisos y cómo escalan
- [ ] Actualizar el modelo de datos de `profiles` con los campos nuevos
- [ ] Actualizar las políticas RLS documentadas
- [ ] Documentar pantalla 20 rediseñada (formulario dinámico)
- [ ] Documentar pantalla 21 rediseñada (gestión de usuarios con permisos)
- [ ] Documentar pantallas 23 y 24 (suspensión)
- [ ] Actualizar el historial de cambios con la versión 5.0

---

## Resumen de progreso

| **Fase** | **Tareas** | **Completadas** | **Estado** |
|---|---|---|---|
| 0 · Base de Datos | 27 | 0 | `[ ]` Pendiente |
| 1 · Modelo Flutter | 12 | 0 | `[ ]` Pendiente |
| 2 · Guards y Permisos | 16 | 0 | `[ ]` Pendiente |
| 3 · Gestión de Usuarios | 12 | 0 | `[ ]` Pendiente |
| 4 · Módulo Publicaciones | 18 | 0 | `[ ]` Pendiente |
| 5 · Suspensión | 11 | 0 | `[ ]` Pendiente |
| 6 · Documentación | 8 | 0 | `[ ]` Pendiente |
| **Total** | **104** | **0** | |

---

> ⚠️ **Regla de oro:** No empezar una fase sin tener la anterior completada al 100%.
> La Fase 0 es la única que puede hacerse de forma incremental (paso a paso) sin riesgo,
> ya que agregar columnas con `DEFAULT` no rompe el frontend existente.

---
*IusZac · Plan de Tareas v5.0 · Zacatecas, Junio 2026*
