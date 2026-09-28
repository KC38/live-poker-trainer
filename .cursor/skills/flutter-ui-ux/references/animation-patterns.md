# Animation patterns

Implicit animations - AnimatedContainer, AnimatedOpacity

Explicit animations - AnimationController with Tween

Hero animations - Screen transitions with Hero widgets

Micro-interactions - Button presses, hover effects, loading states

## Types

| Type | Widget | Duration | Use Case |
| --- | --- | --- | --- |
| Fade | AnimatedOpacity | 200-300ms | Show/hide content |
| Slide | SlideTransition | 250-350ms | Screen transitions |
| Scale | AnimatedScale | 150-250ms | Button presses |
| Rotation | RotationTransition | 1000-2000ms | Loading indicators |

## Performance

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

Pass the stable child into `AnimatedBuilder` so the animated widget does not
rebuild its contents every frame.
