# Opportunités et contraintes pour un développeur Roblox SOLO (fin 2026)

> Note méthodologique : recherche faite le 18/11/2026. Le réseau de cette session bloquait la lecture complète de la plupart des sites (devforum.roblox.com, naavik.co, rolearn.dev, rowatcher.com, wikipedia, ggrecon). Les informations ci-dessous viennent donc des **extraits et synthèses des résultats de recherche**, pas d'une lecture intégrale des pages. Les chiffres de revenus par jeu sont presque tous des **estimations tierces** (trackers), sauf mention contraire. Pour lire les pages en entier, ces domaines doivent être autorisés dans les paramètres réseau de la session.

## 1. Genres/mécaniques faisables surtout avec du code, de l'UI et peu d'assets 3D, et genres à éviter

### Takeaway
Les succès récents les plus massifs (Grow a Garden, Steal a Brainrot, les jeux « +1 ») reposent sur des boucles incrémentales, de collection et d'économie sociale, avec un art simple. Ce type de jeu est presque entièrement systémique (code, données, UI) : c'est le meilleur terrain pour un solo assisté par IA. Les genres que Roblox dit lui-même sous-représentés (RPG, stratégie, shooter) et le co-op survie/horreur exigent plus de contenu (cartes, animations, IA d'ennemis). Ils sont donc risqués en solo, sauf avec un périmètre très réduit.

### Cited Findings
- Grow a Garden : la première version a été construite en quelques jours (3 jours selon Jandel) par un ado de 16 ans (BMWLux) — [Calcalist](https://www.calcalistech.com/ctechnews/article/dj4lxef8r) ; [résultat de recherche citant Wikipedia](https://en.wikipedia.org/wiki/Grow_a_Garden)
- Les jeux « steal » dominent en 2026. Selon une analyse du top 100, 4 jeux avec « steal » dans le nom captaient 29,5 % des joueurs, et Steal An Egg aurait atteint 1,6 M de joueurs simultanés en septembre 2026 (source agrégatrice, à vérifier) — [Studiokrew, Top Roblox Games Sept 2026](https://studiokrew.com/blog/top-roblox-games-september-2026/) ; [playqub.it](https://playqub.it/blog/most-played-roblox-games/)
- Un tracker compte 15 jeux « +1 » (incrémental simple) dans les classements. +1 Speed Keyboard était 5e du top 20 de juillet 2026, mais la même source note des **signes de fatigue** du public pour les simulateurs incrémentaux — [Forgeguides, top 20 juillet 2026](https://forgeguides.com/en/guides/roblox-top-20-most-played-games-july-2026/)
- Les tycoons reviennent en mélangeant progression incrémentale, multijoueur social et thèmes memes — [Forgeguides](https://forgeguides.com/guides/roblox-top-20-most-played-games-july-2026/)
- Des « contre-jeux » apparaissent, comme Fake an Egg, qui joue sur la mode des jeux de vol d'œufs — [Studiokrew](https://studiokrew.com/blog/top-roblox-games-september-2026/)
- L'horreur progresse : environ 77,7K CCU sur 5 jeux et +68 % en une semaine début 2026 (source SEO, faible fiabilité) — [creation.dev](https://www.creation.dev/learn/best-roblox-game-ideas-2026)
- Un rapport tiers cite la complexité technique comme principal risque du co-op survie — [ROLearn, Emerging genres Q2 2026](https://rolearn.dev/trend-reports/emerging-roblox-game-genres-q2-2026/)
- Un dev solo de jeu de destruction physique, après 3 mois de travail, a eu des pics de bande passante réseau (« HUGE spike in network receive ») et des retours sur une UI trop chargée — [DevForum playtest](https://devforum.roblox.com/t/playtest-3-months-of-solo-dev-physics-based-destruction-game-need-your-feedback/4045166)
- Un dev solo construit « World of Rocraft », un MMO inspiré de WoW (quêtes, combat, cinématique), révélé le 19/09/2026. Aucun chiffre de joueurs n'est publié — [VGTimes](https://vgtimes.com/gaming-news/168194-solo-developer-is-building-world-of-rocraft-a-warcraft-inspired-roblox-game.html)

### Inferences
- **Bonnes options pour ce profil** : incrémental/idle multijoueur, tycoon social, collection et échange (pets, items avec raretés), « steal/defend » léger, économie et marché entre joueurs, jeux de gestion à l'écran (comptoir, file de clients), party games à manches courtes, obby procédural, simulation de métier avec des modèles de base, puzzle co-op. Tous peuvent tourner avec des primitives, du low-poly gratuit du Creator Store, des particules et une UI soignée.
- **Mauvaises options** : RPG narratif ou à quêtes, open world, shooter compétitif (netcode, anti-triche, animations), horreur scriptée (level design et ambiance coûteux), sports compétitifs (physique et animation), survie co-op riche en contenu.
- Le « look » simple n'empêche pas le succès, mais le thème doit être lisible tout de suite : memes, animaux, nourriture, objets du quotidien.

### Gaps
- Je n'ai trouvé aucune source qui chiffre la part des top jeux faits avec peu d'assets custom. Cette conclusion est une inférence.

## 2. Succès documentés de solos ou de très petites équipes (2024–2026)

### Takeaway
Les « succès solo » médiatisés sont rarement restés solo. Grow a Garden a été repris par un studio et Steal a Brainrot est sorti sous un label (DoBig Studios) avec une communauté existante. Le dénominateur commun est un prototype rapide (quelques jours à quelques semaines), une boucle virale, puis des mises à jour intensives. Les revenus typiques des petits jeux restent très modestes.

### Cited Findings
- Grow a Garden (lancé en mars 2025) : 12 M$ de revenus en mai 2025 (presse). Le studio Splitting Point (Janzen Madsen) a acquis une part du jeu et a agrandi l'équipe — [Calcalist](https://www.calcalistech.com/ctechnews/article/dj4lxef8r). Record de 21,6 M de joueurs simultanés fin juin 2025 — [News4Jax/AP](https://www.news4jax.com/business/2025/07/30/millions-are-flocking-to-grow-virtual-gardens-in-viral-roblox-game-created-by-teenager/). « Dizaines de millions par mois au pic » (reportedly) — [Windows Central](https://www.windowscentral.com/gaming/teens-becoming-millionaires-making-games-in-roblox)
- TD Cowen a accusé des bots d'avoir gonflé la visibilité de Grow a Garden dans l'algorithme, ce que Roblox conteste (allégation non prouvée) — [résultat citant Wikipedia](https://en.wikipedia.org/wiki/Grow_a_Garden)
- Steal a Brainrot : lancé le 16/05/2025 par SpyderSammy (Sam Brakta) sous DoBig Studios. Il a racheté les droits d'un jeu antérieur, « Steal a Character », et l'a amélioré avec le thème Italian brainrot venu de TikTok. Il est aussi lié à une communauté Roblox de près de 22 M de membres — [Eldorado.gg](https://www.eldorado.gg/blog/steal-a-brainrot-en/sammy-steal-a-brainrot-guide/) ; [The Star](https://www.thestar.com.my/tech/tech-news/2026/03/25/robloxs-hit-game-steal-a-brainrot-battles-its-many-imitators)
- Revenus estimés de Steal a Brainrot : environ 11 M$/mois selon une estimation d'août 2025 (modèle d'hypothèses), contre 1,4 à 4,4 M$/mois en octobre 2026 selon RoWatcher et Profitable.app. Ce sont des estimations tierces qui se contredisent — [Eldorado.gg](https://www.eldorado.gg/blog/steal-a-brainrot-en/sammy-steal-a-brainrot-guide/)
- Bee Swarm Simulator (Onett) est maintenu presque seul. Ses revenus cumulés estimés (non confirmés) sont d'environ 256 M$ — [synthèse de recherche, rowatcher.com](https://rowatcher.com/news/from-bedroom-to-billions-how-solo-developers-built-roblox-empires)
- Un étudiant solo a fait un jeu d'esquive. Après l'arrêt des pubs, le jeu a décollé organiquement jusqu'à 900 CCU et a reçu une offre de rachat de 24 000 $ pour 70 %, refusée. Des mises à jour (battle pass, clans, cosmétiques) l'ont ensuite porté à plus de 20 M de visites et plus de 7 000 CCU en 2 mois (récit, timeline non vérifiée) — [daily.dev](https://daily.dev/posts/i-made-a-successful-roblox-game-to-prove-it-s-not-luck-mds7nwwho)
- Un créateur dit avoir fait un jeu en 3 à 4 jours, avec un pic de 2 100 CCU, environ 6 M de visites, jusqu'à 97 000 Robux en un jour et environ 1,39 M Robux en 56 jours (auto-déclaré) — [sozai.app transcript](https://sozai.app/transcript/2k-ccu-roblox-game-earnings/)
- « Build a Base and Steal » : environ 119 300 $/mois et 38K CCU au pic. Le jeu est co-détenu, pas solo — [sozai.app](https://sozai.app/transcript/roblox-game-119300-month-38k-ccu/)
- Un jeu à 13,1K CCU déclaré à 25 070 $/mois (auto-déclaré YouTube) — [sozai.app](https://sozai.app/transcript/made-25070-month-roblox-game/)
- Données officielles : le top 1 000 des créateurs a touché 1,3 M$ en moyenne en 2025, et le créateur DevEx médian a touché 1 550 $ sur 12 mois — [Roblox, Monetize](https://create.roblox.com/docs/monetize)
- Réalité du bas du marché : sur le DevForum, des devs rapportent 5 à 10 CCU en moyenne, et un jeu à environ 10K visites en une semaine n'a rapporté que 80 Robux de Creator Rewards — [DevForum, Creator Rewards](https://devforum.roblox.com/t/how-much-you-earn-from-creator-rewards/4068829)
- Estimation tierce non primaire : environ 85 % des devs gagnent moins de 100 $/mois — [ROLearn](https://rolearn.dev/insights/roblox-creator-earnings-how-much-developers-make/)

### Inferences
- Ordre de grandeur (estimation à partir des cas auto-déclarés ci-dessus) : environ 2K CCU correspond à quelques milliers de $/mois, environ 13K CCU à environ 25K $/mois, et environ 38K CCU à environ 120K $/mois. Un objectif « rentable » réaliste pour un solo est de 1 à 5K CCU soutenus.
- Un prototype de quelques jours qui teste un « hook » vaut mieux que des mois de développement. Le succès vient ensuite de la cadence de mise à jour.
- Une communauté ou un réseau existant (groupe, Discord, YouTubeurs) a joué un rôle dans plusieurs cas (Steal a Brainrot).

### Gaps
- Je n'ai trouvé aucun postmortem solo complet avec revenus vérifiés pour 2025–2026 (DevForum inaccessible en lecture complète).
- Les revenus personnels réels de BMWLux sont inconnus.

## 3. Niches sous-servies et mécaniques émergentes en 2026

### Takeaway
D'après Roblox lui-même, le RPG, la stratégie et le shooter sont sous-représentés par rapport à la demande des joueurs plus âgés, et la « social co-opetition » est une demande latente. Le marché lui-même est saturé de clones de « steal »/brainrot/garden, et des hybrides apparaissent : steal plus PvP de nuit, contre-jeux, cozy-automation co-op. Le meilleur angle solo est un hybride systémique : une boucle incrémentale ou de collection associée à une mécanique sociale ou co-op originale, plutôt qu'un clone tardif.

### Cited Findings
- Selon l'Incubator de mars 2026, « RPG, strategy, and shooter games are heavily underrepresented despite strong demand from older age groups ». Roblox cherche aussi des « unexpected genre mash-ups » avec avatars et features sociales — [Roblox Newsroom, mars 2026](https://about.roblox.com/newsroom/2026/03/roblox-announces-incubator-jumpstart-creator-programs)
- Roblox a identifié la « social co-opetition » (travailler ensemble pour résoudre ou créer) comme un cluster en forte croissance — [Roblox Genre Insights 2024](https://about.roblox.com/newsroom/2024/07/roblox-genre-insights-what-will-you-create-next)
- La cohorte Incubator de juin 2026 inclut Sky Pixel, un jeu cozy de farming et construction avec automatisation d'îles flottantes dans un monde partagé — [Roblox Newsroom, juin 2026](https://about.roblox.com/newsroom/2026/06/2026-roblox-incubator-cohort)
- Rapports tiers : le co-op survie serait émergent (plusieurs titres à plus de 50K CCU au T1 2026), les sports compétitifs « historiquement sous-servis » et l'horreur co-op multijoueur « underserved » (méthodologie non transparente) — [ROLearn Q2 2026](https://rolearn.dev/trend-reports/emerging-roblox-game-genres-q2-2026/) ; [ROLearn unsaturated genres](https://rolearn.dev/insights/unsaturated-roblox-game-genres-2026/) ; [ROLearn horror](https://rolearn.dev/trend-reports/roblox-horror-genre-market-report-2026/)
- Grow a Garden 2 (juin 2026) ajoute du vol de cultures la nuit et des guildes à récompenses hebdomadaires. Une vague de clones garden, farming idle et tycoons de plantes a suivi l'original — [TheSpike](https://www.thespike.gg/roblox/best-roblox-games/best-games-like-grow-a-garden)
- Dans les top charts mi-2026, on trouve aussi de la survie/horreur (99 Nights in the Forest) et Animal Hospital (Anomaly) au n°2 — [Forgeguides](https://forgeguides.com/guides/roblox-top-20-most-played-games-july-2026/)
- Naavik note qu'aucun 4X n'a encore percé sur Roblox et suggère l'idle-arcade comme porte d'entrée (article ancien, environ 500 jours) — [Naavik, Predicting the Next Big Hits](https://naavik.co/digest/predicting-the-next-big-hits-on-roblox/)
- Dans un podcast Naavik et Sensor Tower, les canaux sociaux (streamers, YouTube, Discord, amis) sont décrits comme le moteur de la découverte, ce qui laisse de la place aux petites équipes. Le RPG y est cité comme un genre pas encore exploité — [Naavik podcast](https://naavik.co/podcast/the-state-of-gaming-in-2026-with-sensor-tower/)
- Roblox 4D Creation (génération d'objets fonctionnels par les joueurs en jeu) est en open beta depuis le 04/02/2026. Les utilisateurs de l'accès anticipé ont eu +64 % de temps de jeu (chiffre Roblox relayé) — [GamesBeat](https://gamesbeat.com/roblox-launches-4d-creation-into-open-beta-for-ai-generated-dynamic-objects/) ; [PocketGamer.biz](https://www.pocketgamer.biz/roblox-launches-4d-generation-creation-feature-enters-beta)

### Inferences
- **Lacunes compatibles avec un solo** :
  1. **Stratégie et idle-strategy légère** : auto-battler, tower defense systémique ou « 4X idle » en UI. C'est un genre sous-représenté selon Roblox et faisable principalement en code et UI.
  2. **Co-op social « co-opetition »** : tâches partagées comme une cuisine, un atelier ou une usine en équipe, des jobs à rôles complémentaires, avec boucle incrémentale. Cela s'aligne avec le nouveau signal de co-play de l'algorithme (section 4).
  3. **Cozy plus automatisation** (farming ou usine en monde partagé) : Roblox le soutient (Sky Pixel), et c'est moins saturé que le « steal ».
  4. **Mécaniques de génération par les joueurs (4D/Cube)** : c'est un levier de contenu sans modélisation pour le dev. L'outil est récent, donc l'avantage va aux premiers arrivants, mais il est en beta et la qualité est variable.
- **À éviter** : arriver tard sur le « steal X »/brainrot pur ou un clone de garden. Le marché est saturé et la fatigue est signalée.

### Gaps
- Je n'ai trouvé aucune donnée fiable du type ratio offre/demande par genre (seulement des rapports tiers non méthodologiques).
- La catégorie « job simulation, cuisine, party co-op » n'a pas de données spécifiques 2026.

## 4. Timelines, périmètre MVP et cadence de mises à jour ; contexte plateforme 2026

### Takeaway
Les hits récents ont été prototypés en quelques jours ou semaines. Les devs solos qui passent 3 à 9 mois avant de lancer rapportent souvent une faible rétention. Depuis juin 2026, l'algorithme de recommandation mesure la rétention sur 28 jours et le co-play. Le MVP doit donc prouver la boucle centrale et une raison de revenir, puis viser des mises à jour toutes les 1 à 2 semaines.

### Cited Findings
- Le 15/06/2026, Roblox a étendu « Recommended For You » de 7 à 28 jours, avec des signaux de rétention J1, J2–7 et J8–28. Les jeux qui créent de la valeur via « retention, co-play, and spend » seront favorisés — [Roblox Newsroom, juin 2026](https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox)
- Des sources secondaires citent le taux de « first-play bounce » comme signal parmi les plus importants, ainsi qu'un indicateur de co-play intentionnel sur 7 jours (à vérifier) — [lensblox](https://lensblox.com/blog/roblox-algorithm-change-2026-explained/) ; [gmmarket](https://gmmarket.me/community/post/how-the-roblox-discovery-algorithm-actually-works-in-2026-myths-debunked)
- Naavik estime que ce changement favorise les jeux qui retiennent sur plusieurs semaines et réduit les voies de visibilité — [Naavik digest](https://naavik.co/digest/robloxs-expensive-year-of-good-intentions/)
- Les bookings Roblox du T2 2026 (1,6 Md$) ne progressent que de 8 %, et la société en attribue une partie au changement d'algorithme. Elle prévoit −14 à −18 % au T3 — [Yahoo Finance](https://finance.yahoo.com/markets/stocks/articles/roblox-made-one-change-wiped-150700257.html) ; [BigGo, earnings call](https://finance.biggo.com/quote/RBLX/earnings-call/US_RBLX_2026-07-30)
- L'âge vérifié est obligatoire pour le chat dans le monde entier, et les comptes Roblox Kids et Select sont disponibles depuis juin 2026. Les jeux de « social hangout » ou de dessin libre ne sont pas autorisés pour ces comptes — [Roblox IR](https://ir.roblox.com/news/news-details/2026/Roblox-Requires-Users-Worldwide-to-Age-Check-to-Access-Chat/default.aspx) ; [Roblox Newsroom, juin 2026](https://about.roblox.com/newsroom/2026/06/age-based-roblox-kids-and-select-accounts-now-globally-available)
- Depuis le 08/06/2026, la part créateur sur les dépenses des utilisateurs US de plus de 18 ans vérifiés passe de 26,6 % à 37,8 % pour les jeux éligibles (source secondaire). La monétisation par heure baisse chez les plus jeunes — [SQ Magazine](https://sqmagazine.co.uk/roblox-statistics/)
- Roblox recommande des updates de contenu de moins de 3 semaines d'effort. Beaucoup de jeux publient toutes les 2 semaines à 1 mois, et la fréquence varie d'hebdomadaire à mensuelle selon la capacité de l'équipe — [Roblox Docs, Content updates](https://create.roblox.com/docs/production/game-design/content-updates) ; [Roblox Docs, LiveOps essentials](https://create.roblox.com/docs/production/game-design/liveops-essentials)
- Rythme tiers suggéré : correctifs et cosmétiques chaque semaine, contenu moyen toutes les 2 semaines, gros update mensuel — [ROLearn, scaling 1K→100K](https://rolearn.dev/guidance/scaling-1k-to-100k/)
- Un MVP doit valider que les joueurs comprennent la boucle centrale et veulent la répéter, avec un périmètre figé (guide générique, non Roblox) — [iLogos](https://ilogos.biz/how-to-build-mvp-game/)
- Cas solos : environ 7 mois de dev, puis une semaine de pubs, avec des joueurs qui partent en quelques minutes — [DevForum](https://devforum.roblox.com/t/just-released-my-first-game/4832887?page=2). Un vétéran se donne 2 semaines pour faire un jeu qu'il finira — [DevForum](https://devforum.roblox.com/t/after-9-years-of-development-i-finally-released-my-first-game/3679366)

### Inferences
- Plan solo suggéré : 1 à 2 semaines de prototype de la boucle centrale, 2 à 4 semaines jusqu'à un MVP publiable (boucle, persistance, 1 monétisation, onboarding en moins de 60 s), puis un soft launch avec un petit budget pub pour mesurer J1 et la session, et ensuite une itération chaque semaine.
- Le design doit intégrer **dès le MVP** une raison de revenir sur 28 jours (progression longue, quotidiens, événements) et une **incitation au jeu entre amis** (bonus d'invitation, co-op), parce que ce sont les signaux de l'algorithme 2026.
- Il vaut mieux éviter de dépendre du chat (gating par l'âge) et des hangouts libres (exclus des comptes Kids et Select).

### Gaps
- Je n'ai trouvé aucune donnée chiffrée sur la durée médiane entre prototype et lancement des devs solos.

## 5. Pièges fréquents et taux d'échec

### Takeaway
La plupart des jeux Roblox ne gagnent presque rien : le créateur DevEx médian touche environ 1 550 $/an, et ceux-là sont déjà une minorité. Les pièges dominants sont un onboarding long ou confus, une boucle centrale pauvre sans raison de revenir, le clonage tardif, des problèmes techniques dans les 20 premières secondes, et une dépense pub avant d'avoir de la rétention.

### Cited Findings
- Le créateur DevEx médian a reçu 1 550 $ sur 2025 — [Roblox](https://create.roblox.com/docs/monetize). Environ 85 % des créateurs gagneraient moins de 100 $/mois (estimation tierce) — [ROLearn](https://rolearn.dev/insights/roblox-creator-earnings-how-much-developers-make/)
- Un jeu à environ 10K visites/semaine a rapporté 80 Robux en Creator Rewards — [DevForum](https://devforum.roblox.com/t/how-much-you-earn-from-creator-rewards/4068829)
- Erreurs citées : vouloir « one-up » un jeu populaire en fast-follow, et des tutoriels longs. Un dev a amélioré son J1 en supprimant son tutoriel — [TechCrunch (via recherche)](https://techcrunch.com/?p=2129906)
- Un onboarding confus est cité comme cause majeure, avec la recommandation d'une première récompense en moins de 60 s. J1 au-dessus de 20 % est jugé bon et au-dessus de 30 % excellent, et il faut corriger la rétention avant le marketing (agence marketing, intérêt commercial) — [BLOXG](https://bloxg.com/problems/roblox-game-low-retention)
- Téléportations lentes, délais de sauvegarde et pop-in d'assets dans les 20 premières secondes poussent les joueurs à partir (vendeur d'analytics) — [RoWatcher](https://rowatcher.com/news/frame-rate-drops-don-t-kill-retention-these-do)
- Une boucle terne, trop peu d'objectifs et une progression linéaire mènent à l'abandon — [DevForum, retention](https://devforum.roblox.com/t/game%E2%80%99s-retention-and-average-session-time-extremely-low/4269329)
- Un fil DevForum explique pourquoi un jeu « techniquement supérieur » est ignoré par l'algorithme — [DevForum](https://devforum.roblox.com/t/why-your-technically-superior-game-isn%E2%80%99t-succeeding-on-roblox-and-why-the-algorithm-ignores-it/4461606)
- Steal a Brainrot doit faire face à de nombreux imitateurs — [The Star](https://www.thestar.com.my/tech/tech-news/2026/03/25/robloxs-hit-game-steal-a-brainrot-battles-its-many-imitators)

### Inferences
- Les exploits sont un risque majeur pour les jeux d'économie et de « steal » (duplication d'items, remotes non validés). Avec du code écrit par IA, il faut imposer un serveur autoritaire et la validation de chaque RemoteEvent.
- Les thumbnails et icônes conditionnent le CTR, et donc le coût par play des pubs (section 6).

### Gaps
- Je n'ai trouvé aucune donnée sourcée sur l'impact des thumbnails ni sur le taux d'échec des clones tardifs.

## 6. Outils, assets et acquisition à petit budget

### Takeaway
La stack solo standard 2026 combine ProfileStore pour les données, le Creator Store pour les assets gratuits, Roblox Assistant (mode agentique, planning, tests) et Cube 3D/4D pour générer des objets. L'acquisition payante peut démarrer avec un très petit budget, puisque Roblox annonce un coût par play inférieur à 0,01 $ en Maximize Plays. Les tests réels restent indispensables.

### Cited Findings
- ProfileStore (loleris/MadStudio) succède à ProfileService, qui n'est plus supporté. Il gère l'auto-save et le session locking, mais il n'est pas fait pour les leaderboards ou l'état global. Asset 109379033046155 — [DevForum ProfileStore](https://devforum.roblox.com/t/profilestore/3190543) ; [GitHub mirror](https://github.com/ISFOR1/ProfileStore)
- Roblox Cube a été lancé en mars 2025 (génération 3D par texte) avec l'objectif de générer des scènes entières — [Roblox Newsroom](https://about.roblox.com/newsroom/2025/03/introducing-roblox-cube). Une mise à jour beta a amélioré la qualité et ajouté le contrôle de la bounding box — [DevForum](https://devforum.roblox.com/t/beta-cube-3d-model-updates-better-quality-and-bounding-box-control/3828156)
- 4D Creation (mesh plus comportements) est en open beta depuis le 04/02/2026 et utilisable en jeu par les joueurs — [GamesBeat](https://gamesbeat.com/roblox-launches-4d-creation-into-open-beta-for-ai-generated-dynamic-objects/). PCGamesN juge la qualité moyenne (« about as good as you'd expect ») — [PCGamesN](https://www.pcgamesn.com/roblox/4d-generative-ai-model-update)
- Roblox Assistant gère désormais des workflows agentiques (Planning Mode, tests automatisés), et la génération procédurale d'assets est annoncée — [FinalBoss](https://insights.finalboss.io/briefings/roblox-is-building-ai-assistant-tools-and-procedural) ; [Naavik](https://naavik.substack.com/p/inside-robloxs-massive-bet-on-ai)
- Benchmarks officiels Ads Manager (nov. 2025) : coût par play d'environ 0,0073 $ (Maximize Plays), 0,0113 $ (Drive Retention) et 0,0187 $ (Acquire New Users), avec un minimum d'achat réduit — [DevForum Ads Manager](https://devforum.roblox.com/t/ads-manager-updates-home-search-combined-new-benchmarks-and-sunsetting-the-classic-flow/4084863). Benchmarks tiers bien plus élevés : environ 0,45 $/play en Sponsored et un départ conseillé à 10–20 $/jour — [BLOXG](https://bloxg.com/statistics/roblox-advertising-benchmarks)
- Il est conseillé de récompenser de petits créateurs de contenu avec des items en jeu en échange de vidéos. Un dev rapporte un pic de joueurs grâce à cette méthode — [DevForum](https://devforum.roblox.com/t/first-time-solo-dev-seeking-advice-on-game-launch-procedures/4551629)
- Les créateurs doivent avoir l'ID vérifiée, la 2FA et un abonnement Roblox Plus actif (selon une synthèse de l'annonce Kids/Select, à vérifier pour le périmètre exact) — [Roblox Newsroom](https://about.roblox.com/newsroom/2026/06/age-based-roblox-kids-and-select-accounts-now-globally-available)
- Roblox compte 3,5 M de développeurs actifs en 2025 et plus de 1 500 expériences à plus de 1 M de MAU, avec de nouveaux outils d'analytics sur les signaux de découverte — [Naavik, State of UGC 2026](https://naavik.co/deep-dives/the-state-of-ugc-games-2026/)

### Inferences
- Avec environ 0,01 $ par play, 100 $ achètent environ 10 000 plays selon les benchmarks officiels. C'est suffisant pour mesurer J1 et la conversion d'un MVP, et c'est la meilleure utilisation d'un petit budget (tester, pas scaler).
- Il faut miser sur l'UI (kits gratuits du Creator Store, polices, tweens) et sur les VFX en particules pour compenser l'absence d'art 3D custom.

### Gaps
- Je n'ai pas pu vérifier la liste à jour des UI kits gratuits recommandés en 2026 (DevForum inaccessible). Je n'ai pas trouvé de données 2026 sur ProfileStore.
