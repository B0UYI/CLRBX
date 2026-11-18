# Outils

## check_roblox_api.py — vérifier l'usage de l'API Roblox sans Studio

Détecte les erreurs qui planteraient à l'exécution : `Enum.X.Y` inexistant, classe ou service inconnu,
propriété ou méthode inexistante sur un objet dont la classe est connue, champ inexistant
(`Vector3.neww`…). Heuristique, mais testée sur des erreurs volontaires.

Il lui faut le fichier de définitions de l'API Roblox du projet open source luau-lsp
(simple fichier de données, rien n'est compilé) :

```bash
git clone --depth 1 https://github.com/JohnnyMorganz/luau-lsp /tmp/luau-lsp
python3 -I tools/check_roblox_api.py /tmp/luau-lsp/scripts/globalTypes.None.d.luau src
```

Résultat attendu : `0 erreur(s)`. Le dossier `src/server/Packages` (code tiers) est ignoré.
