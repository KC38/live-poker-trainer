# Widget patterns

Compose small widgets. Prefer `const` constructors. Read
[SKILL.md](../SKILL.md) phases 2 and 3 before adding a widget.

```dart
// ✅ DO: Compose small, reusable widgets
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const CustomCard({required this.child, this.padding = EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(padding: padding, child: child),
    );
  }
}

// ✅ DO: Use const constructors where possible
const Icon(Icons.add) // Better than Icon(Icons.add)
```

## Responsive layouts

| Technique | Use Case | Implementation |
| --- | --- | --- |
| LayoutBuilder | Responsive layouts | `LayoutBuilder(builder: (context, constraints) => ...)` |
| MediaQuery | Screen info | `MediaQuery.of(context).size.width` |
| Flexible/Expanded | Flex layouts | `Flexible(child: ...)` or `Expanded(child: ...)` |
| AspectRatio | Fixed ratios | `AspectRatio(aspectRatio: 16/9, child: ...)` |

```dart
class ResponsiveCard extends StatelessWidget {
  final Widget child;

  const ResponsiveCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWideLayout(child);
        } else {
          return _buildNarrowLayout(child);
        }
      },
    );
  }

  Widget _buildWideLayout(Widget child) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }

  Widget _buildNarrowLayout(Widget child) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
```

Core widgets: StatelessWidget, StatefulWidget, InheritedWidget.

Layout: Row, Column, Stack, GridView, ListView.
