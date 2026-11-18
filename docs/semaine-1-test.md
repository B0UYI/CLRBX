# Semaine 1 — Test du prototype Potion Panique

## Lancer le test
1. PowerShell : `cd $HOME\Documents\CLRBX`, puis `git pull`, puis `rojo serve` (laisser ouvert).
2. Studio (jeu arrêté) : Plugins → Rojo → **Connect**.
3. Clique sur ▶. Dans **Fenêtre → Sortie** : `[CLRBX] Serveur démarré (7 services)`.

## Ce que tu dois voir
- Une boutique derrière le point d'apparition : sol en pierre, porte « POTION PANIQUE », comptoir, chaudron noir, 6 étagères avec des boules lumineuses, et le **grimoire** au mur du fond.
- Des messages d'accueil en haut de l'écran.
- Un client toutes les ~8 s, jusqu'à 3, qui s'avance au comptoir avec sa commande au-dessus de la tête.

## Checklist (coche ce qui marche)
- [ ] La bulle de chaque client indique les ingrédients de sa commande (ex. « Racine + Cristal »).
- [ ] **E** sur une étagère : l'ingrédient va dans ton **panier** (jusqu'à 3).
- [ ] **E** sur le chaudron : tout le panier est versé, le liquide change de couleur.
- [ ] **F** (sans maintenir) avec 2–3 ingrédients : « Ça mijote… » puis potion prête en ~1,5 s.
- [ ] **F** sur le chaudron prêt : tu reçois la potion.
- [ ] **E** sur le client avec la bonne potion : « +X pièces », la colonne **Pièces** (en haut à droite) augmente.
- [ ] Mauvaise potion à un client : il se transforme 😂
- [ ] Clic avec une potion en main : tu la bois, ton avatar change pendant 20 s.
- [ ] Mélange raté (ex. 3 fois le même ingrédient) : 💥 explosion, tu te transformes, sans dégâts.
- [ ] Client pas servi en 60 s : il repart « Trop lent… ».
- [ ] Les 3 clients arrivent tous au comptoir et marchent (animation).

## Nouveautés v3 à tester
- [ ] Panneau à gauche : niveau de boutique + barre, série, compte à rebours du Grand Chaudron, secrets 0/3.
- [ ] Au début, seulement 3 recettes commandées ; le grimoire montre les autres avec 🔒 et leur niveau.
- [ ] Après quelques services : « ⭐ La boutique passe niveau 2 », confettis, nouvelle recette dans le grimoire.
- [ ] Série : à 3 bonnes potions d'affilée, gains x1,5 ; une erreur annonce « Série perdue ».
- [ ] Clients 👑 VIP (fond doré, pas de recette affichée) et ⚡ PRESSÉS (fond rose, 25 s).
- [ ] À 1 min 30 : « LE GRAND CHAUDRON ! », clients plus fréquents, la cuve en verre (à droite de l'entrée) se remplit.
- [ ] Objectif atteint : 🎉 Fête des potions (confettis géants, tout le monde transformé, pièces bonus).
- [ ] Recette secrète : verse 3 fois le même ingrédient (essaie Plume ×3) → annonce, +50 pièces, ligne ✨ dans le grimoire.
- [ ] Son de caisse + confettis à chaque bon service.

## Nouveautés v4 à tester
- [ ] Sortie : `[ProfileStore]: Roblox API services unavailable - data will not be saved` (normal en Studio non publié).
- [ ] La colonne **Pièces** fonctionne comme avant.
- [ ] **Armoire du sorcier** (à gauche de l'entrée) : 5 présentoirs, maintenir E pour acheter.
- [ ] Pas assez de pièces → « Il te manque X pièces ». Achat → confettis + l'invite affiche « Déjà acheté ✅ ».
- [ ] Panier XL : 5 ingrédients. Bottes : tu cours plus vite (et tu le restes après une potion Éclair).
- [ ] Titre au-dessus de ta tête : « 🧪 Apprenti », puis « ⚗️ Alchimiste » / « 🧙 Grand Sorcier » après achat.
- [ ] Recette secrète : « 📖 Nouvelle recette dans ta collection ! +50 », panneau « Mes recettes secrètes 1/3 ».

## Limites connues (normal à ce stade)
- Sauvegarde réelle seulement une fois le jeu publié + accès API activé (voir README).
- Décor en blocs simples, sans son.

## À me renvoyer
- Les cases qui ne marchent pas.
- Tout message **rouge** de la fenêtre Sortie (copier-coller).
- Ton ressenti : est-ce qu'on comprend quoi faire sans explication ? Est-ce drôle ?

## Historique
- v1 : premier prototype.
- v4 : sauvegarde (ProfileStore), Armoire du sorcier (5 améliorations), titres, collection de secrets personnelle.
- v3 : Grand Chaudron + Fête des potions, recettes secrètes, niveau de boutique et déblocages,
  séries, clients VIP / pressés, panneau d'infos, confettis et sons.
- v2 (retours du 1er test) : recette affichée dans la bulle du client, panier de 3 ingrédients,
  plus aucune touche à maintenir, potion en 1,5 s, marche à 20, clients qui ne se bloquent plus
  entre eux (replacés s'ils restent coincés) et animation de marche.
