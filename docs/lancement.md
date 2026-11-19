# Checklist de lancement (test 16+ de la semaine 4)

## 0. Avant de publier
- [ ] Toute la checklist `docs/test-vol.md` passe, **aucun message rouge** dans la Sortie.
- [ ] Test à 2 joueurs (Test → Clients et serveurs → 2) : vol, course à deux lignes, capes.

## 1. Publier
- Studio : **Fichier → Publier sur Roblox** → nouvelle expérience.
- Nom : **Course Céleste ✈️** (provisoire) · Genre : course / simulation · Appareils : tous (téléphone en priorité).
- Description (brouillon) :
  - FR : « Vole comme un super-héros ! Gagne de la vitesse, attrape les orbes, fonce dans la course du ciel
    et débloque des capes de plus en plus puissantes. Jusqu'où iras-tu ? »
  - EN : "Fly like a superhero! Build up speed, grab orbs, race through the sky and unlock
    more and more powerful capes. How far can you fly?"

## 2. Réglages du jeu (Studio → Paramètres du jeu)
- **Sécurité** → activer *l'accès de Studio aux services API* (pour tester la vraie sauvegarde).
- **Avatar** → type **R15 uniquement** (requis pour le taux DevEx majoré 18+ US ; nos clients PNJ sont en R15).
- **Monétisation** (Creator Hub → ton jeu) : créer les 3 passes et 4 produits, copier les Id dans
  `src/shared/Config/Monetization.luau` (voir README), republier.

## 3. Langues
- Langue source : **français**. Activer la **traduction automatique** (Creator Hub → Localisation) :
  les joueurs anglophones (la majorité des dépenses) verront les textes traduits automatiquement.
- Plus tard, si le jeu marche : passer la langue source en anglais pour une meilleure qualité.

## 4. Public et maturité
- Remplir le **questionnaire de maturité** : vol et course, pas de violence ni de sang,
  pas d'objet aléatoire payant → classement attendu *Minimal* ou *Mild*.
- Lancer d'abord **visible pour les 16+** (possible tout de suite), puis demander l'**examen tous âges**
  (vérification d'identité + 2FA + frais ou abonnement) une fois les premiers chiffres bons.

## 5. Visuels
- Icône + 3 à 5 miniatures **à partir de vraies captures** (vol bras tendu, course, capes).

## 6. Test publicitaire
- Ads Manager : 100 à 200 $ sur 3 à 5 jours, objectif « parties jouées ».
- Rappel : les joueurs venus par la pub ne comptent pas dans le classement ; la pub sert à faire tester le jeu.

## 7. Lire les chiffres (Creator Hub → Analytics), objectifs
| Indicateur | Objectif | Si c'est en dessous |
|---|---|---|
| Rétention J1 | ≥ 15 % | Revoir les 3 premières minutes (entonnoir d'accueil) |
| Rétention J7 | ≥ 4 % | Plus de raisons de revenir (défis, événements, collection) |
| Durée de session | ≥ 12 min | Plus de contenu entre deux Grands Chaudrons |
| Entonnoir d'accueil | < 20 % de perte par étape | Clarifier la consigne de l'étape qui décroche |
| Joueurs payants | ≥ 2 % | Revoir les prix / l'utilité des passes |

Règle de décision (rapport de phase 0) : si J1 reste **sous 10 %** après deux séries de corrections,
on change de concept plutôt que de polir.
