import 'package:flutter/material.dart';

/// Reusable card/list tile used for menu navigation actions.
class NavigationMenuTile extends StatelessWidget {
  const NavigationMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
