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
    expect(Config.anthropicApiKey, isEmpty);
    expect(Config.hasAnthropicKey, isFalse);
    expect(Config.anthropicKeySource, 'unloaded');
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
    expect(
      dotenv.env.containsKey('ANTHROPIC_API_KEY'),
      isTrue,
      reason: 'ANTHROPIC_API_KEY placeholder must be present',
    );
    expect(Config.geminiKeySource, isNot('unloaded'));
    expect(Config.anthropicKeySource, isNot('unloaded'));
    expect(Config.geminiApiKey, Config.geminiApiKey.trim());
    expect(Config.anthropicApiKey, Config.anthropicApiKey.trim());
    // Never assert the secret value — only that presence matches source.
    if (Config.hasAnthropicKey) {
      expect(Config.anthropicKeySource, anyOf('env-asset', 'dart-define'));
    }
  });

  test('a missing env file degrades quietly instead of throwing', () async {
    await expectLater(
      dotenv.load(fileName: 'does-not-exist.env', isOptional: true),
      completes,
    );
    expect(Config.hasGeminiKey, isFalse);
    expect(Config.geminiKeySource, 'missing');
    expect(Config.hasAnthropicKey, isFalse);
    expect(Config.anthropicKeySource, 'missing');
  });

  test('coach model is Claude Sonnet; Gemini remains for scenarios only', () {
    expect(Config.claudeCoachModel, startsWith('claude-'));
    expect(Config.geminiModel, isNot(Config.geminiImageModel));
    expect(
      Config.geminiGenerateContentUri().toString(),
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '${Config.geminiModel}:generateContent',
    );
  });
}
