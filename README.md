# Claude Code

## Informations de fonctionnement
Lorsque Claude code est instancié, il lit /home/nayte/.claude/CLAUDE.md.
Lorsqu'un sous-agent est instancié, Claude code va lui passer du contexte de son choix. Donc on peut dire précisément ce qui doit être passé comme contexte pour chaque sous-agent.

- Le texte en langage naturel que l'utilisateur écrit à l'agent est appelé le prompt.
- L’agent avec lequel l’utilisateur communique par le prompt est appelé l’orchestrateur.
- Un orchestrateur peut appeler par l’outil Task d’autres agents, par Task Delegation.
- Un sub-agent, appelé par Task delegation, ne peut pas faire de Task Delegation.

- Le fichier CLAUDE.md qui est dans un prokje est appelé "Project CLAUDE.md"
- Le fichier CLAUDE.md qui est installé sur la session (/home/foo/.claude/CLAUDE.md) est appelé "Global CLAUDE.md"

## La mémoire de Claude code
2 mémoires différentes, assez évidentes :
1. Pre-training Knowledge
Terminologie alternative : Training Data Knowledge, Parametric Knowledge, Parametric Memory, Static Knowledge, Model Weights
Nature : Intégrée dans les paramètres pendant l'entraînement
Caractéristiques :
Figée (cutoff janvier 2025 pour Sonnet)
Accessible instantanément
Généraliste mais parfois obsolète
2. Contextual Knowledge
Terminologie alternative : In-Context Learning, Dynamic Context, Contextual Memory, Dynamic Knowledge, Context Window
Nature : Acquise pendant les conversations
Sources :
Fichiers lus
URLs fetch
Résultats d'outils
Discussions
Exemple concret
  - Pre-training : Il "sait" que Symfony existe et connaît ses concepts généraux
  - Contextual : Si on lui donne le lien vers les docs Symfony 7.3, il apprend les spécificités de cette version pendant la conversation

## Context Window en détail
La context window est la "mémoire de travail" active, mesurée en tokens.

La limitation clé : Ma contextual knowledge est limitée par la taille de mon context window et disparaît à la fin de notre session. C'est pourquoi je dois parfois "re-fetcher" des infos même si on en a déjà parlé !

Signaux de saturation
Je "perds" des infos mentionnées plus tôt
Je redemande des choses déjà dites
Mes réponses deviennent moins contextuelles

### Composition du Context Window
[System Instructions] + [Conversation History] + [Tool Results] + [Current Input] = Total Context Window

### Caractéristiques
- Taille limitée : Variable selon le modèle (Claude Sonnet 4, plusieurs centaines de milliers de tokens)
- FIFO automatique : Quand c'est plein, les plus anciens éléments sont supprimés [Ancien] → [Moyen] → [Récent] → [Immédiat]
- Pas de nettoyage sélectif : ne peux pas “Oublier le contenu du fichier X”, le seul nettoyage se fait en FIFO
- Ignorance sélective : même si il ne peut pas “oublier”, on peut lui demander de ne pas prendre en compte certaines infos de sa context window
    - "Ne tiens pas compte de [élément spécifique] dans ton contexte"
    - "Considère uniquement [X] comme source de vérité"
    - "Utilise uniquement la version la plus récente de [fichier]"
- Éphémère : Disparaît complètement à la fin de la session

### Mauvaises pratiques
Ce qui consomme beaucoup de tokens :
- Gros fichiers lus avec Read
- Résultats de recherche massifs (Grep, Glob)
- Documentation fetchée avec WebFetch
- Historique long de conversation
- Outputs d'agents Task

#### erreur #1
> Ecrire dans son agent `git-manager.md`: "Lis tous les commits du repository officiel de Linux, charge toute la documentation de l'outil git et apprends tout son code en C pour avoir le même niveau d'expertise que son créateur" et ensuite "fais un commit avec mes dernières modifs." --> Cas clair de sur-qualification !

#### erreur #2
> Ecrire dans son agent `symfony-expert.md`: "Apprends toute la documentation de la version current" et ensuite l'appeler en task delegation 10 fois de suite pour 10 petites modifications --> Déperdition car à fin de tache déléguée l'instance est coupée et tout l'apprentissage a été fait pour rien !

### Bonnes pratiques

#### Optimisation avec Task Agent
Déléguer les recherches pour éviter de charger le contexte.
Mon Context Window:
 ├─ [Conversation history]
 ├─ [Rapport de l'agent - 500 tokens] ← Juste le résumé !
 └─ [Nouveaux échanges] ← Plein de place disponible

Sub-agent (session séparée):
 ├─ [GROS FICHIER - 50k tokens] ← Dans SA mémoire
 └─ [Travail terminé] ← Sa session se ferme, mémoire libérée

La différence clé :
Mes tokens persistent pendant toute notre conversation
Les tokens du sub-agent existent seulement pendant sa tâche, puis sont libérés

  Économie réelle :
  - Je reçois un résumé synthétique (500 tokens) au lieu du fichier brut (50k tokens)
  - Le sub-agent "digère" l'info et donne l'essentiel
  - Le context window reste "propre" pour la suite

C'est pourquoi une bonne pratique dans le CLAUDE.md est d'utiliser les agents spécialisés - ça économise le context window !

System Instructions (CLAUDE.md, etc.)
Tool Schemas & Configurations
MÉMOIRE CONVERSATIONNELLE
├─ Messages utilisateur
├─ Mes réponses
├─ Résultats d'outils
└─ Historique des échanges
Current Input & Working Memory


Quand on fait /clear :
✅ Mémoire conversationnelle → Cleaned
❌ System Instructions → Keeped
❌ Tool Schemas → Keeped
❌ Configurations → Keeped
Quand on termine la session :
✅ Tout le Context Window → Cleaned
Donc :
Mémoire conversationnelle = Juste nos échanges + résultats d'outils de cette conversation
Context Window = Tout ce qui est chargé dans ma "RAM" actuellement

C'est pourquoi après /clear il garde encore les instructions CLAUDE.md mais oublie ce dont on parlait.

## Sous agents

### Comment l’instance Claude code utilise les sous-agents
Il a 2 possibilités:
1. Task Delegation / Subtask Delegation
    - Terminologie alternative : "Subprocess delegation", "Subtask assignment"
    - Outil : Task
    - Principe : délègue une tâche à un agent spécialisé, il travaille en autonomie, l’instance principale reçoit son rapport
    - En écosystème multi-agents : orchestration indirecte (l’instance principale reste l'orchestrateur)
2. Agent Handoff / Control Transfer
    - Terminologie alternative : "Control handover", "Agent switching", "Direct agent routing"
    - Principe : transfère le contrôle directement à l'agent spécialisé qui devient l'assistant principal temporaire
    - En écosystème multi-agents : transfert direct de contrôle (l'autre agent prend le lead)

### Task
L'outil Task permet de déléguer des tâches spécifiques à des agents spécialisés qui possèdent leurs propres outils et domaines d'expertise. Chaque agent travaille de manière autonome et retourne un rapport final à Claude Code.

#### Communication stateless
- Chaque appel d'agent est indépendant
- Aucune mémoire partagée entre les appels
- Pas de communication bidirectionnelle possible

#### Fonctionnement autonome
- L'agent reçoit des instructions complètes via le paramètre prompt
- Il effectue tout le travail nécessaire de manière indépendante
- Il retourne un rapport final unique à Claude Code

### Spécialisation par domaine
Chaque agent dispose d'outils spécifiques à son domaine
Certains agents ont accès à tous les outils (*)
D'autres ont des restrictions d'outils selon leur spécialité

### Recommandations d'usage
Sélection proactive : Certains agents doivent être utilisés automatiquement selon le contexte
Instructions détaillées : Le prompt doit contenir toutes les informations nécessaires
Parallélisation : Possibilité de lancer plusieurs agents simultanément
Spécification du retour : Indiquer clairement les informations attendues dans le rapport final

### Limitations
Aucune interaction en temps réel avec les agents
Impossibilité d'envoyer des messages supplémentaires après le lancement
Les agents ne peuvent pas communiquer directement entre eux
Chaque agent n'a accès qu'aux informations fournies dans son prompt initial

### Plan mode 
placer l’ia en plan mode permet de concevoir des features sans coder. Si on a un gros abonnement, en faisant /model, on peut choisir “claude 4.1 pour les plans, 4.0 pour le code” ce qui est une bonne attribution de la puissance de frappe.
Status line
Une petite ligne placée sous la box input permet d’avoir un rappel rapide d’infos pertinentes. Ça se configure en demandant à claude, ou avec la commande /statusline.
Agents
Des agents sont des sous instanciations de claude code, que notre instance générale va piloter; l’avantage est qu’on peut leur réduire leur contexte pour avoir plus de puissance de frappe

Son lorsqu'une tâche est finie
Claude config set –global preferredNotifChannel terminal_bell

Utiliser agent de review (claude code.yml et claude_code_review.yml)

Créer des commandes custom, pour focus. Un prompt est en 3 parties : goal, rules, et steps.

Tester /ide et /terminalsetup

### Documentation et Liens utiles
https://www.anthropic.com/engineering/claude-code-best-practices
https://docs.anthropic.com/en/docs/claude-code/overview
https://www.anthropic.com/engineering/multi-agent-research-system
https://claudelog.com/mechanics/humanising-agents/
https://github.com/VoltAgent/awesome-claude-code-subagents/tree/main/categories
https://github.com/wshobson/agents
