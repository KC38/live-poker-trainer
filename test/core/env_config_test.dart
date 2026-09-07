import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(dotenv.clean);

  test('key reads are safe before dotenv loads', () {
    dotenv.clean();
    expect(Config.geminiApiKey, isEmpty);
    expect(Config.hasGeminiKey, isFalse);
    expect(Config.geminiKeySource, 'unloaded');
  });

  test('env files resolve through the asset bundle', () async {
    // Mirrors main(): `.env.example` is the committed base, `.env` overrides.
    // Both must be declared as assets or nothing is readable at runtime.
    await dotenv.load(
      fileName: '.env.example',
      overrideWithFiles: const ['.env'],
      isOptional: true,
    );

    expect(
      dotenv.env.containsKey('GEMINI_API_KEY'),
      isTrue,
      reason: '.env / .env.example must be bundled assets (see pubspec.yaml)',
    );
    expect(Config.geminiKeySource, isNot('unloaded'));
    expect(Config.geminiApiKey, Config.geminiApiKey.trim());
  });

  test('a missing env file degrades quietly instead of throwing', () async {
    await expectLater(
      dotenv.load(fileName: 'does-not-exist.env', isOptional: true),
      completes,
    );
    expect(Config.hasGeminiKey, isFalse);
    expect(Config.geminiKeySource, 'missing');
  });

  test('coach speech uses the dedicated TTS model and Puck voice', () {
    expect(Config.geminiTtsModel, isNot(Config.geminiModel));
    expect(Config.geminiTtsModel, contains('tts'));
    expect(Config.coachVoice, 'Puck');
    expect(
      Config.geminiGenerateContentUri(model: Config.geminiTtsModel).toString(),
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '${Config.geminiTtsModel}:generateContent',
    );
  });
}
