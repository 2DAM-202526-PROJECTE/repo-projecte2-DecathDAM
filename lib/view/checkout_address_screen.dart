import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/services/payment_service.dart';
import 'package:decathdam/viewmodels/cart_viewmodel.dart';
import 'package:decathdam/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decathdam/services/email_service.dart';

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
  
  // Dades de facturació
  final TextEditingController _billingNameController = TextEditingController();
  final TextEditingController _billingNifController = TextEditingController();
  final TextEditingController _billingCountryController = TextEditingController();
  final TextEditingController _billingAddressController = TextEditingController();
  final TextEditingController _billingPostalCodeController = TextEditingController();
  final TextEditingController _billingCityController = TextEditingController();

  bool _billingSameAsShipping = true;
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

      _billingSameAsShipping = user.billingSameAsShipping;
      _billingNameController.text = user.billingNom.isNotEmpty ? user.billingNom : user.nom;
      _billingNifController.text = user.billingNif.isNotEmpty ? user.billingNif : user.dni;
      _billingAddressController.text = user.billingAdreca.isNotEmpty ? user.billingAdreca : user.adreca;
      _billingPostalCodeController.text = user.billingCodiPostal.isNotEmpty ? user.billingCodiPostal : user.codiPostal;
      _billingCityController.text = user.billingCiutat.isNotEmpty ? user.billingCiutat : user.ciutat;
      _billingCountryController.text = user.billingPais.isNotEmpty ? user.billingPais : 'Espanya';
    } else {
      _billingCountryController.text = 'Espanya'; // Per defecte
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
    _billingNameController.dispose();
    _billingNifController.dispose();
    _billingCountryController.dispose();
    _billingAddressController.dispose();
    _billingPostalCodeController.dispose();
    _billingCityController.dispose();
    super.dispose();
  }

  Future<void> _processPayment(
    BuildContext context, {
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> billingDetails,
  }) async {
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

      if (!context.mounted) return;
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

        final docRef = await FirebaseFirestore.instance.collection('orders').add({
          'userId': user.id,
          'items': orderItems,
          'totalAmount': widget.cart.totalPrice,
          'date': FieldValue.serverTimestamp(),
          'status': 'pending',
          'shippingAddress': shippingAddress,
          'billingDetails': billingDetails,
        });

        // Enviar el correu electrònic a través de EmailJS
        EmailService.sendOrderConfirmation(
          toEmail: user.email,
          toName: user.nom,
          orderId: docRef.id,
          totalAmount: widget.cart.totalPrice,
          items: orderItems,
          shippingAddress: shippingAddress,
          billingDetails: billingDetails,
        ).catchError((err) {
          print("Error enviant correu de confirmació: $err");
          return false;
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

    final bName = _billingSameAsShipping ? name : _billingNameController.text.trim();
    final bNif = _billingSameAsShipping ? '' : _billingNifController.text.trim();
    final bAddress = _billingSameAsShipping ? address : _billingAddressController.text.trim();
    final bPostalCode = _billingSameAsShipping ? postalCode : _billingPostalCodeController.text.trim();
    final bCity = _billingSameAsShipping ? city : _billingCityController.text.trim();
    final bCountry = _billingSameAsShipping ? country : _billingCountryController.text.trim();

    if (!_billingSameAsShipping) {
      if (bName.isEmpty || bAddress.isEmpty || bPostalCode.isEmpty || bCity.isEmpty || bCountry.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.fillAllFields)),
        );
        return;
      }
    }

    final shippingMap = {
      'name': name,
      'phone': phone,
      'address': address,
      'postalCode': postalCode,
      'city': city,
      'country': country,
    };

    final billingMap = {
      'name': bName,
      'nif': bNif,
      'address': bAddress,
      'postalCode': bPostalCode,
      'city': bCity,
      'country': bCountry,
      'sameAsShipping': _billingSameAsShipping,
    };

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
          billingNom: bName,
          billingNif: bNif,
          billingAdreca: bAddress,
          billingCodiPostal: bPostalCode,
          billingCiutat: bCity,
          billingPais: bCountry,
          billingSameAsShipping: _billingSameAsShipping,
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
    await _processPayment(
      context,
      shippingAddress: shippingMap,
      billingDetails: billingMap,
    );
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
                
                const Divider(height: 32),
                
                // Opció d'adreça de facturació igual a la d'enviament
                CheckboxListTile(
                  title: Text(
                    l10n.billingSameAsShipping,
                    style: TextStyle(color: colors.textPrimary, fontSize: 16),
                  ),
                  value: _billingSameAsShipping,
                  onChanged: (val) {
                    setState(() {
                      _billingSameAsShipping = val ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: colors.accentBlue,
                ),
                
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        l10n.billingDataTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(colors, l10n.billingFullName, _billingNameController),
                      _buildTextField(colors, l10n.billingNif, _billingNifController),
                      _buildTextField(colors, l10n.billingCountry, _billingCountryController),
                      _buildTextField(colors, l10n.billingAddress, _billingAddressController),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(colors, l10n.billingPostalCode, _billingPostalCodeController, type: TextInputType.number),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: _buildTextField(colors, l10n.billingCity, _billingCityController),
                          ),
                        ],
                      ),
                    ],
                  ),
                  crossFadeState: _billingSameAsShipping ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                ),

                const Divider(height: 32),
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
