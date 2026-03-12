import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';


class PaymentService {
  // ATENCIÓ: Les claus han estat mogudes a lib/services/secrets.dart per seguretat.
  static const String publishableKey = StripeSecrets.publishableKey;
  static const String secretKey = StripeSecrets.secretKey;

  static Future<void> init() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  // Mètode realista cridant al backend (Cloud Functions)
  static Future<Map<String, dynamic>> createPaymentIntent(
    int amount,
    String currency,
  ) async {
    try {
      // Nota: Aquí aniria la URL de la teva Firebase Cloud Function
      // Per exemple: https://us-central1-decathdam.cloudfunctions.net/createPaymentIntent
      final url = Uri.parse(
        'https://us-central1-decathdam.cloudfunctions.net/createPaymentIntent',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'currency': currency}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error al Backend: $e');
      rethrow;
    }
  }

  // Mètode simplificat per a proves (Simula el backend cridant directament a Stripe)
  // ÚTIL si l'estudiant no vol configurar Cloud Functions encara.
  static Future<Map<String, dynamic>> createPaymentIntentDirect(
    int amount,
    String currency,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error direct Stripe: $e');
      rethrow;
    }
  }

  static Future<void> makePayment(int amount, String currency) async {
    try {
      // 1. Crear el PaymentIntent al backend (o directament per a proves ràpides)
      // Per defecte usem el mètode directe per facilitar la prova de l'usuari
      final paymentIntentData = await createPaymentIntentDirect(
        amount,
        currency,
      );

      // 2. Inicialitzar el Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'DecathDAM Store',
        ),
      );

      // 3. Mostrar el Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      print('Pagament completat amb èxit!');
    } catch (e) {
      if (e is StripeException) {
        print('Error de Stripe: ${e.error.localizedMessage}');
      } else {
        print('Error inesperat: $e');
      }
      rethrow;
    }
  }
}
