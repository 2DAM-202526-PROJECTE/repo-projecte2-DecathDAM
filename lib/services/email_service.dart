import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class EmailService {
  static Future<bool> sendOrderConfirmation({
    required String toEmail,
    required String toName,
    required String orderId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    // Adaptar la llista de productes a l'estructura de bucle {{#orders}} de la teva plantilla d'EmailJS
    final List<Map<String, dynamic>> ordersList = items.map((item) {
      return {
        'to_name':
            item['productName'] ??
            '', // EmailJS utilitza 'to_name' per defecte en aquest camp a la plantilla
        'units': item['quantity'] ?? 1,
        'price': (item['price'] ?? 0.0).toStringAsFixed(2),
        'image': item['productImageUrl'] ?? '', // URL de la imatge del producte
      };
    }).toList();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': EmailJSSecrets.serviceId,
          'template_id': EmailJSSecrets.templateId,
          'user_id': EmailJSSecrets.publicKey,
          'template_params': {
            'to_email': toEmail,
            'order_id': orderId,
            'total_amount': totalAmount.toStringAsFixed(2),
            'cost': {'shipping': '0.00', 'tax': '0.00'},
            'orders': ordersList,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Email enviat amb èxit per EmailJS!');
        return true;
      } else {
        print('Error de EmailJS: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepció en enviar el correu: $e');
      return false;
    }
  }
}
