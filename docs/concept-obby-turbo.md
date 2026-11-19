# Obby Turbo (nom provisoire) — concept « +1 Vitesse »

Genre « +1 Vitesse » : plus tu cours, plus tu vas vite ; tu traverses des parcours d'obstacles qui
rapportent des victoires ; les victoires débloquent de nouveaux mondes et achètent de l'équipement
qui accélère ta progression.

> Mécaniques de genre uniquement : mondes, parcours, noms et visuels sont **originaux**
> (copier les cartes, noms ou visuels d'un jeu existant expose à un retrait par Roblox).

## Boucle de jeu
1. **⚡ Vitesse (passif)** : +1 par seconde de course × multiplicateur d'équipement (× pass, × Turbo).
   Les **tapis de course** du lobby donnent de la vitesse sans bouger (débloqués par le total de victoires).
2. **Vitesse = vitesse de course réelle** (16 + Vitesse, plafonnée à 1 500). Limiteur 100/50/25/10 % (touche L).
3. **Parcours d'obstacles** (portails du lobby) : vides, lave, murs à contourner, haies, poutres étroites,
   3 points de contrôle. **L'arrivée rapporte des 🏆**, puis on repart du début (record de temps sauvegardé).
4. **Mondes** débloqués par le **total** de victoires (dépenser ne fait rien perdre).
5. **Équipement** (acheté en victoires) : 3 emplacements dont les multiplicateurs se **multiplient**.

## Mondes (Config/Worlds.luau)
| Monde | Débloqué à (total 🏆) | Longueur | Arrivée |
|---|---|---|---|
| Prairie | 0 | 600 | +5 |
| Désert | 100 | 1 000 | +20 |
| Royaume de glace (sol glissant) | 1 000 | 1 500 | +80 |
| Volcan | 8 000 | 2 200 | +300 |
| Espace | 50 000 | 3 000 | +1 200 |

## Équipement (Config/Equipment.luau)
| Emplacement | Pièces (prix 🏆 → multiplicateur) |
|---|---|
| ✨ Traînées | bleue 15 → ×1,25 · feu 60 → ×1,5 · arc-en-ciel 250 → ×2 · éclair 3 000 → ×3 |
| 🦸 Capes | rouge 40 → ×1,5 · bleue 150 → ×2 · or 1 500 → ×3 · cosmique 15 000 → ×5 |
| 🌟 Auras | étoilée 300 → ×2 · feu 5 000 → ×3 · cosmique 40 000 → ×5 |

Multiplicateur maximal d'équipement : 3 × 5 × 5 = **×75**.

## Anti-triche
Le serveur suit la position des joueurs : points de contrôle obligatoires dans l'ordre, déplacements
invraisemblables ignorés (téléportation), victoires et gains calculés côté serveur.

## Monétisation (Config/Monetization.luau, Id à créer après publication)
Passes **Vitesse ×2** et **Victoires ×2** ; produits **Turbo ×3 (10 min)**, **+100 🏆**, **+1 000 🏆**.

## Suite possible
**Renaissance** (remise à zéro de la Vitesse contre un multiplicateur permanent), mondes 6+,
compagnons (pets) avec multiplicateurs, classement des records par monde, obstacles mobiles.
