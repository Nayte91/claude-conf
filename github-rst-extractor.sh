#!/usr/bin/env bash
set -euo pipefail

# Fonction d'aide
show_usage() {
    echo "Usage: $0 <repo> <branch> <start_path> <output_file>"
    echo ""
    echo "Exemples:"
    echo "  $0 doctrine/orm 3.5.x docs/en doctrine-urls.txt"
    echo "  $0 symfony/symfony 7.3 src/Symfony/Component/Console/Resources/doc symfony-console-docs.txt"
    echo "  $0 phpunit/phpunit main docs phpunit-docs.txt"
    echo ""
    echo "Arguments:"
    echo "  repo        : Repository GitHub au format 'owner/name'"
    echo "  branch      : Branche à analyser (ex: main, 3.5.x, v7.3)"
    echo "  start_path  : Chemin de départ pour la recherche"
    echo "  output_file : Fichier de sortie pour les URLs"
    exit 1
}

# Vérifier le nombre d'arguments
if [ $# -ne 4 ]; then
    echo "Erreur: Nombre d'arguments incorrect" >&2
    show_usage
fi

# Récupérer les paramètres
REPO="$1"
BRANCH="$2"
START_PATH="$3"
OUTPUT="$4"

# Vider le fichier de sortie
> "$OUTPUT"

# Récupérer l'arbre complet du dépôt
json=$(curl -s "https://api.github.com/repos/$REPO/git/trees/$BRANCH?recursive=1")

# Vérifier si l'API a renvoyé une erreur
if echo "$json" | grep -q '"message":'; then
  echo "Erreur renvoyée par l'API GitHub :" >&2
  echo "$json" | grep '"message":' >&2
  exit 1
fi

# Extraire les chemins des fichiers .rst dans docs/en
echo "$json" \
  | grep '"path":' \
  | sed -E 's/.*"path": "([^"]+)".*/\1/' \
  | grep "^$START_PATH/.*\.rst$" \
  | while read -r path; do
      echo "https://raw.githubusercontent.com/$REPO/refs/heads/$BRANCH/$path"
    done > "$OUTPUT"

echo "Terminé — URLs .rst enregistrées dans : $OUTPUT"
echo "Repository: $REPO"
echo "Branch: $BRANCH" 
echo "Start path: $START_PATH"
echo "Nombre d'URLs trouvées: $(wc -l < "$OUTPUT")"