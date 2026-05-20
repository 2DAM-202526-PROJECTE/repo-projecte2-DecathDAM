import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/category_model.dart';
import 'package:decathdam/viewmodels/categories_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late Stream<List<Category>> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream = Provider.of<CategoriesViewModel>(
      context,
      listen: false,
    ).getCategoriesStream();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.manageCategories,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, colors, l10n),
        backgroundColor: const Color(0xFF0077C8),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.newCategory,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<Category>>(
        stream: _categoriesStream,
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

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noCategories,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.createFirstCategory,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) =>
                _onReorder(context, categories, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(
                key: ValueKey(category.id),
                context: context,
                category: category,
                colors: colors,
                l10n: l10n,
                index: index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required Key key,
    required BuildContext context,
    required Category category,
    required AppColors colors,
    required AppLocalizations l10n,
    required int index,
  }) {
    final categoriesVM =
        Provider.of<CategoriesViewModel>(context, listen: false);

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icona de reordenació
            Icon(
              Icons.drag_handle_rounded,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 12),
            // Icona de categoria amb gradient
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0077C8), Color(0xFF00A3E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.category_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Nom i info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.nom,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FutureBuilder<int>(
                    future:
                        categoriesVM.getProductsCountByCategory(category.id),
                    builder: (context, snap) {
                      final count = snap.data ?? 0;
                      return Text(
                        '$count ${l10n.products.toLowerCase()}',
                        style: GoogleFonts.outfit(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Botons d'acció
            IconButton(
              onPressed: () => _showCategoryDialog(
                context,
                colors,
                l10n,
                category: category,
              ),
              icon: const Icon(Icons.edit_outlined),
              color: colors.accentBlue,
              tooltip: l10n.edit,
            ),
            IconButton(
              onPressed: () => _showDeleteConfirmation(
                context,
                category,
                colors,
                l10n,
              ),
              icon: const Icon(Icons.delete_outline),
              color: Colors.red[400],
              tooltip: l10n.delete,
            ),
          ],
        ),
      ),
    );
  }

  /// Diàleg per crear o editar una categoria.
  void _showCategoryDialog(
    BuildContext context,
    AppColors colors,
    AppLocalizations l10n, {
    Category? category,
  }) {
    final isEditing = category != null;
    final nameController = TextEditingController(
      text: isEditing ? category.nom : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.dialog,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isEditing ? l10n.editCategory : l10n.newCategory,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                labelStyle: GoogleFonts.outfit(color: colors.textSecondary),
                prefixIcon:
                    Icon(Icons.category_outlined, color: colors.iconSecondary),
                filled: true,
                fillColor: colors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF0077C8), width: 1.5),
                ),
              ),
              style: GoogleFonts.outfit(color: colors.textPrimary),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.enterCategoryName;
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.outfit(color: colors.cancelButton),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  final categoriesVM = Provider.of<CategoriesViewModel>(
                    context,
                    listen: false,
                  );

                  try {
                    if (isEditing) {
                      await categoriesVM.updateCategory(category.id, {
                        'nom': nameController.text.trim(),
                      });
                    } else {
                      // Obtenim l'ordre més alt actual + 1
                      final cats = await categoriesVM.fetchCategories();
                      final maxOrdre = cats.isEmpty
                          ? 0
                          : cats
                              .map((c) => c.ordre)
                              .reduce((a, b) => a > b ? a : b);
                      await categoriesVM.addCategory({
                        'nom': nameController.text.trim(),
                        'ordre': maxOrdre + 1,
                      });
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? l10n.categoryUpdated
                                : l10n.categoryCreated,
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077C8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEditing ? l10n.saveChanges : l10n.create,
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Confirma l'eliminació d'una categoria, comprovant si té productes associats.
  void _showDeleteConfirmation(
    BuildContext context,
    Category category,
    AppColors colors,
    AppLocalizations l10n,
  ) async {
    final categoriesVM =
        Provider.of<CategoriesViewModel>(context, listen: false);
    final productCount =
        await categoriesVM.getProductsCountByCategory(category.id);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.dialog,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.deleteCategoryConfirmation,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteCategoryText(category.nom),
                style: GoogleFonts.outfit(color: colors.textSecondary),
              ),
              if (productCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.categoryHasProducts(productCount),
                          style: GoogleFonts.outfit(
                            color: Colors.orange[800],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.outfit(color: colors.cancelButton),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await categoriesVM.deleteCategory(category.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.categoryDeleted),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
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
                l10n.delete,
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Reordena les categories i actualitza el camp 'ordre' a Firestore.
  Future<void> _onReorder(
    BuildContext context,
    List<Category> categories,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;
    final categoriesVM =
        Provider.of<CategoriesViewModel>(context, listen: false);

    final reordered = List<Category>.from(categories);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);

    // Actualitza l'ordre de cada categoria afectada
    for (int i = 0; i < reordered.length; i++) {
      if (reordered[i].ordre != i) {
        await categoriesVM.updateCategory(reordered[i].id, {'ordre': i});
      }
    }
  }
}
