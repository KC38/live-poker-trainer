# Performance

Phase 5: Optimize and Test

Performance profiling - Use Flutter DevTools

Accessibility testing - Screen readers, contrast ratios

Responsive testing - Multiple screen sizes and orientations

Animation smoothness - 60fps validation

```dart
// ✅ DO: Use performance-optimized animations
AnimatedBuilder(
  animation: controller,
  builder: (context, child) => Transform.rotate(
    angle: controller.value * 2 * math.pi,
    child: child, // Pass child to avoid rebuilding
  ),
  child: const Icon(Icons.refresh),
)

// ❌ DON'T: Animate expensive operations
// Avoid animating complex layouts or heavy widgets
```

Do not animate a complex layout or a heavy widget. Animate a transform,
opacity, or a small leaf. Profile before adding another controller on a
table that already moves chips.
