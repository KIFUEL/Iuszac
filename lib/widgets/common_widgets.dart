import 'package:flutter/material.dart';

class LawButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final Color? backgroundColor;
  // Optional icon to display alongside the label
  final IconData? icon;

  const LawButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    // Gradient only when isPrimary and no override backgroundColor provided
    final useGradient = isPrimary && backgroundColor == null;

    // Larger, premium button dimensions
    const double buttonHeight = 60.0;
    const double borderRadius = 16.0;
    const double iconSize = 24.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: useGradient
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary,
                    Color.lerp(primary, Colors.indigo.shade900, 0.45)!,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(borderRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius),
                  onTap: isLoading ? null : onPressed,
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null) ...[
                                Icon(icon, size: iconSize, color: Colors.white),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 17,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(buttonHeight),
                backgroundColor: backgroundColor ?? secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius)),
              ),
              onPressed: isLoading ? null : onPressed,
              child: isLoading
                  ? const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: iconSize, color: Colors.white),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}


class LawTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const LawTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Larger, premium input styling
    const double iconSize = 28.0;
    const double fontSize = 16.0;
    const double borderRadius = 16.0;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(fontSize: fontSize, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: fontSize),
        prefixIcon: Icon(icon, size: iconSize),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF161B2E)
            : const Color(0xFFF3F4F8),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}


class LawDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const LawDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Premium dropdown styling
    const double borderRadius = 16.0;
    const double fontSize = 16.0;
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: fontSize),
        prefixIcon: Icon(icon, size: 28),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      ),
      style: TextStyle(fontSize: fontSize, color: Theme.of(context).colorScheme.onSurface),
    );
  }
}


class LawCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const LawCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Glassmorphism + subtle elevation for premium look
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.grey.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        // Subtle backdrop blur effect (requires ClipRRect in parent widget)
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
        child: child,
      ),
    );
  }
}

