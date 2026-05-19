import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/services/payment_service.dart';
import 'package:decathdam/viewmodels/cart_viewmodel.dart';
import 'package:decathdam/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutAddressScreen extends StatefulWidget {
  final CartViewModel cart;

  const CheckoutAddressScreen({super.key, required this.cart});

  @override
  State<CheckoutAddressScreen> createState() => _CheckoutAddressScreenState();
}

class _CheckoutAddressScreenState extends State<CheckoutAddressScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  
  bool _saveAddress = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (authVM.currentUserModel != null) {
      final user = authVM.currentUserModel!;
      _nameController.text = user.nom;
      _phoneController.text = user.telefon;
      _addressController.text = user.adreca;
      _postalCodeController.text = user.codiPostal;
      _cityController.text = user.ciutat;
      _countryController.text = 'Espanya'; // Per defecte
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _processPayment(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final amountInCents = (widget.cart.totalPrice * 100).toInt();
      await PaymentService.makePayment(amountInCents, 'eur');

      if (context.mounted) Navigator.pop(context); // Tancar dialog de càrrega

      // Desar l'historial de compres
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final user = authVM.currentUserModel;
      if (user != null) {
        final orderItems = widget.cart.items.map((item) => {
          'productId': item.product.id,
          'productName': item.product.nom,
          'quantity': item.quantity,
          'price': item.product.preu,
          'productImageUrl': item.product.url,
        }).toList();

        await FirebaseFirestore.instance.collection('orders').add({
          'userId': user.id,
          'items': orderItems,
          'totalAmount': widget.cart.totalPrice,
          'date': FieldValue.serverTimestamp(),
          'status': 'completed',
        });
      }

      widget.cart.clearCart();

      if (context.mounted) {
        Navigator.pop(context); // Tancar la pantalla de checkout
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.paymentSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Tancar dialog de càrrega
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.paymentError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmAndPay() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final postalCode = _postalCodeController.text.trim();
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();

    if (name.isEmpty || address.isEmpty || postalCode.isEmpty || city.isEmpty || country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillAllFields)),
      );
      return;
    }

    if (_saveAddress) {
      setState(() { _isLoading = true; });
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final user = authVM.currentUserModel;
      if (user != null) {
        final success = await authVM.updateProfile(
          nom: name,
          adreca: address,
          telefon: phone,
          dni: user.dni,
          dataNaixement: user.dataNaixement,
          genere: user.genere,
          codiPostal: postalCode,
          ciutat: city,
        );
        if (!success && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authVM.errorMessage ?? AppLocalizations.of(context)!.errorSavingAddress),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      if (mounted) setState(() { _isLoading = false; });
    }

    if (!mounted) return;
    await _processPayment(context);
  }

  Widget _buildTextField(AppColors colors, String label, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: colors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.accentBlue),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.shippingDataTitle,
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.contactInfo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(colors, l10n.fullName, _nameController),
                _buildTextField(colors, l10n.phone, _phoneController, type: TextInputType.phone),
                
                const SizedBox(height: 24),
                Text(
                  l10n.shippingAddress,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(colors, l10n.country, _countryController),
                _buildTextField(colors, l10n.address, _addressController),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(colors, l10n.postalCode, _postalCodeController, type: TextInputType.number),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildTextField(colors, l10n.city, _cityController),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: Text(
                    l10n.saveDataForFuture,
                    style: TextStyle(color: colors.textPrimary, fontSize: 16),
                  ),
                  value: _saveAddress,
                  onChanged: (val) {
                    setState(() {
                      _saveAddress = val ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: colors.accentBlue,
                ),
                const SizedBox(height: 100), // Espai pel botó final
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmAndPay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accentBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            '${l10n.pay} ${widget.cart.totalPrice.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
