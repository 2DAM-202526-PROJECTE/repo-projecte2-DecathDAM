import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/viewmodels/favorites_viewmodel.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  /// IDs marcats per eliminar (pendents fins que l'usuari canviï de pàgina)
  final Set<String> _pendingRemovals = {};
  late final Stream<List<Product>> _productsStream;
  bool _streamInitialized = false;

  /// Aplica les eliminacions pendents (cridat des de MainScreen quan es canvia de pestanya)
  void applyPendingRemovals() {
    if (_pendingRemovals.isEmpty) return;
    final favoritesViewModel = Provider.of<FavoritesViewModel>(
      context,
      listen: false,
    );
    for (final id in Set<String>.from(_pendingRemovals)) {
      favoritesViewModel.toggleFavorite(id);
    }
    _pendingRemovals.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_streamInitialized) {
      _productsStream = Provider.of<ProductsViewModel>(
        context,
        listen: false,
      ).getProductsStream();
      _streamInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesViewModel = Provider.of<FavoritesViewModel>(context);
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<Product>>(
      stream: _productsStream,
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

        final allProducts = snapshot.data ?? [];
        final favorites = allProducts
            .where((p) => favoritesViewModel.isFavorite(p.id))
            .toList();

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.yourFavorites,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noSavedProducts,
                  style: TextStyle(fontSize: 16, color: colors.textSecondary),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final product = favorites[index];
              final isPendingRemoval = _pendingRemovals.contains(product.id);

              return Card(
                elevation: colors.isDark ? 2 : 4,
                color: colors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Column(
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
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isPendingRemoval) {
                              // L'usuari ha canviat d'opinió, torna a marcar-lo com a favorit
                              _pendingRemovals.remove(product.id);
                            } else {
                              // Marca per eliminar quan canviï de pàgina
                              _pendingRemovals.add(product.id);
                            }
                          });
                        },
                        child: Icon(
                          isPendingRemoval
                              ? Icons.favorite_border
                              : Icons.favorite,
                          color: isPendingRemoval
                              ? colors.textSecondary
                              : Colors.red,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
