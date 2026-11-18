# CLRBX — conventions pour Claude

Projet : jeu Roblox commercial, développé par un développeur solo (le propriétaire) avec Claude comme développeur principal.
Objectif : revenus. Langue de travail avec le propriétaire : **français**.

## Workflow
- Code Luau dans `src/`, synchronisé dans Studio par Rojo (`default.project.json`). Ne jamais supposer qu'une modif faite seulement dans Studio existe dans le dépôt.
- Outils fixés dans `rokit.toml`. Avant chaque commit : `stylua src` puis `selene src`.
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
- Données joueur : une seule source (ProfileStore), sauvegarde à la sortie et périodique.

## Monétisation
- Game passes (achat unique) + produits de développeur (répétables) + récompenses de connexion.
- Pas de pay-to-win agressif ; respecter les règles Roblox (pas de loot box payante opaque, mentions des chances si tirage).
