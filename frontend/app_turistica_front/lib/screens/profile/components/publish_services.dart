import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddServiceDialog extends StatefulWidget {
  @override
  _AddServiceDialogState createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  double price = 0.0;
  String image = '';
  bool isLoading = false;

  Future<void> _registerService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Token no disponible, inicia sesión nuevamente')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final uri =
          Uri.parse('${dotenv.env['API_BASE_URL']}/registrar_servicios');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['nombre'] = title
        ..fields['descripcion'] = description
        ..fields['precio'] = price.toString();

      if (image.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagen_servicio',
          image,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Servicio registrado correctamente')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el servicio')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión al servidor')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width - 20,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Publicar Servicio',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSaved: (value) {
                        title = value ?? '';
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSaved: (value) {
                        description = value ?? '';
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        price = double.tryParse(value ?? '0') ?? 0.0;
                      },
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker()
                            .getImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            image = pickedFile.path;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: image.isEmpty
                            ? Icon(Icons.add_a_photo,
                                color: Colors.grey, size: 50)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child:
                                    Image.file(File(image), fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (isLoading)
                CircularProgressIndicator()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      child: Text('Guardar'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _registerService();
                        }
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
