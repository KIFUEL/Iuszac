import 'package:flutter/material.dart';

class ForumView extends StatelessWidget {
  const ForumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foro de Discusión')),
      body: const Center(child: Text('Plantea aquí tus dudas o casos legales.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
