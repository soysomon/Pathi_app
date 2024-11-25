import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../screens/home/components/top_services.dart';

class ReservationDialog extends StatefulWidget {
  final int destinationId;

  const ReservationDialog({Key? key, required this.destinationId})
      : super(key: key);

  @override
  _ReservationDialogState createState() => _ReservationDialogState();
}

class _ReservationDialogState extends State<ReservationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool isLoading = false;
  List<Service> selectedServices = [];
  List<Service> destinationServices = [];
  double totalAmount = 0.0;
  bool resultAlreadySent = false;
  int? reservationId; // Declara reservationId como una variable de instancia

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchServices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token no disponible, inicia sesión nuevamente')),
      );
      return;
    }

    try {
      final uri = Uri.parse('${dotenv.env['API_BASE_URL']}/empresa/${widget.destinationId}/servicios');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          destinationServices = data.map((service) => Service.fromJson(service)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener los servicios')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión al servidor')),
      );
    }
  }

  void _calculateTotalAmount() {
    totalAmount =
        selectedServices.fold(0, (sum, service) => sum + service.price);
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token no disponible, inicia sesión nuevamente')),
        );
        return;
      }

      // Primero, crea la reserva y obtén el reservationId
      final reservationResponse = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/reservas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'usuario_id': widget.destinationId,
          'telefono': _phoneController.text,
          'fecha': _dateController.text,
          'hora': _timeController.text,
          'detalles': 'Reserva para destino ${widget.destinationId}',
          'total_pagar': totalAmount,
        }),
      );

      if (reservationResponse.statusCode != 201) {
        print('Error al registrar la reserva: ${reservationResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la reserva: ${reservationResponse.body}')),
        );
        return;
      }

      final reservationData = json.decode(reservationResponse.body);
      reservationId = reservationData['reservaId']; // Asigna el reservationId

      // Solicitar el token del cliente desde el backend
      final clientTokenResponse = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/client_token'),
      );

      if (clientTokenResponse.statusCode == 200) {
        final clientToken = clientTokenResponse.body;

        // Inicia el flujo de pago
        var request = BraintreeDropInRequest(
          clientToken: clientToken,
          collectDeviceData: true,
          requestThreeDSecureVerification: true,
          amount: totalAmount.toString(),
          paypalRequest: BraintreePayPalRequest(
            amount: totalAmount.toString(),
            displayName: 'Reserva',
            currencyCode: 'USD',
          ),
          cardEnabled: true,
          googlePaymentRequest: BraintreeGooglePaymentRequest(
            totalPrice: totalAmount.toString(),
            currencyCode: 'USD',
            billingAddressRequired: false,
          ),
          venmoEnabled: true,
        );

        BraintreeDropInResult? result = await BraintreeDropIn.start(request);
        if (result != null) {
          final nonce = result.paymentMethodNonce.nonce;
          final response = await http.post(
            Uri.parse('${dotenv.env['API_BASE_URL']}/checkout'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'paymentMethodNonce': nonce,
              'amount': totalAmount.toString(),
              'reservationId': reservationId, // Incluye el reservationId
            }),
          );

          if (response.statusCode == 200) {
            final transactionData = json.decode(response.body);
            final transactionId = transactionData['transactionId'];

            // Actualiza la reserva con el transactionId
            final updateReservationResponse = await http.put(
              Uri.parse('${dotenv.env['API_BASE_URL']}/reservas/$reservationId'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode({
                'transaction_id': transactionId,
              }),
            );

            if (updateReservationResponse.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reserva registrada correctamente')),
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            } else {
              print('Error al actualizar la reserva: ${updateReservationResponse.body}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al actualizar la reserva: ${updateReservationResponse.body}')),
              );
            }
          } else {
            print('Error en la transacción: ${response.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error en la transacción: ${response.body}')),
            );
            // Elimina la reserva si la transacción falla
            await http.delete(
              Uri.parse('${dotenv.env['API_BASE_URL']}/reservas/$reservationId'),
              headers: {
                'Authorization': 'Bearer $token',
              },
            );
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('El flujo de pago fue cancelado')),
          );
          // Elimina la reserva si el flujo de pago es cancelado
          await http.delete(
            Uri.parse('${dotenv.env['API_BASE_URL']}/reservas/$reservationId'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          );
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener el token del cliente: ${clientTokenResponse.body}')),
        );
        // Elimina la reserva si no se puede obtener el token del cliente
        await http.delete(
          Uri.parse('${dotenv.env['API_BASE_URL']}/reservas/$reservationId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // Elimina la reserva en caso de excepción
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token != null) {
        await http.delete(
          Uri.parse('${dotenv.env['API_BASE_URL']}/reservas/$reservationId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      }
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showServiceSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Seleccionar Servicios',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: destinationServices.map((service) {
                final isSelected = selectedServices.contains(service);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedServices.remove(service);
                      } else {
                        selectedServices.add(service);
                      }
                      _calculateTotalAmount();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      service.title,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.blue : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Guardar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isFormValid() {
    return _phoneController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _timeController.text.isNotEmpty &&
        selectedServices.isNotEmpty;
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
                'Reservar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                onChanged: () => setState(() {}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: 'Fecha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor seleccione una fecha';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _timeController,
                          decoration: InputDecoration(
                            labelText: 'Hora',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor seleccione una hora';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _showServiceSelectionDialog,
                            child: Icon(Icons.add),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: selectedServices.isEmpty
                                  ? Text(
                                      'Seleccionar Servicios',
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  : Wrap(
                                      children: selectedServices.map((service) {
                                        return Chip(
                                          label: Text(service.title),
                                          onDeleted: () {
                                            setState(() {
                                              selectedServices.remove(service);
                                              _calculateTotalAmount();
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    IntlPhoneField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Número de Teléfono',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      initialCountryCode: 'DO',
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor ingrese su número de teléfono';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Total a Pagar: \$${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(height: 20),
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
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          _isFormValid() ? Colors.blue : Colors.grey,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('Reservar'),
                    onPressed: _isFormValid() && !isLoading
                        ? _submitReservation
                        : null,
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