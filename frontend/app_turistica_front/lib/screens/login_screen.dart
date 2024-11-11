import 'package:flutter/material.dart' hide CarouselController;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static String routeName = "/login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
      // Valida si el correo tiene un formato válido
      _isEmailValid =
          RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
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

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_BASE_URL']}/login'), // Asegúrate de usar la IP de tu backend
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String token = responseData['token'];

      // Guarda el token en el almacenamiento local para futuras solicitudes
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      print('Token guardado: $token');

      // Redirige a la pantalla principal con animación
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
      _showErrorSnackBar('Uppps, credenciales incorrectas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  'Tu viaje comienza aquí, inicia sesión para continuar.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSocialButton(
                  icon: FontAwesomeIcons.facebookF,
                  text: 'Continuar con Facebook',
                  backgroundColor: const Color(0xFF3b5998),
                  context: context,
                ),
                const SizedBox(height: 10),
                _buildSocialButton(
                  icon: FontAwesomeIcons.google,
                  text: 'Continuar con Google',
                  backgroundColor: const Color(0xFFDB4437),
                  context: context,
                ),
                const SizedBox(height: 10),
                _buildSocialButton(
                  icon: FontAwesomeIcons.apple,
                  text: 'Continuar con Apple',
                  backgroundColor: Colors.black,
                  context: context,
                ),
                const SizedBox(height: 30),
                _buildEmailField(),
                const SizedBox(height: 10),
                _buildPasswordField(),
                const SizedBox(height: 30),
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                const SizedBox(height: 10),
                _buildAnimatedButton(),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Acción de olvidó contraseña
                  },
                  child: const Text(
                    '¿Has olvidado tu contraseña?',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Acción de botón
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
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
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
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
          await login();
        }
            : null, // Desactivado si el correo no es válido
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(
          Icons.travel_explore, // Icono de turismo
          color: Colors.white,
        ),
        label: const Text(
          'Iniciar Sesión',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
