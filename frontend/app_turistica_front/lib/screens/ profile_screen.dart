import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nombreUsuario = '';
  String email = '';
  String imageUrl = 'assets/avatar.png'; // URL de la imagen de perfil
  File? _imageFile; // Archivo de imagen seleccionado
  bool isEditingUser = false; // Saber si se edita nombre de usuario
  bool isEditingEmail = false; // Saber si se edita email

  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Para editar el email

  // Función para obtener los datos del perfil
  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // Recupera el token guardado

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://10.0.0.150:3000/perfil'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nombreUsuario = data['nombre_usuario'] ?? '';
          email = data['email'] ?? 'email@dominio.com';
          imageUrl = data['foto_url'] ?? 'assets/avatar.png';
          _nombreUsuarioController.text = nombreUsuario; // Inicializa campo de texto
          _emailController.text = email; // Inicializa el campo de email
        });
      } else {
        print('Error al obtener los datos del perfil');
      }
    } else {
      print('Token no disponible');
    }
  }

  // Función para actualizar el perfil
  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // El token JWT

    // Asegúrate de que se están enviando todos los valores, incluso los no editados
    final response = await http.put(
      Uri.parse('http://10.0.0.150:3000/perfil'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode({
        'nombre_usuario': _nombreUsuarioController.text, // Siempre enviar el valor actual
        'email': _emailController.text, // Siempre enviar el valor actual
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        nombreUsuario = _nombreUsuarioController.text;
        email = _emailController.text;
        isEditingUser = false; // Desactivar el modo edición
        isEditingEmail = false;
      });
    } else {
      print('Error al actualizar el perfil');
    }
  }

  // Función para mostrar opciones de seleccionar imagen
  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar desde galería'),
                onTap: () {
                  _pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  _openCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Función para seleccionar una imagen desde la galería
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadProfileImage(); // Subir la imagen cuando se seleccione
    }
  }

  // Función para abrir la cámara
  Future<void> _openCamera() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadProfileImage(); // Subir la imagen cuando se seleccione
    }
  }

  // Función para subir la nueva imagen
  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.0.150:3000/perfil/foto'),
      );
      request.headers['Authorization'] = 'Bearer ${await _getToken()}';
      request.files.add(await http.MultipartFile.fromPath('foto', _imageFile!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _imageFile = null;
          _fetchProfileData(); // Refrescar los datos del perfil
        });
        print('Imagen subida correctamente');
      } else {
        print('Error al subir la imagen');
      }
    } catch (error) {
      print('Error al subir la imagen: $error');
    }
  }

  // Función para obtener el token de autenticación
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') ?? '';
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData(); // Cargar los datos del perfil al iniciar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()), // Regresa a HomeScreen, no al login
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Foto y Nombre de Usuario
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60, // Tamaño del avatar más grande
                    backgroundImage: _imageFile == null
                        ? AssetImage(imageUrl) as ImageProvider
                        : FileImage(_imageFile!),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        onPressed: _showImagePickerOptions, // Mostrar opciones de galería o cámara
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Campo editable para nombre de usuario
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isEditingUser
                      ? Expanded(
                    child: TextField(
                      controller: _nombreUsuarioController,
                      decoration: InputDecoration(
                        hintText: 'Editar nombre de usuario',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: _updateProfile, // Guardar cambios
                        ),
                      ),
                    ),
                  )
                      : Text(
                    nombreUsuario,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (!isEditingUser)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditingUser = true; // Activar modo edición
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Campo editable para email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isEditingEmail
                      ? Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Editar email',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: _updateProfile, // Guardar cambios
                        ),
                      ),
                    ),
                  )
                      : Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (!isEditingEmail)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditingEmail = true; // Activar modo edición
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
