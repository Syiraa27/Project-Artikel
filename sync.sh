#!/bin/bash
# ==============================================================================
# SCRIPT AUTO-SYNC ARTIKEL HASINA
# ==============================================================================
# Penggunaan:
#   ./sync.sh "Pesan perubahan / catatan update"
# ==============================================================================

PROJECT_DIR="/storage/emulated/0/Project Artikel/Tema keajaiban dunia"
cd "$PROJECT_DIR" || exit 1

MSG="${1:-Pembaruan artikel oleh Hasina}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION=$(date +"%y.%m.%d-%H%M%S")

echo "=================================================="
echo "🪶 MEMULAI PROSES AUTO-SYNC ARTIKEL HASINA"
echo "=================================================="

# 1. Update version.json
cat <<EOF > version.json
{
  "version": "$VERSION",
  "updatedAt": "$TIMESTAMP",
  "author": "Hasina",
  "message": "$MSG"
}
EOF

echo "✅ version.json diperbarui ke versi: $VERSION"
echo "🕒 Waktu update: $TIMESTAMP"

# 2. Git sync jika git terinisialisasi
if [ -d ".git" ]; then
  git add .
  git commit -m "$MSG (v$VERSION)"
  
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
  if [ -z "$CURRENT_BRANCH" ]; then
    CURRENT_BRANCH="main"
  fi

  if git remote | grep -q "origin"; then
    echo "🚀 Mengunggah perubahan ke repositori online (git push)..."
    git push origin "$CURRENT_BRANCH"
    echo ""
    echo "🎉 BERHASIL SINKRONISASI!"
    echo "Pengunjung situs Anda akan otomatis menerima pembaruan dalam beberapa detik."
  else
    echo "⚠️ Remote repository Git belum dihubungkan ke GitHub/hosting."
    echo "Jalankan: git remote add origin <URL_REPO_ANDA>"
  fi
else
  echo "ℹ️ Git belum diinisialisasi di folder ini."
fi

echo "=================================================="
