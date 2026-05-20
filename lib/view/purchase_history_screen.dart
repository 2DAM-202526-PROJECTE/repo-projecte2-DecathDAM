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
              return OrderCard(order: order, colors: colors, l10n: l10n);
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final OrderModel order;
  final AppColors colors;
  final AppLocalizations l10n;

  const OrderCard({
    super.key,
    required this.order,
    required this.colors,
    required this.l10n,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final colors = widget.colors;
    final l10n = widget.l10n;

    final hasAddressDetails = order.shippingAddress != null || order.billingDetails != null;

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
            _buildTrackingStepper(order.status),
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
            if (hasAddressDetails) ...[
              const SizedBox(height: 8),
              Divider(color: colors.divider),
              InkWell(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expanded ? l10n.hideOrderDetails : l10n.viewOrderDetails,
                        style: TextStyle(
                          color: colors.accentBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: colors.accentBlue,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.shippingAddress != null) ...[
                        Text(
                          l10n.shippingAddress,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.shippingAddress!['name'] ?? ''}\n'
                          '${l10n.phone}: ${order.shippingAddress!['phone'] ?? ''}\n'
                          '${order.shippingAddress!['address'] ?? ''}, ${order.shippingAddress!['postalCode'] ?? ''} ${order.shippingAddress!['city'] ?? ''}, ${order.shippingAddress!['country'] ?? ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (order.billingDetails != null) ...[
                        Text(
                          l10n.billingDataTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (order.billingDetails!['sameAsShipping'] == true)
                          Text(
                            l10n.billingSameAsShipping,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Text(
                            '${order.billingDetails!['name'] ?? ''}\n'
                            '${order.billingDetails!['nif'] != null && order.billingDetails!['nif'].toString().isNotEmpty ? "${l10n.billingNif}: ${order.billingDetails!['nif']}\n" : ""}'
                            '${order.billingDetails!['address'] ?? ''}, ${order.billingDetails!['postalCode'] ?? ''} ${order.billingDetails!['city'] ?? ''}, ${order.billingDetails!['country'] ?? ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStepper(String status) {
    int currentStep = 0;
    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
        currentStep = 0;
        break;
      case 'shipped':
        currentStep = 1;
        break;
      case 'in_delivery':
      case 'in_transit':
        currentStep = 2;
        break;
      case 'delivered':
      case 'completed':
        currentStep = 3;
        break;
      default:
        currentStep = 0;
    }

    final steps = [
      {'label': 'Rebuda', 'icon': Icons.receipt_long_rounded},
      {'label': 'Enviat', 'icon': Icons.local_shipping_rounded},
      {'label': 'En repartiment', 'icon': Icons.delivery_dining_rounded},
      {'label': 'Lliurat', 'icon': Icons.check_circle_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.colors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isActive = index <= currentStep;
              final isLast = index == steps.length - 1;
              final color = isActive ? widget.colors.accentBlue : widget.colors.textSecondary.withValues(alpha: 0.3);

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(step['icon'] as IconData, size: 20, color: color),
                          const SizedBox(height: 4),
                          Text(
                            step['label'] as String,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: color,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 15,
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: index < currentStep
                            ? widget.colors.accentBlue
                            : widget.colors.textSecondary.withValues(alpha: 0.2),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
