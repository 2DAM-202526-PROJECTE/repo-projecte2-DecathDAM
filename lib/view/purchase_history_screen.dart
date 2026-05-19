import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/l10n/app_localizations.dart';
import 'package:decathdam/models/order_model.dart';
import 'package:decathdam/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final user = authVM.currentUserModel;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.purchaseHistory)),
        body: const Center(child: Text('Usuari no autenticat')),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.purchaseHistory,
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.id)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: colors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noPurchases,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs.map((doc) {
            return OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, order, colors, l10n);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, AppColors colors, AppLocalizations l10n) {
    return Card(
      color: colors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.orderNumber(order.id.substring(0, 8)),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(order.date),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: colors.divider),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item['productImageUrl'] != null && item['productImageUrl'].toString().isNotEmpty
                            ? Image.network(
                                item['productImageUrl'],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                color: colors.imagePlaceholder,
                                child: Icon(Icons.image, size: 20, color: colors.textSecondary),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['productName'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              '${item['quantity']} x ${item['price']} €',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(item['quantity'] * item['price']).toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Divider(color: colors.divider),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  '${order.totalAmount.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colors.accentBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
