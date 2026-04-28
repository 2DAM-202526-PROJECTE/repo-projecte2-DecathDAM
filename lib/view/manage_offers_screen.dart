import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageOffersScreen extends StatelessWidget {
  const ManageOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final productsViewModel = Provider.of<ProductsViewModel>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Gestionar Ofertes',
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
                'No hi ha productes',
                style: TextStyle(color: colors.textSecondary),
              ),
            );
          }

          final offersCount = products.where((p) => p.descompte > 0).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Selecciona fins a 4 productes en oferta i el seu percentatge. Seleccionats: $offersCount/4',
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final bool isOffer = product.descompte > 0;

                    return Card(
                      color: colors.card,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: product.url.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.url,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product.preu.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  decoration: isOffer
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              if (isOffer)
                                Text(
                                  '${(product.preu * (1 - product.descompte / 100)).toStringAsFixed(2)} € (-${product.descompte}%)',
                                  style: TextStyle(
                                    color: colors.accentBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isOffer)
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showDiscountDialog(
                                      context, product, productsViewModel),
                                ),
                              Switch(
                                value: isOffer,
                                activeThumbColor: colors.accentBlue,
                                onChanged: (value) async {
                                  if (value) {
                                    if (offersCount >= 4) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Només pots tenir un màxim de 4 ofertes.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    // Show dialog to set discount when enabling
                                    _showDiscountDialog(
                                        context, product, productsViewModel);
                                  } else {
                                    // Disable offer
                                    try {
                                      await productsViewModel.updateProduct(
                                        product.id,
                                        {'descompte': 0},
                                      );
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
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

  void _showDiscountDialog(BuildContext context, Product product,
      ProductsViewModel productsViewModel) {
    final TextEditingController controller = TextEditingController(
        text: product.descompte > 0 ? product.descompte.toString() : '10');
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.dialog,
        title: Text(
          'Percentatge de descompte',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ex: 10',
            hintStyle: TextStyle(color: colors.textHint),
            suffixText: '%',
            suffixStyle: TextStyle(color: colors.textPrimary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final int? discount = int.tryParse(controller.text);
              if (discount == null || discount <= 0 || discount > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Introdueix un percentatge vàlid (1-100)'),
                  ),
                );
                return;
              }

              Navigator.pop(context);
              try {
                await productsViewModel.updateProduct(
                  product.id,
                  {'descompte': discount},
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Desar'),
          ),
        ],
      ),
    );
  }
}
