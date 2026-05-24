#!/usr/bin/env bash
# Reset local Togo Market (DEV ONLY) — irréversible sans backup.
set -euo pipefail

LARAVEL_ROOT="/home/othnelio/laravel-togo-market"
FLUTTER_ROOT="/home/othnelio/Togo_market"
FIREBASE_RESET="$FLUTTER_ROOT/scripts/firebase_reset"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  RESET COMPLET TOGO MARKET (environnement local)${NC}"
echo -e "${YELLOW}  MySQL + fichiers Laravel + Firebase + caches Flutter${NC}"
echo -e "${YELLOW}  Supabase : vider chat_media MANUELLEMENT (Dashboard)${NC}"
echo -e "${YELLOW}══════════════════════════════════════════════════════════${NC}"
echo ""
read -rp "Tapez RESET pour confirmer : " confirm
if [[ "$confirm" != "RESET" ]]; then
  echo "Annulé."
  exit 1
fi

echo -e "\n${GREEN}[1/5] Laravel : migrate:fresh --seed${NC}"
cd "$LARAVEL_ROOT"
php artisan migrate:fresh --seed --force

echo -e "\n${GREEN}[2/5] Laravel : uploads publics${NC}"
find storage/app/public/produits -mindepth 1 -delete 2>/dev/null || true
find storage/app/public/boutiques -mindepth 1 -delete 2>/dev/null || true
find storage/app/public/profiles -mindepth 1 -delete 2>/dev/null || true

echo -e "\n${GREEN}[3/5] Laravel : caches${NC}"
php artisan optimize:clear
php artisan queue:clear 2>/dev/null || true
php artisan storage:link 2>/dev/null || true

echo -e "\n${GREEN}[4/5] Firebase : Firestore + Storage chats/${NC}"
if [[ -f "$FIREBASE_RESET/reset_messaging.js" ]]; then
  cd "$FIREBASE_RESET"
  if [[ ! -d node_modules ]]; then
    npm install --silent
  fi
  node reset_messaging.js
else
  echo -e "${RED}Script reset_messaging.js introuvable — étape ignorée${NC}"
fi

echo -e "\n${GREEN}[5/5] Flutter : clean${NC}"
cd "$FLUTTER_ROOT"
flutter clean
flutter pub get

echo -e "\n${GREEN}Vérification MySQL :${NC}"
cd "$LARAVEL_ROOT"
php artisan tinker --execute="
echo 'users='.\\App\\Models\\User::count();
echo ' produits='.\\App\\Models\\Produit::count();
echo ' boutiques='.\\App\\Models\\Boutique::count();
echo ' categories='.\\App\\Models\\Category::count();
echo PHP_EOL;
"

echo ""
echo -e "${YELLOW}Actions manuelles restantes :${NC}"
echo "  1. Supabase Dashboard → Storage → bucket chat_media → tout supprimer"
echo "  2. Android : adb shell pm clear com.example.togo_market"
echo "  3. Relancer : composer run dev + flutter run"
echo ""
echo -e "${GREEN}Reset automatisé terminé.${NC}"
