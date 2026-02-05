import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/view/edit_product_screen.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsViewModel = Provider.of<ProductsViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Administrar Productes',
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
      body: StreamBuilder<List<Product>>(
        stream: productsViewModel.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.outfit(color: Colors.red),
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hi ha productes',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(context, product, productsViewModel);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    ProductsViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: product.url.isNotEmpty
                    ? Image.network(
                        product.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                          );
                        },
                      )
                    : Icon(Icons.image, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(width: 16),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nom,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.categoria,
                    style: GoogleFonts.outfit(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.preu.toStringAsFixed(2)} €',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0077C8),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProductScreen(product: product),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.blue[700],
                  tooltip: 'Editar',
                ),
                IconButton(
                  onPressed: () =>
                      _showDeleteConfirmation(context, product, viewModel),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Product product,
    ProductsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Eliminar producte?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Estàs segur que vols eliminar "${product.nom}"? Aquesta acció no es pot desfer.',
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel·lar',
                style: GoogleFonts.outfit(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await viewModel.deleteProduct(product.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Producte eliminat: ${product.nom}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error en eliminar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Eliminar',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
