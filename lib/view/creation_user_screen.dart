import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/user_model.dart';
import 'package:decathdam/viewmodels/users_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class CreationUserScreen extends StatefulWidget {
  const CreationUserScreen({super.key});

  @override
  State<CreationUserScreen> createState() => _CreationUserScreenState();
}

class _CreationUserScreenState extends State<CreationUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _adrecaController = TextEditingController();
  final _telefonController = TextEditingController();
  final _dniController = TextEditingController();
  final _dataNaixementController = TextEditingController();
  final _genereController = TextEditingController();
  final _codiPostalController = TextEditingController();
  final _ciutatController = TextEditingController();
  String _selectedRol = 'client';

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _adrecaController.dispose();
    _telefonController.dispose();
    _dniController.dispose();
    _dataNaixementController.dispose();
    _genereController.dispose();
    _codiPostalController.dispose();
    _ciutatController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateUser() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final usersVM = context.read<UsersViewModel>();
    
    try {
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporal
        nom: _nomController.text.trim(),
        email: _emailController.text.trim(),
        rol: _selectedRol,
        actiu: true,
        adreca: _adrecaController.text.trim(),
        telefon: _telefonController.text.trim(),
        dni: _dniController.text.trim(),
        dataNaixement: _dataNaixementController.text.trim(),
        genere: _genereController.text.trim(),
        codiPostal: _codiPostalController.text.trim(),
        ciutat: _ciutatController.text.trim(),
      );
      await usersVM.addUser(newUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.userCreatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorCreatingUser}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.createNewUser,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n.basicInfo, colors),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nomController,
                label: l10n.fullName,
                icon: Icons.person_outline,
                colors: colors,
                validator: (v) => v?.isEmpty ?? true ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: l10n.email,
                icon: Icons.email_outlined,
                colors: colors,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.isEmpty ?? true) return l10n.requiredField;
                  if (!v!.contains('@')) return l10n.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildRolPicker(colors, l10n),
              
              const SizedBox(height: 32),
              _buildSectionTitle(l10n.personalData, colors),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _dniController,
                label: l10n.dni,
                icon: Icons.badge_outlined,
                colors: colors,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telefonController,
                label: l10n.phone,
                icon: Icons.phone_outlined,
                colors: colors,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _dataNaixementController,
                      label: l10n.birthDate,
                      icon: Icons.cake_outlined,
                      colors: colors,
                      hintText: l10n.dateFormat,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _genereController,
                      label: l10n.gender,
                      icon: Icons.people_outline,
                      colors: colors,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionTitle(l10n.deliveryAddress, colors),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _adrecaController,
                label: l10n.addressLabel,
                icon: Icons.home_outlined,
                colors: colors,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _codiPostalController,
                      label: l10n.postalCode,
                      icon: Icons.mark_as_unread_outlined,
                      colors: colors,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _ciutatController,
                      label: l10n.city,
                      icon: Icons.location_city_outlined,
                      colors: colors,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleCreateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    l10n.createUserButton,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors colors) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppColors colors,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.outfit(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: colors.textSecondary),
        hintText: hintText,
        hintStyle: GoogleFonts.outfit(color: colors.textSecondary.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFFFF6D00), size: 22),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6D00), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  Widget _buildRolPicker(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.userRoleLabel,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRol,
              isExpanded: true,
              dropdownColor: colors.surface,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFFFF6D00)),
              style: GoogleFonts.outfit(color: colors.textPrimary),
              items: [
                DropdownMenuItem(value: 'client', child: Text(l10n.clientRole)),
                DropdownMenuItem(value: 'admin', child: Text(l10n.adminRole)),
              ],
              onChanged: (val) => setState(() => _selectedRol = val!),
            ),
          ),
        ),
      ],
    );
  }
}
