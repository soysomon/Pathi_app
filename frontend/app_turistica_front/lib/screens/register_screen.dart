import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  static String routeName = "/register";

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'turista';
  bool _isEmailValid = false;
  bool _obscurePassword = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    setState(() {
      final email = _emailController.text;
      _isEmailValid = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(milliseconds: 3000),
      ),
    );
  }

  Future<void> register() async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_BASE_URL']}/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': _nameController.text,
        'nombre_usuario': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'rol': _selectedRole,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      String token = responseData['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      print('Token guardado: $token');

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else {
      _showErrorSnackBar('Error al registrar el usuario');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF47DCB6),
                Color(0xFF46C9C1),
                Color(0xFF45B0CF),
                Color(0xFF44A3D8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    height: 190,
                    child: Image.asset('assets/loginpathi.png'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Regístrate para comenzar tu viaje.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, 'Introducir nombre'),
                  const SizedBox(height: 10),
                  _buildTextField(_usernameController, 'Introducir nombre de usuario'),
                  const SizedBox(height: 10),
                  _buildEmailField(),
                  const SizedBox(height: 10),
                  _buildPasswordField(),
                  const SizedBox(height: 10),
                  _buildRoleDropdown(),
                  const SizedBox(height: 30),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  const SizedBox(height: 10),
                  _buildAnimatedButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(
        textStyle: const TextStyle(color: Colors.white),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      style: GoogleFonts.inter(
        textStyle: const TextStyle(color: Colors.white),
      ),
      decoration: InputDecoration(
        hintText: 'Introducir correo',
        hintStyle: const TextStyle(color: Colors.white70),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: _isEmailValid ? Colors.white : Colors.red,
            width: 2.0,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: _isEmailValid ? Colors.white : Colors.red,
            width: 2.0,
          ),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.inter(
        textStyle: const TextStyle(color: Colors.white),
      ),
      decoration: InputDecoration(
        hintText: 'Introducir contraseña',
        hintStyle: const TextStyle(color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items: [
        DropdownMenuItem(
          value: 'empresa',
          child: Text('Empresa', style: GoogleFonts.inter(color: Colors.white)),
        ),
        DropdownMenuItem(
          value: 'turista',
          child: Text('Turista', style: GoogleFonts.inter(color: Colors.white)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRole = value!;
        });
      },
      decoration: InputDecoration(
        hintText: 'Seleccionar rol',
        hintStyle: const TextStyle(color: Colors.white70),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
      dropdownColor: Colors.blueAccent,
    );
  }

  Widget _buildAnimatedButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: _isEmailValid
            ? const LinearGradient(
                colors: [
                  Color(0xFF6BEA9D),
                  Color(0xFF5ACB96),
                  Color(0xFF47DCB6),
                  Color(0xFF44A3D8),
                ],
              )
            : LinearGradient(
                colors: [
                  Colors.grey.shade700,
                  Colors.grey.shade600,
                ],
              ),
      ),
      child: ElevatedButton.icon(
        onPressed: _isEmailValid
            ? () async {
                await register();
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(
          Icons.person_add,
          color: Colors.white,
        ),
        label: const Text(
          'Registrarse',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}