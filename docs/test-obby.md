# Test d'Obby Turbo

## Lancer
1. PowerShell : `cd $HOME\Documents\CLRBX`, puis `git pull`, puis `rojo serve` (laisser ouvert).
2. Studio (jeu arrêté) : Plugins → Rojo → **Connect** ; ouvrir **Fenêtre → Sortie** ; ▶.
3. Sortie : `[CLRBX] Serveur démarré (16 services)` et `[ProfileStore]: ... data will not be saved` (normal).

## Checklist
- [ ] Lobby : portails au nord, **rangée 👣 Améliorations de pas** au sud, tapis à droite, équipement à gauche.
- [ ] Au-dessus de ta tête : nom, ⚡ Vitesse, niveau, forme.
- [ ] En bas : « Vitesse : X », ×Vitesse / ×Victoires, barre **Niveau N** qui se remplit en courant.
- [ ] Panneau : 👣 +1 par pas (+X/s), forme, course, prochain monde, défi du jour.
- [ ] Dalle « +2 / pas » (5 🏆, maintenir E) : la Vitesse monte 2× plus vite ; « +4 » refusée avant « +2 ».
- [ ] Portail Prairie : barre **1 → 10** en haut ; étape 1 = terrain plat + **une créature 👀** qui patrouille.
- [ ] Toucher la créature / lave / tomber → retour au début de l'étape en cours.
- [ ] Fin d'étape : « ✅ Étape 1 : +1 🏆 », la case 1 devient verte.
- [ ] Barrière rouge « ⚡ Vitesse requise » : bloque tant que tu es trop lent, devient verte et traversable ensuite.
- [ ] Étapes suivantes : plus de créatures, îlots sur la lave, vides, murs ; dès l'étape 3, **boulet qui roule**.
- [ ] Étape 10 : « 🏆 Prairie terminé en X s » puis retour au départ.
- [ ] 🧬 Évoluer : fenêtre Avant → Après ; au niveau 5 avec 5 🏆 → « Sprinteur », couleur sur l'avatar.
- [ ] Limiteur 🏃 (L), bouton 🏠 Lobby, 🛒 Boutique toujours là.

## À me renvoyer
- Tout message **rouge ou orange** de la Sortie (copier-coller).
- Ce qui ne marche pas, et ton ressenti : **vitesse de progression** (trop lente / trop rapide ?),
  **difficulté des obstacles**, envie de débloquer le monde suivant.
