# CLRBX

Jeu Roblox — code Luau géré avec [Rojo](https://rojo.space) et synchronisé dans Roblox Studio.

## Installation (Windows, une seule fois)

1. Installer [Roblox Studio](https://create.roblox.com/), [VS Code](https://code.visualstudio.com/), [Git](https://git-scm.com/download/win) et [Rokit](https://github.com/rojo-rbx/rokit).
2. Redémarrer le PC (pour que Rokit soit reconnu).
3. Dans PowerShell :

```powershell
cd $HOME\Documents
git clone https://github.com/B0UYI/CLRBX.git
cd CLRBX
rokit install
```

4. Installer le plugin Rojo dans Studio : `rojo plugin install`.

## Travailler au quotidien

```powershell
cd $HOME\Documents\CLRBX
git pull
rojo serve
```

Puis dans Studio : ouvrir le place du jeu → onglet **Plugins** → **Rojo** → **Connect**.
Le code du dépôt apparaît dans Studio et se met à jour en direct.

## Organisation

| Dossier | Destination dans Studio | Rôle |
|---|---|---|
| `src/server` | `ServerScriptService.Server` | Logique serveur (fait autorité) |
| `src/client` | `StarterPlayerScripts.Client` | Interface et contrôles du joueur |
| `src/shared` | `ReplicatedStorage.Shared` | Config et utilitaires communs |
| `docs` | — | Conception, économie, notes |

Les cartes, modèles 3D et décors se construisent dans Studio ; seul le code vit dans ce dépôt.

## Sauvegarde des données

Les données joueur (pièces, améliorations, recettes secrètes) sont gérées par `DataService` avec
[ProfileStore](https://github.com/MadStudioRoblox/ProfileStore) (copié dans `src/server/Packages/`).

- En Studio, tant que le jeu n'est **pas publié**, la Sortie affiche
  `Roblox API services unavailable - data will not be saved` : le jeu marche, mais rien n'est gardé.
- Pour tester la vraie sauvegarde : publier le jeu (Fichier → Publier sur Roblox), puis
  **Paramètres du jeu → Sécurité → Activer l'accès de Studio aux services API**.

## Activer les achats Robux (après publication)

1. Publier le jeu, puis sur le [Creator Hub](https://create.roblox.com/) : ton jeu → **Monétisation**.
2. Créer les **Passes** (Pièces ×2, VIP, Chaudron express) et les **Produits de développeur**
   (Potion farce, Sac / Coffre / Trésor de pièces) avec leur image et leur prix.
3. Copier chaque identifiant dans `src/shared/Config/Monetization.luau` (champ `Id`), puis publier.
   Tant qu'un `Id` vaut 0, l'article apparaît « Bientôt » dans la boutique.
