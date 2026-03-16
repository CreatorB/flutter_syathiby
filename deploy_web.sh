#!/bin/bash
# Deploy Flutter Web ke aplikasi/web
# Usage (dari PowerShell): bash ./deploy_web.sh
#   Options:
#     --dev           Build DEV  (base-href /aplikasi/web/) untuk akses via IP
#     --prod          Build PROD (base-href /web/) untuk aplikasi.test & server [default]
#     --skip-build    Skip flutter build, hanya sync saja
#     --commit "msg"  Auto commit & push ke repo aplikasi

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLUTTER_DIR="$SCRIPT_DIR"
APLIKASI_WEB="$SCRIPT_DIR/../aplikasi/web"

# Cari fvm
if command -v fvm &>/dev/null; then
    FVM="fvm"
else
    WIN_FVM="$HOME/AppData/Local/Pub/Cache/bin/fvm.bat"
    if [ -f "$WIN_FVM" ]; then
        FVM="$WIN_FVM"
    else
        echo "ERROR: fvm tidak ditemukan."
        exit 1
    fi
fi

# Defaults
MODE="PROD"
BASE_HREF="/web/"
SKIP_BUILD=false
AUTO_COMMIT=false
COMMIT_MSG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dev)        MODE="DEV"; BASE_HREF="/aplikasi/web/"; shift ;;
        --prod)       MODE="PROD"; BASE_HREF="/web/"; shift ;;
        --skip-build) SKIP_BUILD=true; shift ;;
        --commit)     AUTO_COMMIT=true; COMMIT_MSG="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo ""
echo "======================================="
echo "   SYATHIBY WEB DEPLOY (bash)"
echo "======================================="
echo "  Mode:      $MODE"
echo "  Base-href: $BASE_HREF"
echo "  FVM:       $FVM"
echo ""

# Step 1: Build
if [ "$SKIP_BUILD" = false ]; then
    echo "[1/3] Building flutter web [$MODE]..."
    cd "$FLUTTER_DIR"
    export MSYS_NO_PATHCONV=1
    "$FVM" flutter build web --base-href "$BASE_HREF" --release
    
    echo "      Injecting Cache Buster..."
    BUILD_ID=$(date +%Y%m%d%H%M%S)
    # Gunakan sed untuk mengganti {{BUILD_VERSION}} dengan BUILD_ID di build/web/index.html
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed needs an empty string for -i
        sed -i "" "s/{{BUILD_VERSION}}/$BUILD_ID/g" build/web/index.html
    else
        sed -i "s/{{BUILD_VERSION}}/$BUILD_ID/g" build/web/index.html
    fi
    echo "      Build complete (Version: $BUILD_ID)."
else
    echo "[1/3] Skipping build (--skip-build)"
fi

# Step 2: Sync
echo "[2/3] Syncing build/web -> aplikasi/web..."
if [ ! -d "$APLIKASI_WEB" ]; then
    echo "ERROR: Folder $APLIKASI_WEB tidak ditemukan!"
    exit 1
fi
rm -rf "$APLIKASI_WEB"/*
cp -r "$FLUTTER_DIR/build/web/"* "$APLIKASI_WEB/"
for f in "$FLUTTER_DIR/build/web/".??*; do
    [ -e "$f" ] && cp -r "$f" "$APLIKASI_WEB/"
done
echo "      Sync complete."

# Step 3: Git commit & push (optional)
if [ "$AUTO_COMMIT" = true ]; then
    echo "[3/3] Committing & pushing..."
    cd "$SCRIPT_DIR/../aplikasi"
    git add web/
    git commit -m "${COMMIT_MSG:-:hammer: update flutter web}"
    git push
    echo "      Push complete."
else
    echo "[3/3] Skipping git commit (use --commit \"message\" to auto commit)"
fi

echo ""
echo "======================================="
echo "   DEPLOY SELESAI [$MODE]"
echo "======================================="
echo ""
if [ "$MODE" = "DEV" ]; then
    echo "  Test: http://192.168.50.100/aplikasi/web/"
else
    echo "  Test: http://aplikasi.test/web/"
    echo "  Prod: https://aplikasi.syathiby.id/web/"
fi
echo ""
