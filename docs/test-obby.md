# Test d'Obby Turbo

## Lancer
1. PowerShell : `cd $HOME\Documents\CLRBX`, puis `git pull`, puis `rojo serve` (laisser ouvert).
2. Studio (jeu arrêté) : Plugins → Rojo → **Connect** ; ouvrir **Fenêtre → Sortie** ; ▶.
3. Sortie : `[CLRBX] Serveur démarré (13 services)` et `[ProfileStore]: ... data will not be saved` (normal).

## Checklist
- [ ] Lobby : 5 portails au nord (Prairie ✅, les autres 🔒), tapis à droite, équipement à gauche (3 rangées).
- [ ] Panneau : Vitesse (+X/s), Victoires, Gains ×1, Course, « Prochain monde : Désert (100 🏆) », défi du jour.
- [ ] En courant : la Vitesse monte de +1/s et le personnage va de plus en plus vite.
- [ ] Bouton **🏃 100 % (L)** en bas : passe à 50 / 25 / 10 % → on ralentit vraiment.
- [ ] Tapis de bois : « +2 ⚡ » par seconde ; tapis de fer : message 🔒.
- [ ] Guide jaune : 1/4 courir → 2/4 portail Prairie (rayon) → 3/4 arrivée → 4/4 traînée bleue.
- [ ] Portail Prairie (E ou en courant dedans) : téléportation au départ, bandeau « 🌍 Prairie · 🚩 0/3 ».
- [ ] Obstacles : vides, lave (→ retour au dernier point de contrôle), murs avec ouverture, haies, poutres.
- [ ] Chute dans le vide → retour au dernier point de contrôle. Points de contrôle : « 🚩 1/3 », 2/3, 3/3.
- [ ] Arrivée : « 🏆 +5 victoires ! Prairie en X s », confettis, retour au départ ; record au 2e passage plus rapide.
- [ ] Bouton **🏠 Lobby** (dans un monde) : retour au lobby.
- [ ] Portail Désert avant 100 🏆 : « 🔒 il faut 100 🏆 au total ».
- [ ] Traînée bleue (15 🏆, maintenir E) : traînée derrière le personnage, « Gains ×1,25 », invite « Possédé ✅ ».
- [ ] Cape rouge, aura étoilée : visibles sur le personnage ; les gains se multiplient (×1,25 × 1,5 …).
- [ ] Glace : sol glissant ; ciel qui change de couleur selon le monde.

## À me renvoyer
- Tout message **rouge ou orange** de la Sortie (copier-coller).
- Ce qui ne marche pas, et ton ressenti : **vitesse de progression** (trop lente / trop rapide ?),
  **difficulté des obstacles**, envie de débloquer le monde suivant.
