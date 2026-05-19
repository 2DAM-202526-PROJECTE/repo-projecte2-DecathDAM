import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (authVM.currentUserModel != null) {
        final user = authVM.currentUserModel!;
        _nameController.text = user.nom;
        _emailController.text = user.email;
        _addressController.text = user.adreca;
        _phoneController.text = user.telefon;
        _dniController.text = user.dni;
        _birthDateController.text = user.dataNaixement;
        _genderController.text = user.genere;
        _postalCodeController.text = user.codiPostal;
        _cityController.text = user.ciutat;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _dniController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(BuildContext context, AuthViewModel authVM) async {
    final l10n = AppLocalizations.of(context)!;

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nameCannotBeEmpty)),
      );
      return;
    }

    final success = await authVM.updateProfile(
      nom: newName,
      adreca: _addressController.text.trim(),
      telefon: _phoneController.text.trim(),
      dni: _dniController.text.trim(),
      dataNaixement: _birthDateController.text.trim(),
      genere: _genderController.text.trim(),
      codiPostal: _postalCodeController.text.trim(),
      ciutat: _cityController.text.trim(),
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.infoUpdated),
          backgroundColor: Colors.green.shade600,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? l10n.errorUpdating),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.myInformation,
          style:
              TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: authVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.personalData,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: l10n.fullName,
                    controller: _nameController,
                    colors: colors,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: l10n.email,
                    controller: _emailController,
                    colors: colors,
                    icon: Icons.email,
                    readOnly: true,
                    helpText: l10n.emailCannotBeModified,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: l10n.dni,
                    controller: _dniController,
                    colors: colors,
                    icon: Icons.badge,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: l10n.phone,
                    controller: _phoneController,
                    colors: colors,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: l10n.birthDate,
                    controller: _birthDateController,
                    colors: colors,
                    icon: Icons.cake,
                    hintText: l10n.dateFormat,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: l10n.gender,
                    controller: _genderController,
                    colors: colors,
                    icon: Icons.people,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.shippingAddress,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: l10n.address,
                    controller: _addressController,
                    colors: colors,
                    icon: Icons.home,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          label: l10n.postalCode,
                          controller: _postalCodeController,
                          colors: colors,
                          icon: Icons.mark_as_unread,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          label: l10n.city,
                          controller: _cityController,
                          colors: colors,
                          icon: Icons.location_city,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _saveChanges(context, authVM),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accentBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        l10n.saveChanges,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required AppColors colors,
    required IconData icon,
    bool readOnly = false,
    String? helpText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: TextStyle(
              color: readOnly ? colors.textSecondary : colors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.5)),
              prefixIcon: Icon(icon, color: colors.accentBlue),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
        if (helpText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: colors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  helpText,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }
}
