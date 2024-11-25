import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    Key? key,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.clientTime,
    required this.clientDate,
    required this.totalPayment,
    required this.userName,
    required this.userLocation,
    required this.userDetails,
    required this.image,
    required this.onRemove,
  }) : super(key: key);

  final String clientName, clientEmail, clientPhone, clientTime, clientDate, totalPayment;
  final String userName, userLocation, userDetails, image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final DateTime parsedDate = DateTime.parse(clientDate);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity, // Make the card take the full width
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10), // Added padding around the image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Make the image have rounded corners on all sides
                child: CachedNetworkImage(
                  imageUrl: image.isNotEmpty
                      ? '${dotenv.env['API_BASE_URL']}/$image'
                      : 'assets/images/default_image.png',
                  fit: BoxFit.cover,
                  width: 100, // Adjusted width of the image
                  height: 100, // Adjusted height of the image
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10), // Adjusted padding to make card more compact
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18, // Adjusted font size to make card more compact
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15), // Adjusted spacing to make card more compact
                    const SizedBox(height: 5), // Adjusted spacing to make card more compact
                    ElevatedButton(
                      onPressed: () => _showDetails(context, formattedDate),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Detalles'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, String formattedDate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow(Icons.phone, 'Teléfono', _formatPhoneNumber(clientPhone)),
              _buildInfoRow(Icons.calendar_today, 'Fecha', formattedDate),
              _buildInfoRow(Icons.access_time, 'Hora', _formatTimeTo12Hour(clientTime)),
              _buildInfoRow(Icons.attach_money, 'Pagado', totalPayment),
              _buildInfoRow(Icons.location_on, 'Ubicación', userLocation), // Agregar esta línea
            ],
          ),
        );
      },
    );
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 10) {
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6, 10)}';
    }
    return phoneNumber;
  }

  String _formatTimeTo12Hour(String time) {
    final DateFormat inputFormat = DateFormat('HH:mm');
    final DateFormat outputFormat = DateFormat('hh:mm a');
    final DateTime dateTime = inputFormat.parse(time);
    return outputFormat.format(dateTime);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Aumenta el espaciado vertical
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28), // Ajusta el tamaño del icono
          const SizedBox(width: 15), // Aumenta el espaciado horizontal
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18, // Ajusta el tamaño de la fuente
                fontWeight: FontWeight.w600, // Ajusta el estilo de la fuente
              ),
            ),
          ),
        ],
      ),
    );
  }
}