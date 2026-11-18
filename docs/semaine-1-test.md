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
- [ ] **E** sur une étagère : l'ingrédient apparaît dans ta main.
- [ ] **E** sur le chaudron : l'ingrédient est versé, le liquide change de couleur.
- [ ] **F** (maintenir) avec 2–3 ingrédients : « Ça mijote… » puis potion prête.
- [ ] **F** sur le chaudron prêt : tu reçois la potion.
- [ ] **E** sur le client avec la bonne potion : « +X pièces », la colonne **Pièces** (en haut à droite) augmente.
- [ ] Mauvaise potion à un client : il se transforme 😂
- [ ] Clic avec une potion en main : tu la bois, ton avatar change pendant 20 s.
- [ ] Mélange raté (ex. 3 fois le même ingrédient) : 💥 explosion, tu te transformes, sans dégâts.
- [ ] Client pas servi en 60 s : il repart « Trop lent… ».

## Limites connues (normal à ce stade)
- Les clients glissent sans animation de marche.
- Les pièces ne sont pas sauvegardées (semaine 2).
- Décor en blocs simples, sans son.

## À me renvoyer
- Les cases qui ne marchent pas.
- Tout message **rouge** de la fenêtre Sortie (copier-coller).
- Ton ressenti : est-ce qu'on comprend quoi faire sans explication ? Est-ce drôle ?
