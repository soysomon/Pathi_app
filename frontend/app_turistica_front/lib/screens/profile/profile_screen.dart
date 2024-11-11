import 'package:app_turistica_front/screens/helpcenter/help_center.dart';
import 'package:app_turistica_front/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '/services/theme_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:app_turistica_front/screens/login_screen.dart';
import 'package:app_turistica_front/screens/profile/components/edit_profile.dart';
import 'package:app_turistica_front/screens/profile/components/profile_menu.dart';
import 'package:app_turistica_front/screens/profile/components/profile_pic.dart';
import 'package:app_turistica_front/screens/profile/components/publish_services.dart';
import 'package:app_turistica_front/screens/profile/components/publish_profile.dart';
import 'package:app_turistica_front/screens/profile/components/publish_promotion.dart';
import 'package:app_turistica_front/screens/profile/components/dark_mode.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static String routeName = "/profile";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nombreUsuario = '';
  String email = '';
  String imageUrl = 'assets/avatar.png'; // URL de la imagen de perfil
  File? _imageFile; // Archivo de imagen seleccionado
  bool isDarkMode = false; // Estado del modo oscuro

  final TextEditingController _nombreUsuarioController =
      TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); // Para editar el email

  // Función para alternar el modo oscuro
  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token =
        await prefs.getString('jwt_token'); // Recupera el token guardado
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('${dotenv.env['API_BASE_URL']}/perfil'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            nombreUsuario = data['nombre_usuario'] ?? '';
            email = data['email'] ?? 'email@dominio.com';
            imageUrl = data['foto_url'] ?? 'assets/avatar.png';
            _nombreUsuarioController.text =
                nombreUsuario; // Inicializa campo de texto
            _emailController.text = email; // Inicializa el campo de email
          });
        } else if (response.statusCode == 404) {
          print('Usuario no encontrado');
        } else {
          print(
              'Error al obtener los datos del perfil: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al realizar la solicitud: $e');
      }
    } else {
      print('Token no disponible');
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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadProfileImage(); // Subir la imagen cuando se seleccione
    }
  }

  // Función para abrir la cámara
  Future<void> _openCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
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
        Uri.parse('${dotenv.env['API_BASE_URL']}/perfil/foto'),
      );
      request.headers['Authorization'] = 'Bearer ${await _getToken()}';
      request.files
          .add(await http.MultipartFile.fromPath('foto', _imageFile!.path));

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

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('Token eliminado');
    Navigator.pushReplacementNamed(context, '/login');
  }

  String getProfileImagePath() {
    if (_imageFile != null && _imageFile!.path.isNotEmpty) {
      return _imageFile!.path;
    }
    return imageUrl.isNotEmpty ? imageUrl : 'assets/avatar.png';
  }

  Future<void> _updateProfile() async {
    print("--------------------------------------------------Actualizando perfil...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // El token JWT

    // Asegúrate de que se están enviando todos los valores, incluso los no editados
    final response = await http.put(
      Uri.parse('${dotenv.env['API_BASE_URL']}/perfil'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'nombre_usuario':
            _nombreUsuarioController.text, // Siempre enviar el valor actual
        'email': _emailController.text, // Siempre enviar el valor actual
      }),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          nombreUsuario = _nombreUsuarioController.text;
          email = _emailController.text;
        });
        Navigator.of(context).pop(); // Cerrar el diálogo
      }
    } else {
      print('Error al actualizar el perfil');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData(); // Cargar los datos del perfil al iniciar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

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
              MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen()), // Regresa a HomeScreen, no al login
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ProfilePic(
                name: nombreUsuario,
                email: email,
                imagePath: getProfileImagePath(),
                onImageTap: _showImagePickerOptions,
                onEditTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EditProfileDialog(
                        nombreUsuarioController: _nombreUsuarioController,
                        emailController: _emailController,
                        onUpdateProfile: _updateProfile,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              DarkModeSwitch(
                isDarkMode: themeService.isDarkMode,
                onToggle: (value) {
                  themeService.toggleTheme();
                },
              ),
              ProfileMenu(
                text: "Publicar Perfil",
                icon: "assets/icons/User.svg", // Icono de usuario
                press: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PublishProfile();
                    },
                  );
                },
              ),
              ProfileMenu(
                text: "Publicar Promoción",
                icon: "assets/icons/Cart Icon.svg", // Icono de etiqueta
                press: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PromotionsDialog();
                    },
                  );
                },
              ),
              ProfileMenu(
                text: "Publicar Servicio",
                icon: "assets/icons/Plus Icon.svg", // Icono de servicio
                press: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddServiceDialog();
                    },
                  );
                },
              ),
              ProfileMenu(
                text: "Help Center",
                icon: "assets/icons/Question mark.svg",
                press: () {
                  Navigator.pushNamed(context, HelpCenter.routeName);
                },
              ),
              ProfileMenu(
                text: "Log Out",
                icon: "assets/icons/Log out.svg",
                press: () async {
                  await logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LoginScreen()), // Regresa a HomeScreen, no al login
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}