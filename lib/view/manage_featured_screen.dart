import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class ManageFeaturedScreen extends StatelessWidget {
  const ManageFeaturedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final productsViewModel = Provider.of<ProductsViewModel>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.featuredProducts,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.icon),
          onPressed: () => Navigator.pop(context),
        ),
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
                style: TextStyle(color: colors.textPrimary),
              ),
            );
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(
              child: Text(
                l10n.noProducts,
                style: TextStyle(color: colors.textSecondary),
              ),
            );
          }

          final featuredCount = products.where((p) => p.destacat).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.selectFeaturedProductsText(featuredCount),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      color: colors.card,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: product.url.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.url,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              )
                            : const Icon(Icons.image),
                        title: Text(
                          product.nom,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${product.preu.toStringAsFixed(2)} €',
                          style: TextStyle(color: colors.accentBlue),
                        ),
                        trailing: Switch(
                          value: product.destacat,
                          activeThumbColor: colors.accentBlue,
                          onChanged: (value) async {
                            if (value && featuredCount >= 4) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.maxFeaturedProductsError,
                                  ),
                                ),
                              );
                              return;
                            }

                            // Update the product in Firestore
                            try {
                              await productsViewModel.updateProduct(
                                product.id,
                                {'destacat': value},
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
