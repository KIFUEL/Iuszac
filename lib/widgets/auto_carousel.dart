
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/publication.dart';
import 'large_update_card.dart';

class AutoCarousel extends StatefulWidget {
  final List<Publication> publications;
  final Duration duration;

  const AutoCarousel({
    super.key,
    required this.publications,
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<AutoCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.publications.isNotEmpty) {
      _animationController.forward();
    }

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_isUserScrolling && widget.publications.isNotEmpty) {
          final nextPage = (_currentPage + 1) % widget.publications.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    if (!_isUserScrolling) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.publications.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 380, // Aproximadamente el alto de LargeUpdateCard
          child: Listener(
            onPointerDown: (_) {
              _isUserScrolling = true;
              _animationController.stop();
            },
            onPointerUp: (_) {
              _isUserScrolling = false;
              _animationController.forward(from: 0.0);
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.publications.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final update = widget.publications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: LargeUpdateCard(
                    update: update,
                    onTap: () => context.push('/alerts/detail/${update.id}'),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores y barra de progreso
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.publications.length, (index) {
              final isCurrent = index == _currentPage;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: isCurrent
                      ? AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _animationController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          },
                        )
                      : null,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
