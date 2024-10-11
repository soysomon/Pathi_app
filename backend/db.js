const { Pool } = require('pg');

// Configurar la conexión a PostgreSQL
const pool = new Pool({
    user: 'postgres', // El nombre de usuario que creaste durante la instalación
    host: 'localhost', // O la IP del servidor si no está local
    database: 'app_turistica', // El nombre de la base de datos que creaste
    password: 'somonx', // La contraseña que estableciste durante la instalación
    port: 5432, // El puerto predeterminado de PostgreSQL
});

module.exports = pool;

