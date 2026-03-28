#!/bin/bash
# Import GPG keys if not already present
set -euo pipefail

KEY_ID="3934970EDF71D5D3"
GPG_EXPORT_DIR="$HOME/.local/share/gpg-export"

if gpg --list-secret-keys "$KEY_ID" &>/dev/null; then
    echo "GPG key $KEY_ID already imported, skipping."
    exit 0
fi

echo "Importing GPG keys..."
gpg --batch --import "$GPG_EXPORT_DIR/public.asc"
gpg --batch --import "$GPG_EXPORT_DIR/private.asc"
gpg --import-ownertrust "$GPG_EXPORT_DIR/ownertrust.txt"
echo "GPG keys imported successfully."
