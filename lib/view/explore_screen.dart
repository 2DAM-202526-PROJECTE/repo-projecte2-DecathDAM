import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/viewmodels/favorites_viewmodel.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/view/product_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late final Stream<List<Product>> _productsStream;
  bool _streamInitialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      final priceStr1 = product.preu.toString();
      final priceStr2 = product.preu.toStringAsFixed(2);
      final priceStr3 = priceStr1.replaceAll('.', ',');
      final priceStr4 = priceStr2.replaceAll('.', ',');

      return product.nom.toLowerCase().contains(query) ||
          product.descripcio.toLowerCase().contains(query) ||
          product.categoria.toLowerCase().contains(query) ||
          priceStr1.contains(query) ||
          priceStr2.contains(query) ||
          priceStr3.contains(query) ||
          priceStr4.contains(query);
    }).toList();
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

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: TextStyle(color: colors.textPrimary),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cerca productes...',
              hintStyle: TextStyle(color: colors.textHint),
              prefixIcon: Icon(Icons.search, color: colors.iconSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: colors.iconSecondary),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
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
                final products = _filterProducts(allProducts);

                if (allProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'No hi ha productes',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  );
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No s\'han trobat resultats per "$_searchQuery"',
                          style: TextStyle(color: colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
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
                                    child: Hero(
                                      tag: 'product_image_${product.id}',
                                      child: product.url.isNotEmpty
                                          ? Image.network(
                                              product.url,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  favoritesViewModel.toggleFavorite(product.id);
                                },
                                child: Icon(
                                  favoritesViewModel.isFavorite(product.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      favoritesViewModel.isFavorite(product.id)
                                      ? Colors.red
                                      : colors.textSecondary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
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
