import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/view/creation_product_screen.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsViewModel = Provider.of<ProductsViewModel>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administració',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dashboard Section
            _buildDashboard(context, productsViewModel),

            const SizedBox(height: 24),
            const Text(
              'Gestió',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildAdminOption(
              context,
              icon: Icons.add_box,
              title: 'Crear Productes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreationProductScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildAdminOption(
              context,
              icon: Icons.people,
              title: 'Administrar Usuaris',
              onTap: () {
                // TODO: Navegar a l'administració d'usuaris
              },
            ),
            const SizedBox(height: 12),
            _buildAdminOption(
              context,
              icon: Icons.edit,
              title: 'Administrar Productes',
              onTap: () {
                // TODO: Navegar a l'administració de productes (editar)
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, ProductsViewModel viewModel) {
    return StreamBuilder<List<Product>>(
      stream: viewModel.getProductsStream(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return Card(
          color: Colors.blue[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(Icons.inventory, color: Colors.white, size: 40),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Productes',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[800]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
