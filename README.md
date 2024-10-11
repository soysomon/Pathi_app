# Pathi_app
# app_turistica

Proyecto App Turística
Este proyecto consiste en una aplicación de turismo que permite a los usuarios ver, gestionar y reservar servicios turísticos. El proyecto está dividido en dos partes principales: el frontend (desarrollado en Flutter) y el backend (API construida en Node.js con una base de datos PostgreSQL).

Características Completadas
Backend (API)
Autenticación de Usuarios:

Registro de usuarios con roles (usuario, empresa).
Inicio de sesión con autenticación por JWT.
Middleware para autenticar usuarios y verificar roles.
Gestión de Perfil:

Actualización del perfil del usuario (nombre de usuario y correo electrónico).
Validación para asegurar que no haya duplicados de nombre de usuario o correo.
Subida de Imagen de Perfil:

Soporte para subir fotos de perfil (aceptando solo imágenes JPEG y PNG).
Almacenamiento de imágenes en el servidor.
Servicios Turísticos:

Gestión de servicios turísticos por empresas (listar, agregar y eliminar servicios).
Filtro por provincia para los servicios turísticos.
Frontend (App Flutter)
Pantalla de Inicio de Sesión:

Inicio de sesión para usuarios autenticados.
Token JWT almacenado para gestionar la sesión.
Pantalla de Perfil de Usuario:

Visualización de la información del perfil (nombre de usuario, correo electrónico).
Opción para editar el nombre de usuario y correo electrónico.
Subida de imágenes de perfil con selección desde la galería o cámara.
Pantalla Principal:

Navegación al perfil de usuario.
Persistencia del token y manejo de la sesión.
Características del Backend que Faltan por Implementar en el Frontend
Sección de Servicios:

Falta implementar la visualización de los servicios turísticos ofrecidos por las empresas.
Crear una pantalla de servicios que liste los servicios turísticos disponibles.
Añadir un filtro por provincia para que los usuarios puedan buscar servicios según su ubicación.
Implementar la lógica para eliminar servicios en la sección de las empresas.
Sistema de Roles:

El backend ya maneja la autenticación por roles (usuario y empresa), pero falta implementar la lógica en el frontend para permitir que los usuarios con rol de empresa gestionen sus servicios (agregar, eliminar, modificar).
Mejoras en la Interfaz:

Aunque el perfil permite editar el nombre de usuario y el correo electrónico, aún no se ha implementado la visualización y gestión de otros detalles del usuario como reseñas de servicios o historial de reservas, que están previstos en el backend.
Conexión con la Base de Datos de Servicios:

Aún no se ha hecho la integración completa con la base de datos de servicios turísticos que ya está disponible en el backend. Se necesita conectar las pantallas del frontend con las rutas API de servicios (/servicios).
Requisitos para Ejecutar el Proyecto
Requisitos Generales
Node.js (para el backend)
Flutter SDK (para el frontend)
PostgreSQL (base de datos)
