import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common_widgets.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logotipo + nombre
              Icon(
                Icons.gavel_rounded,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'IUS ZAC',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Derecho Digital · Zacatecas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              // Tagline
              Text(
                'La plataforma integral para la actualización jurídica y el debate legal profesional.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const Spacer(),
              // Botón Comenzar
              LawButton(
                label: 'Comenzar',
                onPressed: () => context.go('/register'),
              ),
              const SizedBox(height: 16),
              // Enlace 'Ya tengo cuenta'
              TextButton(
                onPressed: () => context.go('/login'),
                child: RichText(
                  text: TextSpan(
                    text: '¿Ya tienes cuenta? ',
                    style: TextStyle(color: Colors.grey.shade700),
                    children: [
                      TextSpan(
                        text: 'Inicia sesión',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
