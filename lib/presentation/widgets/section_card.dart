import 'package:flutter/material.dart';

/// Card with optional title for form sections.
/// Paste in: lib/presentation/widgets/section_card.dart
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final String? title;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
