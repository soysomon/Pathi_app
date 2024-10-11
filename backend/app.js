const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const pool = require('./db'); // Importar la conexión de la base de datos

const app = express();
const port = 3000;

// Crear la carpeta de "uploads" si no existe
const uploadDir = './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

app.use(bodyParser.json());

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({ message: 'API de la aplicación turística funcionando' });
});

// Middleware para autenticar el token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  
  if (!authHeader) {
    return res.status(403).json({ error: 'Acceso denegado. Token no proporcionado.' });
  }

  const token = authHeader.split(' ')[1]; // Eliminar el prefijo "Bearer"

  try {
    const decoded = jwt.verify(token, 'secret_key');
    req.user = decoded; // Adjuntar el usuario decodificado a la solicitud
    next(); // Procede al siguiente middleware o ruta
  } catch (error) {
    return res.status(401).json({ error: 'Token no válido.' });
  }
}

// Middleware para verificar el rol del usuario
function checkRole(roles) {
  return (req, res, next) => {
    if (!roles.includes(req.user.rol)) {
      return res.status(403).json({ error: 'Acceso denegado. Permisos insuficientes.' });
    }
    next(); // Si el rol es permitido, seguimos a la siguiente función
  };
}

// Middleware para verificar si el servicio existe
async function checkServicioExists(req, res, next) {
  const servicioId = req.params.id || req.params.servicioId;
  try {
    const servicio = await pool.query('SELECT * FROM servicios WHERE id = $1', [servicioId]);
    if (servicio.rows.length === 0) {
      return res.status(404).json({ error: 'Servicio no encontrado' });
    }
    req.servicio = servicio.rows[0]; // Adjuntamos el servicio para usarlo en otras partes del código
    next();
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al verificar el servicio' });
  }
}

// Registro de nuevos usuarios o empresas
app.post('/register', async (req, res) => {
  const { nombre, nombre_usuario, email, password, rol } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
      'INSERT INTO usuarios (nombre, nombre_usuario, email, password, rol) VALUES ($1, $2, $3, $4, $5) RETURNING id',
      [nombre, nombre_usuario, email, hashedPassword, rol]
    );

    const token = jwt.sign({ userId: result.rows[0].id, rol }, 'secret_key', { expiresIn: '1h' });
    res.status(201).json({ token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al registrar el usuario' });
  }
});


// Actualizar el perfil del usuario
app.put('/perfil', authenticateToken, async (req, res) => {
  const { nombre, nombre_usuario, email } = req.body;  // Recibe los datos a editar
  const userId = req.user.userId;

  try {
    // Obtener el perfil actual del usuario
    const userResult = await pool.query('SELECT * FROM usuarios WHERE id = $1', [userId]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    // Guardar los datos existentes para los campos que no se envían
    const existingUser = userResult.rows[0];
    const updatedNombre = nombre || existingUser.nombre; // Si no se envía, mantener el valor actual
    const updatedNombreUsuario = nombre_usuario || existingUser.nombre_usuario;
    const updatedEmail = email || existingUser.email;

    // Verificar si ya existe otro usuario con el mismo nombre de usuario o email, excluyendo al usuario actual
    if (nombre_usuario) {
      const existingUserUsername = await pool.query('SELECT * FROM usuarios WHERE nombre_usuario = $1 AND id != $2', [nombre_usuario, userId]);
      if (existingUserUsername.rows.length > 0) {
        return res.status(400).json({ error: 'Este nombre de usuario ya está en uso.' });
      }
    }

    if (email) {
      const existingUserEmail = await pool.query('SELECT * FROM usuarios WHERE email = $1 AND id != $2', [email, userId]);
      if (existingUserEmail.rows.length > 0) {
        return res.status(400).json({ error: 'Este correo ya está en uso.' });
      }
    }

    // Actualizar los campos que hayan sido enviados
    const result = await pool.query(
      'UPDATE usuarios SET nombre = $1, nombre_usuario = $2, email = $3 WHERE id = $4 RETURNING id, nombre, nombre_usuario, email',
      [updatedNombre, updatedNombreUsuario, updatedEmail, userId]
    );

    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al actualizar el perfil.' });
  }
});




// Configuración de multer para manejar el almacenamiento de imágenes
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');  // Carpeta para guardar las imágenes
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));  // Nombre único para cada archivo
  }
});

const upload = multer({
  storage: storage,
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Solo se permiten imágenes en formato JPEG o PNG'));
    }
  }
});

// Ruta para subir la foto de perfil
app.post('/perfil/foto', authenticateToken, upload.single('foto'), async (req, res) => {
  const userId = req.user.userId;

  if (!req.file) {
    return res.status(400).json({ error: 'No se ha enviado ninguna imagen' });
  }

  const fotoUrl = `uploads/${req.file.filename}`;  

  try {
    await pool.query('UPDATE usuarios SET foto_url = $1 WHERE id = $2', [fotoUrl, userId]);
    res.status(200).json({ message: 'Foto actualizada correctamente', fotoUrl: `http://localhost:3000/${fotoUrl}` });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al actualizar la foto de perfil' });
  }
});

// Ruta para obtener el perfil del usuario
app.get('/perfil', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT nombre, nombre_usuario, email, foto_url FROM usuarios WHERE id = $1', [req.user.userId]);
    if (result.rows.length > 0) {
      const user = result.rows[0];
      res.status(200).json({
        nombre: user.nombre,
        nombre_usuario: user.nombre_usuario,
        email: user.email,
        foto_url: user.foto_url ? `http://localhost:3000/${user.foto_url}` : null
      });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener los datos del perfil' });
  }
});




// Ruta para eliminar un servicio (sólo empresas)
app.delete('/servicios/:id', authenticateToken, checkRole(['empresa']), checkServicioExists, async (req, res) => {
  const servicioId = req.params.id;

  try {
    // Verificar si el servicio pertenece a la empresa autenticada
    if (req.servicio.empresa_id !== req.user.userId) {
      return res.status(403).json({ error: 'Acceso denegado. No puedes eliminar este servicio' });
    }

    // Eliminar el servicio
    await pool.query('DELETE FROM servicios WHERE id = $1', [servicioId]);
    res.status(200).json({ message: 'Servicio eliminado correctamente' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al eliminar el servicio' });
  }
});

// Inicio de sesión de usuarios
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Correo electrónico o contraseña incorrectos' });
    }

    const user = result.rows[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Correo electrónico o contraseña incorrectos' });
    }

    const token = jwt.sign({ userId: user.id, rol: user.rol }, 'secret_key', { expiresIn: '1h' });
    res.status(200).json({ token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
});

// Ruta para obtener todos los servicios turísticos, con filtro de provincia opcional
app.get('/servicios', async (req, res) => {
  const { provincia } = req.query;

  try {
    let query = 'SELECT * FROM servicios';
    let values = [];

    if (provincia) {
      query += ' WHERE provincia = $1';
      values.push(provincia);
    }

    const result = await pool.query(query, values);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener los servicios turísticos' });
  }
});

// Middleware global para manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Algo salió mal, por favor intenta de nuevo.' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Servidor corriendo en el puerto ${port}`);
});
