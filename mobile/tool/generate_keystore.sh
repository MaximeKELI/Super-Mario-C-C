#!/usr/bin/env bash
# Generate Play Store upload keystore for PipeLeap.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID="$ROOT/android"
KEYSTORE="$ANDROID/upload-keystore.jks"
PROPS="$ANDROID/key.properties"

if [[ -f "$KEYSTORE" ]]; then
  echo "Keystore already exists: $KEYSTORE"
  exit 0
fi

PASS="${PIPELEAP_KEYSTORE_PASS:-$(openssl rand -base64 24)}"

keytool -genkey -v \
  -keystore "$KEYSTORE" \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias pipeleap \
  -storepass "$PASS" \
  -keypass "$PASS" \
  -dname "CN=PipeLeap, OU=Mobile, O=PipeLeap, L=Internet, ST=NA, C=US"

cat > "$PROPS" <<EOF
storePassword=$PASS
keyPassword=$PASS
keyAlias=pipeleap
storeFile=upload-keystore.jks
EOF

chmod 600 "$PROPS" "$KEYSTORE"
echo "Created $KEYSTORE and $PROPS"
echo "Back up the keystore and passwords securely — losing them blocks Play updates."
