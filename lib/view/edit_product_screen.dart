import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
    super.dispose();
  }

  Future<void> _submitForm() async {
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
        'imatge': widget.product.imatge,
      };

      try {
        await productsViewModel.updateProduct(widget.product.id, productData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producte actualitzat correctament'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error en actualitzar: $e'),
              backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Editar Producte',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Modificar Producte',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Actualitza la informació del producte.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel('Nom del Producte'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  hint: 'Ex: Bambes de Running Kalenji',
                  icon: Icons.shopping_bag_outlined,
                ),
                style: GoogleFonts.outfit(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Si us plau, introdueix un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _buildLabel('Descripció'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  hint: 'Descriu les característiques tècniques...',
                  icon: Icons.description_outlined,
                ).copyWith(alignLabelWithHint: true),
                style: GoogleFonts.outfit(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Si us plau, introdueix una descripció';
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
                        _buildLabel('Preu (€)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _buildInputDecoration(
                            hint: '0.00',
                            icon: Icons.euro,
                          ),
                          style: GoogleFonts.outfit(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Introdueix un preu';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Preu no vàlid';
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
                        _buildLabel('Categoria'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: GoogleFonts.outfit(),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          decoration: _buildInputDecoration(
                            hint: 'Tria una',
                            icon: Icons.category_outlined,
                          ),
                          validator: (value) =>
                              value == null ? 'Tria una categoria' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel('URL de la Imatge'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _urlController,
                decoration: _buildInputDecoration(
                  hint: 'https://exemple.com/imatge.jpg',
                  icon: Icons.link,
                ),
                style: GoogleFonts.outfit(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Si us plau, introdueix una URL';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 48),

              // Action Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
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
                          'Desar Canvis',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.grey[800],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0077C8), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
