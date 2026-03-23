#!/bin/bash
# ============================================================
# Script de promotion — Calcul Prix
# Auteur : Sylvain AKTEPE — NOTOS (Groupe Armonie)
#
# Usage :
#   ./promote.sh build dev       → compile dans CALCPXDEV
#   ./promote.sh build recette   → compile dans CALCPXRC
#   ./promote.sh build prod      → compile dans CALCPRIX
#   ./promote.sh promote dev     → copie dev → recette
#   ./promote.sh promote recette → copie recette → prod
# ============================================================

ACTION=${1:-build}
ENV=${2:-dev}
BASE_DIR="/home/SYLVAIN/projets/calcprix"

# Configuration des environnements
case $ENV in
  dev)
    SRC_DIR="$BASE_DIR/dev/qrpglesrc"
    BIBLIO="CALCPXDEV"
    NEXT_ENV="recette"
    ;;
  recette)
    SRC_DIR="$BASE_DIR/recette/qrpglesrc"
    BIBLIO="CALCPXRC"
    NEXT_ENV="prod"
    ;;
  prod)
    SRC_DIR="$BASE_DIR/prod/qrpglesrc"
    BIBLIO="CALCPRIX"
    NEXT_ENV=""
    ;;
  *)
    echo "❌ Environnement inconnu : $ENV"
    echo "Usage : ./promote.sh [build|promote] [dev|recette|prod]"
    exit 1
    ;;
esac

# ============================================================
# ACTION : BUILD — Compiler les sources
# ============================================================
if [ "$ACTION" = "build" ]; then
  echo "============================================"
  echo "🔨 BUILD — Environnement : $ENV"
  echo "📁 Sources     : $SRC_DIR"
  echo "📚 Bibliothèque : $BIBLIO"
  echo "============================================"
  echo ""

  # Vérifier que la bibliothèque existe
  system "CHKOBJ OBJ($BIBLIO) OBJTYPE(*LIB)" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "📚 Création de la bibliothèque $BIBLIO..."
    system "CRTLIB LIB($BIBLIO) TEXT('Calcul Prix - $ENV')"
  fi

  # Compiler les sources RPGLE
  for src in "$SRC_DIR"/*.rpgle; do
    if [ -f "$src" ]; then
      pgm=$(basename "$src" .rpgle | tr '[:lower:]' '[:upper:]')
      echo "  ⚙️  Compilation de $pgm..."

      system "CRTBNDRPG OBJ($BIBLIO/$pgm) SRCSTMF('$src') DBGVIEW(*SOURCE) REPLACE(*YES)" 2>/dev/null

      if [ $? -eq 0 ]; then
        echo "  ✅ $pgm compilé avec succès dans $BIBLIO"
      else
        echo "  ❌ Erreur de compilation pour $pgm"
        exit 1
      fi
    fi
  done

  # Compiler les sources SQLRPGLE
  for src in "$SRC_DIR"/*.sqlrpgle; do
    if [ -f "$src" ]; then
      pgm=$(basename "$src" .sqlrpgle | tr '[:lower:]' '[:upper:]')
      echo "  ⚙️  Compilation de $pgm (SQL)..."

      system "CRTSQLRPGI OBJ($BIBLIO/$pgm) SRCSTMF('$src') COMMIT(*NONE) DBGVIEW(*SOURCE) REPLACE(*YES) CVTCCSID(*JOB)" 2>/dev/null

      if [ $? -eq 0 ]; then
        echo "  ✅ $pgm compilé avec succès dans $BIBLIO"
      else
        echo "  ❌ Erreur de compilation pour $pgm"
        exit 1
      fi
    fi
  done

  echo ""
  echo "============================================"
  echo "✅ BUILD TERMINÉ — $BIBLIO"
  echo "📅 $(date '+%Y-%m-%d %H:%M:%S')"
  echo "============================================"

# ============================================================
# ACTION : PROMOTE — Copier vers l'environnement suivant
# ============================================================
elif [ "$ACTION" = "promote" ]; then

  if [ -z "$NEXT_ENV" ]; then
    echo "❌ Impossible de promouvoir depuis prod — c'est le dernier environnement"
    exit 1
  fi

  DEST_DIR="$BASE_DIR/$NEXT_ENV/qrpglesrc"

  echo "============================================"
  echo "🚀 PROMOTION : $ENV → $NEXT_ENV"
  echo "📤 Source      : $SRC_DIR"
  echo "📥 Destination : $DEST_DIR"
  echo "============================================"
  echo ""

  # Créer le répertoire cible s'il n'existe pas
  mkdir -p "$DEST_DIR"

  # Copier les sources
  cp -v "$SRC_DIR"/*.rpgle "$DEST_DIR/" 2>/dev/null
  cp -v "$SRC_DIR"/*.sqlrpgle "$DEST_DIR/" 2>/dev/null

  echo ""
  echo "✅ Sources copiées vers $NEXT_ENV"
  echo ""

  # Proposer la compilation
  echo "📋 Pour compiler en $NEXT_ENV :"
  echo "   ./promote.sh build $NEXT_ENV"
  echo ""
  echo "============================================"

else
  echo "❌ Action inconnue : $ACTION"
  echo "Usage : ./promote.sh [build|promote] [dev|recette|prod]"
  exit 1
fi
