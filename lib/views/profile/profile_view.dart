import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            const Text('Nombre de Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
