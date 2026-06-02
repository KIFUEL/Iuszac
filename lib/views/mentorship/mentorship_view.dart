import 'package:flutter/material.dart';

class MentorshipView extends StatelessWidget {
  const MentorshipView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Directorio de Mentores')),
      body: const Center(child: Text('Encuentra expertos en diferentes ramas del derecho.')),
    );
  }
}
