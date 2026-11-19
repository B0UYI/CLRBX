# Course Céleste (nom provisoire) — concept

Jeu de **course en vol** façon super-héros : on progresse en vitesse dans le lobby, on la convertit
en victoires pendant les courses, et les victoires achètent des capes qui accélèrent la progression.

> Pas de nom, logo ni costume de super-héros existant (propriété intellectuelle) :
> on reprend seulement le **style de vol**. Nom du jeu modifiable dans `Config/Gameplay.luau`.

## Boucle de jeu
1. **Gagner de la ⚡ Vitesse** dans le lobby :
   - **voler** (touche F / bouton ✈️) : +3/s en mouvement ;
   - **orbes** bleues dans le ciel : +20 chacune (30 orbes, réapparaissent) ;
   - **tapis de course** : gain passif (+2 → +500/s), débloqués par le **total** de victoires.
2. **Course** toutes les ~45 s (compte à rebours sur le tableau du lobby) : tout le monde est envoyé
   sur la piste dans le ciel, vol automatique pendant 20 s. Plus la Vitesse est haute, plus on va loin.
   Chaque **zone** franchie rapporte des **🏆 Victoires** ; l'arrivée donne un bonus.
3. **Capes** (achetées en victoires) : multiplient tous les gains de Vitesse (×1,5 → ×15).

Tous les gains sont multipliés : **cape × pass Vitesse ×2 × Turbo**.

## Équilibrage (Config/Race.luau)
| Vitesse | Vitesse de course | Distance (20 s) | Victoires / course |
|---|---|---|---|
| 0 | 40 m/s | 800 m | 7 |
| 100 | 80 m/s | 1 595 m | 21 |
| 1 000 | 140 m/s | 2 797 m | 57 |
| 10 000 | 291 m/s | 5 816 m | 140 |
| 100 000 | 670 m/s | 13 400 m | 494 |
| ≈ 200 000 | 870 m/s (max) | 17 246 m (arrivée) | 734 + 50 |

| Cape | Prix | Gains |
|---|---|---|
| Rouge | 25 🏆 | ×1,5 |
| Bleue | 100 🏆 | ×2 |
| Verte | 400 🏆 | ×3 |
| Or | 1 500 🏆 | ×5 |
| Arc-en-ciel | 6 000 🏆 | ×8 |
| Cosmique | 25 000 🏆 | ×15 |

| Tapis | Gain | Débloqué à (total 🏆) |
|---|---|---|
| Bois | +2/s | 0 |
| Fer | +8/s | 20 |
| Or | +30/s | 150 |
| Diamant | +120/s | 1 000 |
| Cosmique | +500/s | 6 000 |

## Monétisation (Config/Monetization.luau, Id à créer après publication)
- Passes : **Vitesse ×2** (199 R$), **Victoires ×2** (299 R$).
- Produits : **Turbo ×3 10 min** (49 R$), **+100 🏆** (99 R$), **+1 000 🏆** (499 R$).

## Rétention
Cadeau de connexion en victoires (série de jours), défi du jour (5 courses), guide des nouveaux
joueurs en 5 étapes (tapis → vol → orbe → course → cape) suivi dans Roblox Analytics.

## Suite possible
Renaissance (remise à zéro contre un multiplicateur permanent), deuxième monde/piste,
animaux de compagnie, classements, événements « course spéciale » à heure fixe.
