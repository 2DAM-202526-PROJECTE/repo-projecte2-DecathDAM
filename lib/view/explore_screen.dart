import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsViewModel = Provider.of<ProductsViewModel>(context);
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextField(
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Cerca productes...',
              hintStyle: TextStyle(color: colors.textHint),
              prefixIcon: Icon(Icons.search, color: colors.iconSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1E88E5)),
              ),
              filled: true,
              fillColor: colors.inputFill,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: productsViewModel.getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  );
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No hi ha productes',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: colors.isDark ? 2 : 4,
                      color: colors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: product.url.isNotEmpty
                                  ? Image.network(
                                      product.url,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: colors.textSecondary,
                                          ),
                                    )
                                  : Container(
                                      color: colors.imagePlaceholder,
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.nom,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.preu.toStringAsFixed(2)} €',
                                  style: TextStyle(
                                    color: colors.accentBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
