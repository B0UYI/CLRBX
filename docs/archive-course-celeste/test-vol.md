# Test de Course Céleste

## Lancer
1. PowerShell : `cd $HOME\Documents\CLRBX`, puis `git pull`, puis `rojo serve` (laisser ouvert).
2. Studio (jeu arrêté) : Plugins → Rojo → **Connect** ; ouvrir **Fenêtre → Sortie** ; ▶.
3. Sortie : `[CLRBX] Serveur démarré (14 services)` et `[ProfileStore]: ... data will not be saved` (normal).

## Checklist
- [ ] Lobby : grande place, tableau « 🏁 PROCHAINE COURSE 0:30 », tapis à droite, capes à gauche, nuages, orbes bleues.
- [ ] Panneau à gauche : Vitesse (+X/s), Victoires, Gains ×1, Vol m/s, défi du jour ; bandeau de course en haut.
- [ ] Guide jaune : « 1/5 · Monte sur le tapis de bois » + rayon vers le tapis.
- [ ] Sur le tapis de bois : « +2 ⚡ » chaque seconde, la Vitesse monte, la bande défile.
- [ ] Tapis de fer sans victoires : message « 🔒 il faut 20 🏆 au total ».
- [ ] **F** (ou bouton ✈️) : décollage. On vole vers où regarde la caméra, corps à l'horizontale, **bras tendu**.
      Espace = monter, Ctrl = descendre, sans touche = vol stationnaire debout. **F** à nouveau = atterrir.
- [ ] En volant : la Vitesse monte (+3/s). Passer dans une orbe : « +20 ⚡ », l'orbe disparaît puis revient.
- [ ] À 0:00 : envoi sur la ligne de départ dans le ciel, « 3, 2, 1 », puis **GO !** et vol automatique.
- [ ] Pendant la course : distance + zone + victoires au centre ; portiques colorés « Zone N · +X 🏆 ».
- [ ] Fin : retour au lobby, podium 🥇🥈🥉, « Course terminée : X m · +Y 🏆 ».
- [ ] Cape rouge (25 🏆, maintenir E) : cape sur le dos + traînée en vol, « Gains ×1,5 », invite « Possédée ✅ ».
- [ ] 🛒 Boutique (bouton à droite) : articles « Bientôt » (normal tant que les Id valent 0).
- [ ] Test à 2 joueurs (Test → Clients et serveurs → 2) : chacun voit l'autre voler bras tendu ; deux lignes en course.

## À me renvoyer
- Tout message **rouge ou orange** de la Sortie (copier-coller).
- Ce qui ne marche pas, et ton ressenti sur **la sensation de vol** (trop lent ? trop nerveux ?).
