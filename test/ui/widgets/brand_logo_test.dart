/// Brand logo SVG contract: transparent gold mark for any backdrop.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/widgets/brand_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logo_mark.svg is gold-only with no opaque background fill', () {
    final svg = File('assets/brand/logo_mark.svg').readAsStringSync();
    expect(svg, contains('viewBox="0 0 128 128"'));
    expect(svg, contains('#D4A84B'));
    expect(svg.toLowerCase(), isNot(contains('rect.*fill="#0')));
    expect(svg, isNot(contains('fill="#0A0E16"')));
    expect(svg, isNot(contains('fill="#000')));
    expect(File(BrandLogo.asset).existsSync(), isTrue);
  });

  test('notification and launcher rasters exist beside the SVG source', () {
    expect(File('assets/brand/logo_mark.png').existsSync(), isTrue);
    expect(File('assets/brand/app_icon.png').existsSync(), isTrue);
    expect(
      File(
        'android/app/src/main/res/drawable-hdpi/ic_notification.png',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/'
        'Icon-App-1024x1024@1x.png',
      ).existsSync(),
      isTrue,
    );
  });

  test('AndroidManifest wires the notification icon drawable', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('@drawable/ic_notification'));
    expect(
      manifest,
      contains('com.google.firebase.messaging.default_notification_icon'),
    );
  });

  testWidgets('BrandLogo paints the SVG asset at the requested size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: BrandLogo(size: 48)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    final sized = tester.getSize(find.byType(BrandLogo));
    expect(sized.width, 48);
    expect(sized.height, 48);
    expect(AppColors.gold, const Color(0xFFD4A84B));
  });
}
