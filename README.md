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
