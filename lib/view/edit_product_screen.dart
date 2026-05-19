import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _urlController;
  late TextEditingController _discountController;
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Ciclisme',
    'Running',
    'Natació',
    'Fitness',
    'Muntanya',
    'Altres',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.nom);
    _descController = TextEditingController(text: widget.product.descripcio);
    _priceController = TextEditingController(
      text: widget.product.preu.toString(),
    );
    _urlController = TextEditingController(text: widget.product.url);
    _discountController = TextEditingController(
      text: widget.product.descompte.toString(),
    );
    _selectedCategory = widget.product.categoria.isNotEmpty
        ? widget.product.categoria
        : 'Altres';
  }

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
      setState(() => _isLoading = true);

      final productsViewModel = Provider.of<ProductsViewModel>(
        context,
        listen: false,
      );

      final productData = {
        'nom': _nameController.text,
        'descripcio': _descController.text,
        'preu': double.tryParse(_priceController.text) ?? 0.0,
        'url': _urlController.text,
        'categoria': _selectedCategory ?? 'Altres',
        'descompte': int.tryParse(_discountController.text) ?? 0,
      };

      try {
        await productsViewModel.updateProduct(widget.product.id, productData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.productUpdatedSuccess),
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
              content: Text('${l10n.errorUpdatingProduct}$e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
          l10n.editProduct,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.modifyProduct,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.updateProductInfo,
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
                          initialValue: _selectedCategory,
                          dropdownColor: colors.dialog,
                          style: GoogleFonts.outfit(color: colors.textPrimary),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: GoogleFonts.outfit(
                                  color: colors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
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
                  onPressed: _isLoading ? null : () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077C8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.saveChanges,
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
