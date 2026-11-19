# Test d'Obby Turbo

## Lancer
1. PowerShell : `cd $HOME\Documents\CLRBX`, puis `git pull`, puis `rojo serve` (laisser ouvert).
2. Studio (jeu arrêté) : Plugins → Rojo → **Connect** ; ouvrir **Fenêtre → Sortie** ; ▶.
3. Sortie : `[CLRBX] Serveur démarré (17 services)` et `[ProfileStore]: ... data will not be saved` (normal).

## Checklist
- [ ] Lobby : portails (Ciel ✅…), rangée 👣 des pas, tapis, équipement ; bouton ✈️ en bas à droite.
- [ ] **F** : décollage, vol vers la caméra, bras tendu ; Espace monte, Ctrl descend.
- [ ] Barre **🔋 Endurance** en bas : baisse en vol, remonte posé au sol ; à 0 → « Plus d'endurance », chute.
- [ ] **Maj** (ou 🚀) en vol : plus rapide, l'endurance baisse 3× plus vite.
- [ ] Portail Ciel : plateforme de départ, panneau « Étape 1 · 100 m · 🔋 3 s · niveau 1 ».
- [ ] Voler jusqu'à la plateforme suivante : « ✅ Étape 1 : +1 🏆 », endurance rechargée, case 1 verte.
- [ ] Tomber dans le vide → retour sur la dernière plateforme.
- [ ] Étapes suivantes plus longues : il faut plus de niveau (s'entraîner, acheter des pas).
- [ ] (Plus tard) Ville : passer entre les buildings · Glacier : toucher la glace = retour · Volcan : flammes
      qui s'allument en vague · Espace : astéroïdes.
- [ ] 🧬 Évoluer, 👣 +2 / pas, équipement, 🛒 Boutique : comme avant.

## Sensation de vol (v2)
- [ ] Posture : bras droit tendu, bras gauche le long du corps, genou gauche plié (vu aussi par un 2e joueur).
- [ ] En virage, le corps s'incline ; sans commande, on plane sur sa lancée.
- [ ] Plus on va vite, plus le champ de vision s'élargit ; lignes de vitesse ; légère vibration à très haute vitesse.
- [ ] Plus de disques de vent systématiques (mécanique gardée en réserve, désactivée : `WindRings` dans Config/Worlds).
- [ ] Décollage : petite poussée vers le haut + onde de choc au sol.
- [ ] Boost à vitesse max : « mur du son » (double onde + son), une fois par boost.
- [ ] Caméra qui s'incline dans les virages, flou de vitesse, couleurs plus vives, son de vent qui monte avec la vitesse.
- [ ] Traînées lumineuses aux mains au-delà d'une certaine vitesse.
- [ ] À pied : vitesse de marche normale (16), jamais modifiée par la Vitesse.

## Biomes et décors (v3)
- [ ] Dessous rocheux sous chaque plateforme flottante.
- [ ] Ciel : mer de nuages, îles herbeuses flottantes avec arbres et cascades.
- [ ] Ville : sol, avenues, tours avec fenêtres éclairées, antennes à feu rouge, enseignes néon.
- [ ] Glacier : banquise, icebergs, cristaux, neige ; cadres néon autour des ouvertures.
- [ ] Volcan : mer de lave, volcans fumants, aiguilles de basalte, braises ; buses et vraies flammes.
- [ ] Espace : étoiles, planètes (une avec anneau), nébuleuses, stations.
- [ ] Indique-moi si ça rame (images/seconde) dans un monde précis.
- [ ] Textes (étapes, achats, tapis, portails) : petits de loin, lisibles de près, ne bouchent plus l'écran.
- [ ] Si l'inclinaison part du mauvais côté dans les virages, dis-le-moi (un signe à inverser).

## À me renvoyer
- Tout message **rouge ou orange** de la Sortie (copier-coller).
- Ce qui ne marche pas, et ton ressenti : **vitesse de progression** (trop lente / trop rapide ?),
  **difficulté des obstacles**, envie de débloquer le monde suivant.
