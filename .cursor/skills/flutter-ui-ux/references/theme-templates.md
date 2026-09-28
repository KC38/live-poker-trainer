# Theme templates

Add custom themes with ThemeData, ColorScheme, and TextTheme. Buttons read
`colorScheme` so a later screen does not invent a second palette.

In this app the branded theme is `buildPokerTheme` in
`lib/ui/theme/app_theme.dart` and `AppColors` in
`lib/core/constants/colors.dart`. Extend that theme. Do not ship a parallel
`ThemeData`.

```dart
class ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ThemedButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
  }
}
```

The Live Poker Trainer button metrics (height, radius, type) are the
Theme section of `docs/ui/design-record.md`. Match those when this template
disagrees with the record.
