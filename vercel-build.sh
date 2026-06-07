#!/usr/bin/env bash
# Build della web app su Vercel. Tenuto in uno script perché il buildCommand
# inline di Vercel è limitato a 256 caratteri (e i --dart-define lo superano).
# Le variabili d'ambiente sono fornite da Vercel (Settings -> Environment Variables).
set -euo pipefail

git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter

_flutter/bin/flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}" \
  --dart-define=VAPID_PUBLIC_KEY="${VAPID_PUBLIC_KEY:-}"
