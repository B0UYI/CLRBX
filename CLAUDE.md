# CLRBX — conventions pour Claude

Projet : jeu Roblox commercial « Obby Turbo » (nom provisoire) — genre « +1 Vitesse » en VOL : parcours aériens par biomes, endurance de vol, mondes, équipement multiplicateur (voir `docs/concept-obby-turbo.md`), développé par un développeur solo (le propriétaire) avec Claude comme développeur principal.
Anciens concepts archivés : branches `archive/potion-panique-v8` et `archive/course-celeste-v1`.
Reprendre des MÉCANIQUES de genre, jamais les noms, cartes, personnages ou visuels d'un jeu existant (propriété intellectuelle).
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
- Le déplacement/vol est piloté par le client (vitesses publiées par le serveur) mais l'ENDURANCE est gérée par le serveur (il coupe le vol à 0) ; la Vitesse ne rapporte que par le temps (gain/s) ; points de contrôle et arrivée sont détectés par le serveur (suivi de position, ordre obligatoire, téléportations ignorées).
- Tout RemoteEvent/RemoteFunction valide types, bornes et cadence (rate limit) de ses arguments côté serveur.
- Achats : `MarketplaceService.ProcessReceipt` idempotent, reçu enregistré avant d'accorder.
- Données joueur : une seule source, `DataService` (ProfileStore copié dans `src/server/Packages/`, licence dans `third_party/`). Ne jamais modifier ce fichier tiers ; il est exclu de StyLua/Selene.
- Studio non publié = mode simulé (rien n'est sauvegardé) : normal.

## Monétisation
- Game passes (achat unique) + produits de développeur (répétables) + récompenses de connexion.
- Monnaie : 🏆 Victoires (équipement). Progression : ⚡ Vitesse (stat, jamais dépensée) ; mondes et tapis débloqués par le TOTAL de victoires.
- Pas de pay-to-win agressif ; respecter les règles Roblox.
- Objet aléatoire payant : chances affichées avant achat (et mises à jour si boost actif) + vérifier `PolicyService:GetPolicyInfoForPlayerAsync` (`ArePaidRandomItemsRestricted`, `IsPaidItemTradingAllowed`) et bloquer selon le pays.
- Avatars en R15 (éligibilité au taux DevEx majoré 18+ US).

## Recherche
- Rapport de phase 0 : `reports/Concepts de jeu Roblox rentables.md` (notes dans `research_notes/`).
