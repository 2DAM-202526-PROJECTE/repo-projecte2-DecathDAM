import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/services/payment_service.dart';
import 'package:decathdam/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  // Dades inventades per als plans
  final List<Map<String, dynamic>> availablePlans = [
    {
      'title': 'Pla Premium Anual',
      'price': 9999, // en cèntims
      'priceLabel': '99.99€',
    },
    {
      'title': 'Pla Bàsic Mensual',
      'price': 999,
      'priceLabel': '9.99€',
    },
    {
      'title': 'DecathDAM Plus',
      'price': 1999,
      'priceLabel': '19.99€',
    },
  ];

  Future<void> _handleSubscription(BuildContext context, Map<String, dynamic> plan, AuthViewModel authVM) async {
    final currentUser = authVM.currentUserModel;
    if (currentUser == null) return;

    // Comprovar si ja té una subscripció activa
    if (currentUser.subscripcio != 'Sense subscripció' && currentUser.subscripcio != '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ja tens una subscripció activa. No pots fer un altre pagament.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      // Intentar fer el pagament amb Stripe
      await PaymentService.makePayment(plan['price'], 'EUR');
      
      // Si el pagament funciona, actualitzar el model de l'usuari
      final success = await authVM.updateSubscription(plan['title']);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subscripció ${plan['title']} activada amb èxit!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error en guardar la subscripció.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el pagament: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final currentSub = authVM.currentUserModel?.subscripcio ?? 'Sense subscripció';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Les meves subscripcions',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscripció Actual
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: colors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El teu pla actual:',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentSub.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: currentSub == 'Sense subscripció' ? colors.textPrimary : Colors.purpleAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Plans disponibles:',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: availablePlans.length,
              itemBuilder: (context, index) {
                final plan = availablePlans[index];
                final isCurrentPlan = currentSub == plan['title'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isCurrentPlan ? Colors.purpleAccent.withOpacity(0.1) : colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrentPlan ? Colors.purpleAccent : colors.divider,
                      width: isCurrentPlan ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan['title']!,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            plan['priceLabel']!,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isCurrentPlan
                              ? null // Ja el té
                              : () => _handleSubscription(context, plan, authVM),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrentPlan ? Colors.grey : colors.accentBlue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isCurrentPlan ? 'Pla Actual' : 'Subscriure\'s',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
