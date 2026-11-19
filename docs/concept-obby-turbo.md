# Obby Turbo (nom provisoire) — concept « +1 Vitesse »

> Mécaniques de genre uniquement : mondes, parcours, noms, formes et visuels sont **originaux**.

## Boucle de jeu
1. **Pas** : chaque pas rapporte des points de ⚡ Vitesse = valeur du pas × multiplicateurs
   (évolution × équipement × pass × Turbo). Le serveur compte les pas (1 pas / 4 studs, 8 pas/s max).
2. **Améliorations de pas** (rangée du lobby, achetées dans l'ordre en 🏆) : +1 → +2 000 par pas.
3. **Tapis** : pas automatiques (2 à 10/s) sans bouger, débloqués par le total de victoires.
4. **Niveau** : barre remplie par la Vitesse (10 × 1,18^(n-1) points par niveau).
5. **Vitesse de course** = 16 + Vitesse^0,6 (plafond 1 500), limiteur 100/50/25/10 % (touche L).
6. **Mondes en 10 étapes** : barrière « ⚡ vitesse requise » à l'entrée de chaque étape, obstacles de
   plus en plus durs (créatures qui patrouillent, îlots sur la lave, vides, murs, haies, poutres,
   boulet qui roule dès l'étape 3), **victoires à la fin de chaque étape**, réapparition à l'étape.
7. **Évolution** (bouton 🧬) : niveau requis + victoires payées → forme suivante (×1,1 → ×8).
8. **Équipement** : traînées, capes, auras (multiplicateurs multipliés, jusqu'à ×75).

## Étapes (Config/Worlds.luau)
| Monde | Débloqué (total 🏆) | 🏆 étape 1 → 10 | ⚡ requise étape 2 → 10 |
|---|---|---|---|
| Prairie | 0 | 1 → 20 (64 au total) | 10 → 1 101 |
| Désert | 100 | 8 → 165 | 1 500 → 64 K |
| Glace | 1 000 | 60 → 1 239 | 80 K → 2 M |
| Volcan | 8 000 | 400 → 8 264 | 3 M → 77 M |
| Espace | 50 000 | 2 500 → 51 652 | 100 M → 2,5 B |

## Évolutions (Config/Evolutions.luau)
Débutant ×1 · Sprinteur ×1,1 (niv. 5, 5 🏆) · Fusée ×1,25 (niv. 12, 30) · Éclair ×1,5 (niv. 20, 150) ·
Comète ×2 (niv. 30, 800) · Météore ×3 (niv. 45, 5 K) · Supernova ×5 (niv. 65, 40 K) · Légende cosmique ×8 (niv. 90, 300 K).

## Anti-triche
Pas comptés par le serveur ; étapes dans l'ordre ; barrière franchie sans la vitesse requise = retour ;
téléportations ignorées ; victoires, achats et évolutions validés côté serveur.

## À venir (repéré chez la concurrence)
Renaissance, événement de course à heure fixe, packs de Vitesse en Robux en bas de l'écran et
pack de démarrage limité, codes, cadeaux de temps de jeu, index/collection.
