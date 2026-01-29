import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administració',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildAdminOption(
              context,
              icon: Icons.add_box,
              title: 'Crear Productes',
              onTap: () {
                // TODO: Navegar a la pantalla de creació de productes
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
