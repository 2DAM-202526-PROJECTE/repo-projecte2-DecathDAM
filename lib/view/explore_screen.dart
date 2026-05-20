import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/category_model.dart';
import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/viewmodels/categories_viewmodel.dart';
import 'package:decathdam/viewmodels/favorites_viewmodel.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/view/product_details_screen.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  List<String> _selectedCategoryIds = [];
  double _minPriceSelected = 0.0;
  double _maxPriceSelected = 1000.0;
  double _absoluteMaxPrice = 1000.0;
  String _sortBy = 'none';
  bool _pricesInitialized = false;

  late final Stream<List<Product>> _productsStream;
  bool _streamInitialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products, Map<String, String> categoryNames) {
    var filtered = products.where((product) {
      // 1. Text filter
      bool textMatch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final priceStr1 = product.preu.toString();
        final priceStr2 = product.preu.toStringAsFixed(2);
        final priceStr3 = priceStr1.replaceAll('.', ',');
        final priceStr4 = priceStr2.replaceAll('.', ',');
        final catName = (categoryNames[product.categoriaId] ?? '').toLowerCase();

        textMatch = product.nom.toLowerCase().contains(query) ||
            product.descripcio.toLowerCase().contains(query) ||
            catName.contains(query) ||
            priceStr1.contains(query) ||
            priceStr2.contains(query) ||
            priceStr3.contains(query) ||
            priceStr4.contains(query);
      }

      // 2. Category filter (by ID)
      bool categoryMatch = _selectedCategoryIds.isEmpty || 
          _selectedCategoryIds.contains(product.categoriaId);

      // 3. Price Filter
      bool priceMatch = product.preu >= _minPriceSelected && product.preu <= _maxPriceSelected;

      return textMatch && categoryMatch && priceMatch;
    }).toList();

    // Sorting
    if (_sortBy == 'price_asc') {
      filtered.sort((a, b) => a.preu.compareTo(b.preu));
    } else if (_sortBy == 'price_desc') {
      filtered.sort((a, b) => b.preu.compareTo(a.preu));
    }

    return filtered;
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
    final categoriesVM = Provider.of<CategoriesViewModel>(context);
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
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
          
          if (!_pricesInitialized && allProducts.isNotEmpty) {
            double maxFound = 0;
            for (var p in allProducts) {
              if (p.preu > maxFound) maxFound = p.preu;
            }
            Future.microtask(() {
              if (mounted) {
                setState(() {
                  _absoluteMaxPrice = maxFound > 0 ? maxFound : 1000.0;
                  _maxPriceSelected = _absoluteMaxPrice;
                  _pricesInitialized = true;
                });
              }
            });
          }

          // Construïm un mapa de categoriaId -> nom des del ViewModel
          return StreamBuilder<List<Category>>(
            stream: categoriesVM.getCategoriesStream(),
            builder: (context, catSnapshot) {
              final categories = catSnapshot.data ?? [];
              final Map<String, String> categoryNames = {
                for (var c in categories) c.id: c.nom
              };

              final products = _filterProducts(allProducts, categoryNames);

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: colors.textPrimary),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: l10n.searchProducts,
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.inputBorder),
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.tune, color: colors.iconSecondary),
                          onPressed: () {
                            _showAdvancedFiltersModal(context, categories);
                          },
                        ),
                        if (_selectedCategoryIds.isNotEmpty || _sortBy != 'none' || _minPriceSelected > 0 || _maxPriceSelected < _absoluteMaxPrice)
                           Positioned(
                             top: 10,
                             right: 12,
                             child: Container(
                               width: 8,
                               height: 8,
                               decoration: const BoxDecoration(
                                 color: Colors.redAccent,
                                 shape: BoxShape.circle,
                               ),
                             ),
                           ),
                      ]
                    )
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: () {
                  if (allProducts.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noProductsAvailable,
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
                            l10n.noResultsModifyFilters,
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
                                            fontSize: 14,
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
                }(),
              ),
            ],
            );
            },  // fi del builder del StreamBuilder<Category>
          );  // fi del StreamBuilder<Category>
        },  // fi del builder del StreamBuilder<Product>
      ),
    );
  }

  void _showAdvancedFiltersModal(BuildContext context, List<Category> allCategories) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Draft state per no alterar la pantalla abans de donar-li a APLICAR
    List<String> tempCategoryIds = List.from(_selectedCategoryIds);
    String tempSortBy = _sortBy;
    double tempMinPrice = _minPriceSelected;
    double tempMaxPrice = _maxPriceSelected;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colors.divider,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.advancedFilters,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                             setModalState(() {
                               tempCategoryIds.clear();
                                tempSortBy = 'none';
                                tempMinPrice = 0;
                                tempMaxPrice = _absoluteMaxPrice;
                             });
                          },
                          child: Text(l10n.clearAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // CATEGORIES
                    Text(
                      l10n.categories,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: allCategories.map((cat) {
                        final isSelected = tempCategoryIds.contains(cat.id);
                        return FilterChip(
                          label: Text(cat.nom),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : colors.textPrimary,
                          ),
                          selected: isSelected,
                          selectedColor: colors.accentBlue,
                          backgroundColor: colors.inputFill,
                          checkmarkColor: Colors.white,
                          showCheckmark: false,
                          onSelected: (bool selected) {
                            setModalState(() {
                              if (selected) {
                                tempCategoryIds.add(cat.id);
                              } else {
                                tempCategoryIds.remove(cat.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // SORT BY
                    Text(
                      l10n.sorting,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.defaultSort),
                          labelStyle: TextStyle(color: tempSortBy == 'none' ? Colors.white : colors.textPrimary),
                          selected: tempSortBy == 'none',
                          selectedColor: colors.accentBlue,
                          backgroundColor: colors.inputFill,
                          showCheckmark: false,
                          onSelected: (selected) {
                            if (selected) {
                               setModalState(() => tempSortBy = 'none');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text(l10n.lowestPrice),
                          labelStyle: TextStyle(color: tempSortBy == 'price_asc' ? Colors.white : colors.textPrimary),
                          selected: tempSortBy == 'price_asc',
                          selectedColor: colors.accentBlue,
                          backgroundColor: colors.inputFill,
                          showCheckmark: false,
                          onSelected: (selected) {
                            if (selected) {
                               setModalState(() => tempSortBy = 'price_asc');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text(l10n.highestPrice),
                          labelStyle: TextStyle(color: tempSortBy == 'price_desc' ? Colors.white : colors.textPrimary),
                          selected: tempSortBy == 'price_desc',
                          selectedColor: colors.accentBlue,
                          backgroundColor: colors.inputFill,
                          showCheckmark: false,
                          onSelected: (selected) {
                            if (selected) {
                               setModalState(() => tempSortBy = 'price_desc');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // PRICE RANGE
                    Text(
                      '${l10n.priceRange}: ${tempMinPrice.toStringAsFixed(0)}€ - ${tempMaxPrice.toStringAsFixed(0)}€',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: RangeValues(tempMinPrice, tempMaxPrice),
                      min: 0,
                      max: _absoluteMaxPrice > 0 ? _absoluteMaxPrice : 100,
                      divisions: _absoluteMaxPrice > 0 ? _absoluteMaxPrice.toInt() : 100,
                      activeColor: colors.accentBlue,
                      inactiveColor: colors.inputBorder,
                      labels: RangeLabels(
                        '${tempMinPrice.toStringAsFixed(0)}€',
                        '${tempMaxPrice.toStringAsFixed(0)}€',
                      ),
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          tempMinPrice = values.start;
                          tempMaxPrice = values.end;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Aplica l'estat draft a l'estat arrel i tanca la pantalla
                          setState(() {
                            _selectedCategoryIds = List.from(tempCategoryIds);
                            _sortBy = tempSortBy;
                            _minPriceSelected = tempMinPrice;
                            _maxPriceSelected = tempMaxPrice;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.accentBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(l10n.applyFilters, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
