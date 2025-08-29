 ## 🤖 Agents spécialisés - Usage automatique OBLIGATOIRE
    Les sub agents à utiliser sont dans agents/

     ### Git Manager - Utilisation OBLIGATOIRE dans ces cas :
     - **Analyse de commits** : Quand l'utilisateur demande d'identifier/analyser des modifications liées à un thème spécifique (qualité, sécurité, feature, etc.)
     - **Stratégie de commit** : Avant tout commit complexe impliquant plusieurs domaines/types de changements
     - **Historique git** : Pour toute analyse qui nécessite de comprendre l'évolution du code
     - **Mots-clés déclencheurs** : "commit", "historique", "pipeline", "qualité", "analyser les modifications"

     ### test-analyst - Utilisation OBLIGATOIRE dans ces cas :
     - **Analyse de tests** : Dès qu'il y a des fichiers de test modifiés/ajoutés
     - **Qualité de code** : Quand l'analyse concerne PHPStan, PHP-CS-Fixer, validation, standards
     - **Architecture de test** : Pour distinguer tests infrastructure vs tests métier
     - **Mots-clés déclencheurs** : "test", "qualité", "validation", "pipeline", "PHPUnit", "analyse statique"

     ### Symfony Manager - Utilisation OBLIGATOIRE dans ces cas :
     - **Projets développement Symfony** : TOUJOURS lancer @symfony-manager qui orchestrera l'équipe spécialisée
     - **Features Symfony** : Pour toute tâche de développement, configuration, ou architecture Symfony
     - **Multi-agents Symfony** : Quand plusieurs agents Symfony sont nécessaires (dev, test, database, frontend, i18n)
     - **AUCUNE EXCEPTION** : Même si l'utilisateur mentionne un agent spécifique par nom (Juliette, Database Admin, etc.), PASSER TOUJOURS par Symfony Manager d'abord sur les projets Symfony
     - **Tous composants Symfony inclus** : Translation/i18n, Doctrine, Twig, Assets, Security, etc. - tout passe par Symfony Manager
     - **Mots-clés déclencheurs** : "Symfony", "développement", "feature", "configuration", "composer", "doctrine", "twig", "translation"

     ### Règle générale :
     **TOUJOURS utiliser les agents spécialisés AVANT d'effectuer une analyse manuelle.** 
     L'analyse manuelle ne doit être qu'un complément, jamais le premier réflexe.
