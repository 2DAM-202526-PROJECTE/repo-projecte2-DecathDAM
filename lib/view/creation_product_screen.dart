import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/category_model.dart';
import 'package:decathdam/viewmodels/categories_viewmodel.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class CreationProductScreen extends StatefulWidget {
  const CreationProductScreen({super.key});

  @override
  State<CreationProductScreen> createState() => _CreationProductScreenState();
}

class _CreationProductScreenState extends State<CreationProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _urlController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      final productsViewModel = Provider.of<ProductsViewModel>(
        context,
        listen: false,
      );

      final productData = {
        'nom': _nameController.text,
        'descripcio': _descController.text,
        'preu': double.tryParse(_priceController.text) ?? 0.0,
        'url': _urlController.text,
        'categoriaId': _selectedCategoryId ?? '',
        'descompte': int.tryParse(_discountController.text) ?? 0,
      };

      try {
        await productsViewModel.addProduct(productData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.productCreatedSuccess),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.errorCreatingProduct}$e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final categoriesVM = Provider.of<CategoriesViewModel>(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.newProduct,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: StreamBuilder<List<Category>>(
        stream: categoriesVM.getCategoriesStream(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.productDetails,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.fillInfoToCreateProduct,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildLabel(l10n.productName, colors),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration(
                      hint: l10n.productNameExample,
                      icon: Icons.shopping_bag_outlined,
                      colors: colors,
                    ),
                    style: GoogleFonts.outfit(color: colors.textPrimary),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterProductName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildLabel(l10n.description, colors),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: _buildInputDecoration(
                      hint: l10n.descriptionHint,
                      icon: Icons.description_outlined,
                      colors: colors,
                    ).copyWith(alignLabelWithHint: true),
                    style: GoogleFonts.outfit(color: colors.textPrimary),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterDescription;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(l10n.priceLabel, colors),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: _buildInputDecoration(
                                hint: l10n.priceExample,
                                icon: Icons.euro,
                                colors: colors,
                              ),
                              style: GoogleFonts.outfit(color: colors.textPrimary),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.enterPrice;
                                }
                                if (double.tryParse(value) == null) {
                                  return l10n.invalidPrice;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(l10n.categoryTitle, colors),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedCategoryId,
                              dropdownColor: colors.dialog,
                              style: GoogleFonts.outfit(color: colors.textPrimary),
                              items: categories.map((Category cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id,
                                  child: Text(
                                    cat.nom,
                                    style: GoogleFonts.outfit(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategoryId = newValue;
                                });
                              },
                              decoration: _buildInputDecoration(
                                hint: l10n.chooseOne,
                                icon: Icons.category_outlined,
                                colors: colors,
                              ),
                              validator: (value) =>
                                  value == null ? l10n.chooseCategory : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildLabel(l10n.imageUrl, colors),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _urlController,
                    decoration: _buildInputDecoration(
                      hint: l10n.imageUrlHint,
                      icon: Icons.link,
                      colors: colors,
                    ),
                    style: GoogleFonts.outfit(color: colors.textPrimary),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterUrl;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('Descompte (%)', colors),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration(
                      hint: 'Ex: 10',
                      icon: Icons.local_offer_outlined,
                      colors: colors,
                    ),
                    style: GoogleFonts.outfit(color: colors.textPrimary),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final discount = int.tryParse(value);
                        if (discount == null || discount < 0 || discount > 100) {
                          return 'Introdueix un percentatge entre 0 i 100';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _submitForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077C8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.createProductButton,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text, AppColors colors) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: colors.textLabel,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required AppColors colors,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: colors.textHint),
      prefixIcon: Icon(icon, color: colors.iconSecondary),
      filled: true,
      fillColor: colors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0077C8), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
