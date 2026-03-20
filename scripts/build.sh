#!/bin/bash
# ============================================================
# Script de build — Demo RPG IBM i
# Auteur : Sylvain AKTEPE — NOTOS (Groupe Armonie)
# Usage  : ./build.sh [dev|recette|prod]
# ============================================================

ENV=${1:-dev}
REPO_DIR="/home/SYLVAIN/demo-rpg-ibmi"
SRC_DIR="$REPO_DIR/qrpglesrc"
SQL_DIR="$REPO_DIR/qddssrc"

# Bibliothèque cible selon l'environnement
case $ENV in
  dev)
    BIBLIO="DEMOGITDEV"
    BRANCH="dev"
    ;;
  recette)
    BIBLIO="DEMOGITRC"
    BRANCH="recette"
    ;;
  prod)
    BIBLIO="DEMOGIT"
    BRANCH="main"
    ;;
  *)
    echo "❌ Environnement inconnu : $ENV"
    echo "Usage : ./build.sh [dev|recette|prod]"
    exit 1
    ;;
esac

echo "============================================"
echo "🔨 BUILD — Environnement : $ENV"
echo "📁 Bibliothèque cible    : $BIBLIO"
echo "🌿 Branche               : $BRANCH"
echo "============================================"

# 1. Pull des dernières modifications
echo ""
echo "📥 Récupération des sources depuis GitHub..."
cd "$REPO_DIR"
git checkout "$BRANCH"
git pull origin "$BRANCH"

if [ $? -ne 0 ]; then
  echo "❌ Erreur lors du git pull"
  exit 1
fi
echo "✅ Sources à jour"

# 2. Vérifier que la bibliothèque existe
echo ""
echo "📚 Vérification de la bibliothèque $BIBLIO..."
system "CHKOBJ OBJ($BIBLIO) OBJTYPE(*LIB)" 2>/dev/null
if [ $? -ne 0 ]; then
  echo "📚 Création de la bibliothèque $BIBLIO..."
  system "CRTLIB LIB($BIBLIO) TEXT('Demo Git - $ENV')"
fi
echo "✅ Bibliothèque $BIBLIO prête"

# 3. Compiler les sources RPG
echo ""
echo "🔨 Compilation des programmes RPG..."

for src in "$SRC_DIR"/*.sqlrpgle; do
  if [ -f "$src" ]; then
    pgm=$(basename "$src" .sqlrpgle | tr '[:lower:]' '[:upper:]')
    echo "  ⚙️  Compilation de $pgm..."

    system "CRTSQLRPGI OBJ($BIBLIO/$pgm) SRCSTMF('$src') COMMIT(*NONE) DBGVIEW(*SOURCE) REPLACE(*YES) CVTCCSID(*JOB)" 2>/dev/null

    if [ $? -eq 0 ]; then
      echo "  ✅ $pgm compilé avec succès"
    else
      echo "  ❌ Erreur de compilation pour $pgm"
      exit 1
    fi
  fi
done

# 4. Résumé
echo ""
echo "============================================"
echo "✅ BUILD TERMINÉ"
echo "📁 Bibliothèque : $BIBLIO"
echo "🌿 Branche      : $BRANCH"
echo "📅 Date         : $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================"
