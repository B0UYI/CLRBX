# Obby Turbo (nom provisoire) — concept « +1 Vitesse »

> Mécaniques de genre uniquement : mondes, parcours, noms, formes et visuels sont **originaux**.

## Boucle de jeu (parcours AÉRIENS)
1. **Vol** façon super-héros (F / ✈️), direction de la caméra, bras tendu. **Boost** (Maj / 🚀) : ×1,8 vitesse.
2. **🔋 Endurance** (la stat clé, gérée par le serveur) : 6 s + 1 s par niveau. Le vol la vide
   (×3 en boost, × l'atmosphère du monde) ; elle ne remonte que posé au sol. À 0 : on tombe.
3. **Étape = vol continu** d'une plateforme à la suivante → sans le niveau, on retourne s'entraîner
   sur les étapes précédentes. Panneau d'entrée : longueur, endurance conseillée, niveau conseillé.
4. **Pas** (à pied ET en vol) : points de Vitesse × multiplicateurs → Niveau → Endurance.
   Améliorations de pas (lobby, en 🏆), tapis (pas automatiques), évolution, équipement.
5. **Victoires** à chaque plateforme d'étape atteinte (endurance rechargée), mondes débloqués au total.

## Mondes (Config/Worlds.luau)
| Monde | Biome | Débloqué (total 🏆) | Atmosphère | Endurance conseillée ét. 1 → 10 | Niveau conseillé |
|---|---|---|---|---|---|
| Ciel | nuages, anneaux | 0 | ×1 | 3 → 13 s | 1 → 8 |
| Ville | rangées de buildings avec une brèche | 100 | ×3 | 12 → 34 s | 7 → 29 |
| Glacier | murs de glace **mortels** à petite ouverture | 1 000 | ×6 | 24 → 60 s | 19 → 55 |
| Volcan | ligne droite, **flammes en vague par cycles** (boost) | 8 000 | ×13 | 43 → 100 s | 38 → 95 |
| Espace | astéroïdes **mortels** en mouvement | 50 000 | ×28 | 77 → 181 s | 72 → 176 |

## Évolutions (Config/Evolutions.luau)
Débutant ×1 · Sprinteur ×1,1 (niv. 5, 5 🏆) · Fusée ×1,25 (niv. 12, 30) · Éclair ×1,5 (niv. 20, 150) ·
Comète ×2 (niv. 30, 800) · Météore ×3 (niv. 45, 5 K) · Supernova ×5 (niv. 65, 40 K) · Légende cosmique ×8 (niv. 90, 300 K).

## Anti-triche
Endurance gérée par le serveur (il coupe le vol) ; pas comptés par le serveur ; étapes dans l'ordre ;
téléportations ignorées ; victoires, achats et évolutions validés côté serveur.

## À venir (repéré chez la concurrence)
Renaissance, événement de course à heure fixe, packs de Vitesse en Robux en bas de l'écran et
pack de démarrage limité, codes, cadeaux de temps de jeu, index/collection.
