# CLRBX — conventions pour Claude

Projet : jeu Roblox commercial, développé par un développeur solo (le propriétaire) avec Claude comme développeur principal.
Objectif : revenus. Langue de travail avec le propriétaire : **français**.

## Workflow
- Code Luau dans `src/`, synchronisé dans Studio par Rojo (`default.project.json`). Ne jamais supposer qu'une modif faite seulement dans Studio existe dans le dépôt.
- Outils fixés dans `rokit.toml`. Avant chaque commit : `stylua src` puis `selene src`.
- Sans Studio sous la main : `python3 -I tools/check_roblox_api.py <globalTypes.None.d.luau> src` doit afficher 0 erreur (voir `tools/README.md`).
- Quand une action revient au propriétaire (Studio manuel, compte Roblox, argent, publication), la lister clairement sous un titre « Tes tâches ».

## Architecture
- `src/server/Services/*` : ModuleScripts avec `Init()` puis `Start()`, chargés par `init.server.luau`.
- `src/client/Controllers/*` : même modèle côté client.
- `src/shared/Config/*` : toutes les valeurs d'équilibrage (prix, gains, temps) — jamais de nombres magiques dans la logique.
- `--!strict` en tête de chaque fichier.

## Sécurité (anti-triche)
- Le serveur fait autorité sur la monnaie, l'inventaire, la progression et les achats.
- Tout RemoteEvent/RemoteFunction valide types, bornes et cadence (rate limit) de ses arguments côté serveur.
- Achats : `MarketplaceService.ProcessReceipt` idempotent, reçu enregistré avant d'accorder.
- Données joueur : une seule source, `DataService` (ProfileStore copié dans `src/server/Packages/`, licence dans `third_party/`). Ne jamais modifier ce fichier tiers ; il est exclu de StyLua/Selene.
- Studio non publié = mode simulé (rien n'est sauvegardé) : normal.

## Monétisation
- Game passes (achat unique) + produits de développeur (répétables) + récompenses de connexion.
- Pas de pay-to-win agressif ; respecter les règles Roblox.
- Objet aléatoire payant : chances affichées avant achat (et mises à jour si boost actif) + vérifier `PolicyService:GetPolicyInfoForPlayerAsync` (`ArePaidRandomItemsRestricted`, `IsPaidItemTradingAllowed`) et bloquer selon le pays.
- Avatars en R15 (éligibilité au taux DevEx majoré 18+ US).

## Recherche
- Rapport de phase 0 : `reports/Concepts de jeu Roblox rentables.md` (notes dans `research_notes/`).
