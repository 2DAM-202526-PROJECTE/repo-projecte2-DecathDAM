import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final DateTime date;
  final String status;
  final Map<String, dynamic>? shippingAddress;
  final Map<String, dynamic>? billingDetails;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.date,
    required this.status,
    this.shippingAddress,
    this.billingDetails,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'completed',
      shippingAddress: data['shippingAddress'] != null ? Map<String, dynamic>.from(data['shippingAddress']) : null,
      billingDetails: data['billingDetails'] != null ? Map<String, dynamic>.from(data['billingDetails']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'totalAmount': totalAmount,
      'date': Timestamp.fromDate(date),
      'status': status,
      'shippingAddress': shippingAddress,
      'billingDetails': billingDetails,
    };
  }
}
