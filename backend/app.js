require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const pool = require('./db'); // Importar la conexión de la base de datos
const cors = require('cors');
const braintree = require('braintree');

const app = express();
const port = 3000;

app.use(cors());

// Crear la carpeta de "uploads" si no existe
const uploadDir = './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/imagenes_emp', express.static(path.join(__dirname, 'imagenes_emp')));
app.use('/imagenes_servicios', express.static(path.join(__dirname, 'imagenes_servicios')));

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
    req.user = {
      userId: decoded.userId,
      nombre: decoded.nombre,
      email: decoded.email
    };
     // Adjuntar el usuario decodificado a la solicitud
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
    const filetypes = /jpeg|jpg|png|gif|bmp|webp/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = file.mimetype.startsWith('image/') || file.mimetype === 'application/octet-stream';

    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten imágenes en formato JPEG, PNG, GIF, BMP o WebP'));
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
    const result = await pool.query('SELECT nombre, nombre_usuario, email, foto_url, rol FROM usuarios WHERE id = $1', [req.user.userId]);
    if (result.rows.length > 0) {
      const user = result.rows[0];
      res.status(200).json({
        id: req.user.userId,
        nombre: user.nombre,
        nombre_usuario: user.nombre_usuario,
        email: user.email,
        foto_url: user.foto_url ? `http://localhost:3000/${user.foto_url}` : null,
        rol: user.rol
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

    const token = jwt.sign(
      { userId: user.id, nombre: user.nombre, email: user.email, rol: user.rol },
      'secret_key',
      { expiresIn: '1h' }
    );
    res.status(200).json({ token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
});

// Ruta para obtener todos los servicios turísticos
app.get('/servicios', async (req, res) => {
  try {
    const query = `
      SELECT s.* 
      FROM servicios s
      JOIN usuarios u ON s.empresa_id = u.id
      WHERE u.publico = true
    `;

    const result = await pool.query(query);
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

// Configuración de multer para manejar el almacenamiento de imágenes empresariales
const storageEmp = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDirEmp = './imagenes_emp';
    if (!fs.existsSync(uploadDirEmp)) {
      fs.mkdirSync(uploadDirEmp);
    }
    cb(null, uploadDirEmp);  // Carpeta para guardar las imágenes empresariales
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));  // Nombre único para cada archivo
  }
});

const uploadEmp = multer({
  storage: storageEmp,
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|gif|bmp|webp/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = file.mimetype.startsWith('image/') || file.mimetype === 'application/octet-stream';

    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten imágenes en formato JPEG, PNG, GIF, BMP o WebP'));
    }
  }
});

// Endpoint para actualizar los campos ubicacion, imagen_empresarial, detalles y localizacion
app.put('/update_company_fields/:id', authenticateToken, uploadEmp.single('imagen_empresarial'), async (req, res) => {
  const { id } = req.params;
  const { ubicacion, detalles, localizacion } = req.body;
  let imagenEmpresarialUrl = null;

  if (req.file) {
    imagenEmpresarialUrl = `imagenes_emp/${req.file.filename}`;
  }

  try {
    const result = await pool.query(
      'UPDATE usuarios SET ubicacion = $1, imagen_empresarial = $2, detalles = $3, localizacion = $4 WHERE id = $5',
      [ubicacion, imagenEmpresarialUrl, detalles, localizacion, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.status(200).json({ message: 'Campos actualizados correctamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar los campos' });
  }
});

// Ruta para listar todos los usuarios
app.get('/destinos', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query("SELECT id, nombre_usuario, ubicacion, detalles, imagen_empresarial FROM usuarios WHERE rol = 'empresa' AND publico = true");
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener la lista de usuarios' });
  }
});

const storageServ = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDirServ = './imagenes_servicios';
    if (!fs.existsSync(uploadDirServ)) {
      fs.mkdirSync(uploadDirServ);
    }
    cb(null, uploadDirServ);  // Carpeta para guardar las imágenes de servicios
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));  // Nombre único para cada archivo
  }
});

const uploadServ = multer({
  storage: storageServ,
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|gif|bmp|webp/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = file.mimetype.startsWith('image/') || file.mimetype === 'application/octet-stream';

    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten imágenes en formato JPEG, PNG, GIF, BMP o WebP'));
    }
  }
});

// Ruta para registrar un nuevo servicio (sólo empresas)
app.post('/registrar_servicios', authenticateToken, uploadServ.single('imagen_servicio'), async (req, res) => {
  const { nombre, descripcion, precio, ubicacion } = req.body;
  const empresaId = req.user.userId;
  let imagenServicioUrl = null;

  if (req.file) {
    imagenServicioUrl = `imagenes_servicios/${req.file.filename}`;
  }

  try {
    const result = await pool.query(
      'INSERT INTO servicios (nombre, descripcion, empresa_id, creado_en, precio, imagen_servicio) VALUES ($1, $2, $3, NOW(), $4, $5) RETURNING id',
      [nombre, descripcion, empresaId, precio, imagenServicioUrl]
    );

    res.status(201).json({ message: 'Servicio registrado correctamente', servicioId: result.rows[0].id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al registrar el servicio' });
  }
});

// Ruta para listar todos los servicios de una empresa por su empresaId
app.get('/empresa/:empresaId/servicios', authenticateToken, async (req, res) => {
  const { empresaId } = req.params;

  try {
    const result = await pool.query('SELECT * FROM servicios WHERE empresa_id = $1', [empresaId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'No se encontraron servicios para esta empresa' });
    }
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener los servicios de la empresa' });
  }
});

// Ruta para registrar una nueva promoción
app.post('/promociones', authenticateToken, async (req, res) => {
  const { servicio_id, nombre_servicio, fecha, estado, detalles } = req.body;
  const usuario_id = req.user.userId; // Obtener el ID del usuario logueado

  try {
    const result = await pool.query(
      'INSERT INTO promociones (servicio_id, nombre_servicio, usuario_id, fecha, estado, creado_en, detalles) VALUES ($1, $2, $3, $4, $5, NOW(), $6) RETURNING id',
      [servicio_id, nombre_servicio, usuario_id, fecha, estado, detalles]
    );

    res.status(201).json({ message: 'Promoción registrada correctamente', promocionId: result.rows[0].id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al registrar la promoción' });
  }
});

// Ruta para listar todos los servicios del usuario registrado
app.get('/mis_servicios', authenticateToken, async (req, res) => {
  const usuarioId = req.user.userId;

  try {
    const result = await pool.query('SELECT id, nombre FROM servicios WHERE empresa_id = $1', [usuarioId]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener los servicios del usuario' });
  }
});

// Ruta para listar todas las promociones
app.get('/listar_promociones', authenticateToken, async (req, res) => {
  try {
    const query = `
      SELECT p.* 
      FROM promociones p
      JOIN usuarios u ON p.usuario_id = u.id
      WHERE u.publico = true
    `;

    const result = await pool.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener las promociones' });
  }
});

async function incrementarReservas(usuarioId) {
  try {
    await pool.query("UPDATE usuarios SET reservas = reservas + 1 WHERE id = $1", [usuarioId]);
  } catch (error) {
    console.error('Error al incrementar el contador de reservas:', error);
  }
}

// Ruta para registrar una nueva reserva
app.post('/reservas', authenticateToken, async (req, res) => {
  const { usuario_id, telefono, fecha, hora, detalles, total_pagar } = req.body;
  const usuario_registrado = req.user.userId; // Obtener el ID del usuario logueado
  const nombre_usuario = req.user.nombre; // Obtener el nombre del usuario logueado
  const correo = req.user.email; // Obtener el correo del usuario logueado

  try {
    const result = await pool.query(
      'INSERT INTO reservas (usuario_id, nombre_usuario, correo, telefono, fecha, hora, estado, creado_en, detalles, total_pagar, usuario_registrado) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), $8, $9, $10) RETURNING id',
      [usuario_id, nombre_usuario, correo, telefono, fecha, hora, 'reservado', detalles, total_pagar, usuario_registrado]
    );

    await incrementarReservas(usuario_id);

    res.status(201).json({ message: 'Reserva registrada correctamente', reservaId: result.rows[0].id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al registrar la reserva' });
  }
});

// Ruta para actualizar una reserva
app.put('/reservas/:id', authenticateToken, async (req, res) => {
  const { id } = req.params;
  const { transaction_id } = req.body;

  try {
    const result = await pool.query(
      'UPDATE reservas SET transaction_id = $1 WHERE id = $2 RETURNING id',
      [transaction_id, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Reserva no encontrada' });
    }

    res.status(200).json({ message: 'Reserva actualizada correctamente' });
  } catch (error) {
    console.error('Error al actualizar la reserva:', error);
    res.status(500).json({ error: 'Error al actualizar la reserva' });
  }
});



// Ruta para listar todas las reservas del usuario logueado con estado "reservado"
app.get('/listar_reservas', authenticateToken, async (req, res) => {
  const usuario_registrado = req.user.userId; // Obtener el ID del usuario logueado

  try {
    const result = await pool.query(`
      SELECT r.*, u.*
      FROM reservas r
      JOIN usuarios u ON r.usuario_id = u.id
      WHERE r.usuario_registrado = $1 AND r.estado = 'reservado'
    `, [usuario_registrado]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener las reservas' });
  }
});

// Endpoint para obtener el estado del campo 'publico'
app.get('/usuarios/:id/publico', authenticateToken, async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT publico FROM usuarios WHERE id = $1', [id]);
    if (result.rows.length > 0) {
      res.json({ publico: result.rows[0].publico });
    } else {
      res.status(404).json({ error: 'Usuario no encontrado' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener el estado del campo publico' });
  }
});

// Endpoint para hacer toggle del campo 'publico'
app.post('/usuarios/:id/toggle-publico', authenticateToken, async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT publico FROM usuarios WHERE id = $1', [id]);
    if (result.rows.length > 0) {
      const currentPublico = result.rows[0].publico;
      const newPublico = !currentPublico;
      await pool.query('UPDATE usuarios SET publico = $1 WHERE id = $2', [newPublico, id]);
      res.json({ publico: newPublico });
    } else {
      res.status(404).json({ error: 'Usuario no encontrado' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Error al actualizar el estado del campo publico' });
  }
});

// Ruta para buscar destinos
app.get('/buscar-destinos', authenticateToken, async (req, res) => {
  const { search } = req.query;

  if (!search) {
    return res.status(400).json({ error: 'El término de búsqueda es requerido' });
  }

  try {
    const query = `
      SELECT id, nombre_usuario, ubicacion, detalles, imagen_empresarial 
      FROM usuarios 
      WHERE rol = 'empresa' 
        AND publico = true 
        AND (nombre_usuario ILIKE $1 OR ubicacion ILIKE $1 OR detalles ILIKE $1)
    `;
    const values = [`%${search}%`];

    const result = await pool.query(query, values);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al buscar destinos' });
  }
});

// Configura Braintree
const gateway = new braintree.BraintreeGateway({
  environment: braintree.Environment[process.env.BRAINTREE_ENVIRONMENT],
  merchantId: process.env.BRAINTREE_MERCHANT_ID,
  publicKey: process.env.BRAINTREE_PUBLIC_KEY,
  privateKey: process.env.BRAINTREE_PRIVATE_KEY,
  paypal: {
    payeeEmail: process.env.PAYPAL_PAYEE_EMAIL,
    flow: 'checkout',
    amount: '10.00',
    currency: 'USD'
  },
  googlePay: {
    merchantId: process.env.GOOGLE_PAY_MERCHANT_ID,
  }
});

app.get('/client_token', (req, res) => {
  const clientTokenRequest = {
    merchantAccountId: 'pahti'
  };

  gateway.clientToken.generate(clientTokenRequest, (err, response) => {
    if (err) {
      res.status(500).send(err);
    } else {
      res.send(response.clientToken);
    }
  });
});

app.post('/checkout', async (req, res) => {
  const nonceFromTheClient = req.body.paymentMethodNonce;
  const amount = req.body.amount;
  const paymentMethod = req.body.paymentMethod;
  const reservationId = req.body.reservationId; // Asegúrate de recibir el ID de la reserva

  let nonceToUse = nonceFromTheClient;

  if (paymentMethod === 'googlePay') {
    nonceToUse = 'fake-google-pay-nonce';
  }

  try {
    const result = await gateway.transaction.sale({
      amount: amount,
      paymentMethodNonce: nonceToUse,
      merchantAccountId: 'pahti',
      options: {
        submitForSettlement: true
      }
    });

    if (!result.success) {
      console.error('Error procesando la transacción:', result.message);
      return res.status(500).send(result.message);
    }

    // Guarda el transactionId en la base de datos
    const transactionId = result.transaction.id;
    await pool.query('UPDATE reservas SET transaction_id = $1 WHERE id = $2', [transactionId, reservationId]);

    res.send({ transactionId, result });
  } catch (err) {
    console.error('Error procesando la transacción:', err);
    res.status(500).send(err);
  }
});

// Endpoint para realizar un reembolso
app.post('/refund', authenticateToken, async (req, res) => {
  const { reservationId } = req.body;

  try {
    // Obtener el transaction_id y el total_pagar de la reserva
    const result = await pool.query('SELECT transaction_id, total_pagar FROM reservas WHERE id = $1', [reservationId]);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Reserva no encontrada' });
    }

    const { transaction_id: transactionId, total_pagar: amount } = result.rows[0];

    // Obtener el estado de la transacción
    const transaction = await gateway.transaction.find(transactionId);

    let refundResult;
    if (transaction.status === 'settled' || transaction.status === 'settling') {
      // Realizar el reembolso si la transacción está liquidada o en proceso de liquidación
      refundResult = await gateway.transaction.refund(transactionId, amount);
    } else {
      // Anular la transacción si aún no está liquidada
      refundResult = await gateway.transaction.void(transactionId);
    }

    if (!refundResult.success) {
      console.error('Error procesando el reembolso/anulación:', refundResult.message);
      return res.status(500).json({ error: refundResult.message });
    }

    // Actualizar el estado de la reserva a "cancelado"
    await pool.query('UPDATE reservas SET estado = $1 WHERE id = $2', ['cancelado', reservationId]);

    res.status(200).json(refundResult);
  } catch (error) {
    console.error('Error al procesar el reembolso/anulación:', error);
    res.status(500).json({ error: 'Error al procesar el reembolso/anulación' });
  }
});


// Ruta para buscar destinos
app.get('/buscar-destinos', authenticateToken, async (req, res) => {
  const { search } = req.query;

  if (!search) {
    return res.status(400).json({ error: 'El término de búsqueda es requerido' });
  }

  try {
    const query = `
      SELECT id, nombre_usuario, ubicacion, detalles, imagen_empresarial 
      FROM usuarios 
      WHERE rol = 'empresa' 
        AND publico = true 
        AND (nombre_usuario ILIKE $1 OR ubicacion ILIKE $1 OR detalles ILIKE $1)
    `;
    const values = [`%${search}%`];

    const result = await pool.query(query, values);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al buscar destinos' });
  }
});

// Endpoint para obtener los 3 usuarios con más reservas y que tienen publico en true
app.get('/usuarios/top-reservas', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM usuarios WHERE publico = true ORDER BY reservas DESC LIMIT 3');
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error al obtener los usuarios con más reservas:', error);
    res.status(500).json({ error: 'Error al obtener los usuarios con más reservas' });
  }
});

// Ruta para listar todas las reservas del usuario logueado (solo para empresas)
app.get('/listar_clientes', authenticateToken, async (req, res) => {
  const usuario_registrado = req.user.userId; // Obtener el ID del usuario logueado

  try {
    const result = await pool.query(`
      SELECT r.*, u.*
      FROM reservas r
      JOIN usuarios u ON r.usuario_id = u.id
      WHERE r.usuario_id = $1
    `, [usuario_registrado]);

    if (result.rows.length === 0) {
      console.log('No se encontraron reservas para el usuario registrado.');
    }

    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener las reservas' });
  }
});

// Ruta para obtener solo el rol del usuario autenticado
app.get('/obtener_rol', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT rol FROM usuarios WHERE id = $1', [req.user.userId]);
    if (result.rows.length > 0) {
      res.status(200).json({ rol: result.rows[0].rol });
    } else {
      res.status(404).json({ error: 'Usuario no encontrado' });
    }
  } catch (error) {
    console.error('Error al obtener el rol del usuario:', error);
    res.status(500).json({ error: 'Error al obtener el rol del usuario' });
  }
});
