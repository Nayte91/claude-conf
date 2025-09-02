#!/bin/bash

# Lire les données de session Claude Code
input=$(cat)


# Extraire le répertoire de travail actuel
repertoire_actuel="$(pwd)"

# Obtenir la branche git avec gestion d'erreur
branche_git="$(git -c core.abbrev=40 branch --show-current 2>/dev/null || echo 'aucun-git')"

# Obtenir les lignes ajoutées/supprimées depuis le dernier commit
if git rev-parse --git-dir >/dev/null 2>&1; then
    # Vérifier s'il y a des changements dans le working directory
    if git diff --quiet HEAD 2>/dev/null; then
        # Aucun changement depuis le dernier commit
        stats="+0/-0"
    else
        # Calculer les différences depuis le dernier commit
        stats=$(git diff --numstat HEAD 2>/dev/null | \
                awk '{added += $1; deleted += $2} END {
                    if (NR == 0) printf "+0/-0"
                    else printf "+%d/-%d", added+0, deleted+0
                }')
    fi
else
    stats="+0/-0"
fi

# Vérifier si on dépasse 200k tokens
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false' 2>/dev/null)

# Construire la partie context window uniquement si on est en saturation
context_part=""
if [ "$exceeds_200k" = "true" ]; then
    context_part=" | \033[01;31m🪟 100%\033[00m"
fi

# Sortir la ligne de statut en français
# Couleurs: Bleu pour répertoire, Jaune pour branche git, Vert pour stats, Rouge pour context window en saturation
echo -e "\033[01;34m${repertoire_actuel}\033[00m | \033[01;33m${branche_git}\033[00m | \033[01;32m${stats} lignes\033[00m${context_part}"