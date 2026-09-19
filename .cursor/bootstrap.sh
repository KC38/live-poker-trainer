#!/usr/bin/env bash
# Cloud Agent environment bootstrap for the Exploitative Poker Lab Flutter app.
#
# Idempotent: safe to run on every install. Prepares the two gitignored,
# developer-local files a fresh checkout is missing so the app can compile and
# run:
#   * .env                     — declared Flutter asset (see README "Secrets").
#   * lib/firebase_options.dart — FlutterFire config (see README "Firebase").
#
# Real API keys are read from the environment when present, so the same script
# yields a fully functional build once secrets are configured, and a
# boots-and-renders build when they are not.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# 1) .env is a declared asset in pubspec.yaml and must exist locally, or the
#    build fails with a missing-asset error. Never overwrite a real one.
if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "[bootstrap] created .env from .env.example"
else
  echo "[bootstrap] .env already present"
fi

# Inject provided coach/scenario keys into .env when supplied via secrets.
if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  sed -i "s|^ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}|" .env
  echo "[bootstrap] wrote ANTHROPIC_API_KEY into .env"
fi
if [[ -n "${GEMINI_API_KEY:-}" ]]; then
  sed -i "s|^GEMINI_API_KEY=.*|GEMINI_API_KEY=${GEMINI_API_KEY}|" .env
  echo "[bootstrap] wrote GEMINI_API_KEY into .env"
fi

# 2) lib/firebase_options.dart is gitignored (contains project client config).
#    Generate it from the committed template, substituting real browser keys
#    when available. A placeholder still compiles and boots.
FB_OUT="lib/firebase_options.dart"
if [[ ! -f "$FB_OUT" ]]; then
  WEB_KEY="${FIREBASE_WEB_API_KEY:-AIzaSyDEMO-PLACEHOLDER-live-poker-web}"
  ANDROID_KEY="${FIREBASE_ANDROID_API_KEY:-${FIREBASE_WEB_API_KEY:-AIzaSyDEMO-PLACEHOLDER-live-poker-android}}"
  IOS_KEY="${FIREBASE_IOS_API_KEY:-${FIREBASE_WEB_API_KEY:-AIzaSyDEMO-PLACEHOLDER-live-poker-ios}}"
  sed -e "s|__WEB_API_KEY__|${WEB_KEY}|" \
      -e "s|__ANDROID_API_KEY__|${ANDROID_KEY}|" \
      -e "s|__IOS_API_KEY__|${IOS_KEY}|" \
      .cursor/firebase_options.dart.tmpl > "$FB_OUT"
  if [[ -n "${FIREBASE_WEB_API_KEY:-}" ]]; then
    echo "[bootstrap] generated $FB_OUT with provided FIREBASE_WEB_API_KEY"
  else
    echo "[bootstrap] generated $FB_OUT with placeholder key (set FIREBASE_WEB_API_KEY for live Firebase)"
  fi
else
  echo "[bootstrap] $FB_OUT already present"
fi

echo "[bootstrap] done"
