#!/usr/bin/env bash
# ==============================================================================
# SCRIPT AUTO-SYNC & UPLOAD ARTIKEL HASINA KE GITHUB
# ==============================================================================
# Creator: Hasina
# ==============================================================================

# Warna Terminal
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_GOLD="\033[38;5;220m"
C_GREEN="\033[38;5;82m"
C_CYAN="\033[38;5;51m"
C_RED="\033[38;5;196m"
C_GRAY="\033[38;5;245m"

clear
echo -e "${C_GOLD}${C_BOLD}"
echo "=================================================================="
echo "   🪶 HASINA — AUTO SYNC & UPLOAD ARTIKEL KE GITHUB SERVER"
echo "=================================================================="
echo -e "${C_RESET}"

PROJECT_DIR="/storage/emulated/0/Project Artikel/Tema keajaiban dunia"

if [ ! -d "$PROJECT_DIR" ]; then
  echo -e "${C_RED}❌ Folder proyek tidak ditemukan di:${C_RESET} $PROJECT_DIR"
  exit 1
fi

cd "$PROJECT_DIR" || exit 1

# 1. Tentukan Pesan Pembaruan (Commit Message)
if [ -n "$1" ]; then
  COMMIT_MSG="$1"
else
  echo -e "${C_CYAN}ℹ️  Tuliskan catatan perubahan untuk update artikel kali ini:${C_RESET}"
  read -r -p "👉 Catatan Update (tekan Enter untuk default): " USER_INPUT
  if [ -z "$USER_INPUT" ]; then
    COMMIT_MSG="Pembaruan artikel karya Hasina - $(date +'%d %b %Y %H:%M')"
  else
    COMMIT_MSG="$USER_INPUT"
  fi
fi

# 2. Update version.json agar browser pengunjung auto-sync
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION=$(date +"%y.%m.%d-%H%M%S")

cat <<EOF > version.json
{
  "version": "$VERSION",
  "updatedAt": "$TIMESTAMP",
  "author": "Hasina",
  "message": "$COMMIT_MSG"
}
EOF

echo -e "\n${C_GREEN}✔ Stempel versi baru dibuat:${C_RESET} v$VERSION"
echo -e "${C_GRAY}  Waktu sinkronisasi: $TIMESTAMP${C_RESET}\n"

# 3. Cek & Inisialisasi Git
if [ ! -d ".git" ]; then
  echo -e "${C_CYAN}📦 Menginisialisasi Git lokal...${C_RESET}"
  git init -b main
fi

# Pastikan branch adalah main
git branch -M main 2>/dev/null

# 4. Cek Remote Repository GitHub
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE_URL" ]; then
  echo -e "${C_GOLD}⚠️  Repositori GitHub belum dihubungkan.${C_RESET}"
  echo -e "${C_CYAN}Masukkan URL repositori GitHub Anda:${C_RESET}"
  echo -e "${C_GRAY}(Contoh: https://github.com/Syiraa27/keajaiban-dunia.git)${C_RESET}"
  read -r -p "🔗 URL Repositori: " INPUT_REPO_URL

  if [ -z "$INPUT_REPO_URL" ]; then
    echo -e "${C_RED}❌ URL repositori tidak boleh kosong. Dibatalkan.${C_RESET}"
    exit 1
  fi

  git remote add origin "$INPUT_REPO_URL"
  REMOTE_URL="$INPUT_REPO_URL"
  echo -e "${C_GREEN}✔ Repositori remote 'origin' berhasil ditambahkan!${C_RESET}\n"
fi

# 5. Git Stage & Commit
echo -e "${C_CYAN}📦 Mengemas perubahan berkas...${C_RESET}"
git add .
git commit -m "$COMMIT_MSG (v$VERSION)" 2>/dev/null || echo "Tidak ada perubahan berkas baru."

# 6. Push ke GitHub Server
echo -e "\n${C_GOLD}🚀 Mengunggah berkas ke server GitHub (git push)...${C_RESET}"
echo -e "${C_GRAY}Jika diminta Password, masukkan Personal Access Token (PAT) GitHub Anda.${C_RESET}\n"

if git push -u origin main; then
  echo -e "\n${C_GREEN}${C_BOLD}=================================================================="
  echo "   🎉 BERHASIL! ARTIKEL TELAH TER-UPLOAD KE SERVER GITHUB"
  echo "==================================================================${C_RESET}"
  
  # Format URL GitHub Pages
  GH_USER=$(echo "$REMOTE_URL" | sed -E 's/.*github\.com[\/:]([^\/]+)\/([^\/\.]+)(\.git)?/\1/')
  GH_REPO=$(echo "$REMOTE_URL" | sed -E 's/.*github\.com[\/:]([^\/]+)\/([^\/\.]+)(\.git)?/\2/')
  
  if [ -n "$GH_USER" ] && [ -n "$GH_REPO" ]; then
    echo -e "\n${C_CYAN}🌐 Tautan Situs Web Anda:${C_RESET}"
    echo -e "   ${C_GOLD}${C_BOLD}https://${GH_USER}.github.io/${GH_REPO}/${C_RESET}"
  fi
  
  echo -e "\n${C_GREEN}✨ Seluruh pengunjung web yang sedang membuka situs ini akan"
  echo -e "   otomatis mendeteksi update dan me-refresh halaman dalam hitungan detik!${C_RESET}\n"
else
  echo -e "\n${C_RED}❌ Gagal mengunggah ke GitHub.${C_RESET}"
  echo -e "${C_GOLD}💡 Tips Solusi:${C_RESET}"
  echo "1. Pastikan koneksi internet di HP Anda aktif."
  echo "2. Pastikan Personal Access Token (PAT) GitHub Anda masih berlaku dan memiliki izin 'repo'."
  echo "3. Jalankan kembali: ./upartikel.sh"
fi
