# Lancer un jeu Roblox rentable en solo

*État des lieux au 18 novembre 2026. Le jeu est développé par un dev solo, avec Claude qui écrit le code Luau.*

En novembre 2026, pour un développeur solo qui sait peu modéliser en 3D, le pari le plus rentable n'est pas de copier le dernier « Steal a X ». Ce terrain est saturé et chaque thème est cloné en quelques semaines. Le bon pari est un **jeu systémique** (code, données, interface) qui donne un plaisir immédiat dans la première minute, se joue mieux à plusieurs et donne une raison de revenir pendant 28 jours. Ce sont exactement les signaux que l'algorithme « Recommended For You » récompense depuis juin 2026. Le marché reste très profitable mais traverse un creux. Au T3 2026, Roblox a enregistré sa première baisse annuelle d'utilisateurs : **138 M de DAU (−9 %) et des bookings à 1,7 Md$ (−12 %)**. Les gains sont aussi extrêmement concentrés : le créateur DevEx médian touche **environ 1 500 $/an**, contre **65,7 M$ en moyenne pour chacun des 10 premiers**. Les hits de 2025–2026 montrent une recette répétable. On sort vite un prototype (Grow a Garden : **3 jours**). La boucle est idle et sociale, avec des raretés. On publie des mises à jour à jour fixe et on organise des événements « admin abuse » en direct. Ensuite, presque toujours, une petite équipe ou un studio prend le relais pour faire grandir le jeu. Je recommande de commencer par **« Potion Panique »**, un atelier de potions coopératif aux effets comiques sur les avatars, livrable en 4 semaines. Pour la décision stratégique, je recommande de **ne pas faire un jeu réservé aux 18+**. Il vaut mieux faire un jeu compatible tous âges, lancé d'abord pour les 16+ puis soumis à la revue Kids/Select, et construit en R15 pour toucher quand même le taux DevEx boosté sur les dépenses des adultes américains.

> **Avertissement sur les chiffres.** Roblox ne publie aucun revenu par jeu ni par genre. Tous les revenus par jeu cités ici sont des **estimations de trackers tiers**, et elles divergent souvent d'un facteur 3 à 10. Les pages officielles (Creator Hub, DevForum) n'ont été lues que via des extraits de recherche. Il faut donc vérifier chaque règle sur la page officielle avant de prendre une décision financière.

## Le marché : la simulation domine, mais un nouveau venu gagne moins là qu'ailleurs

### Où sont les joueurs et l'argent

La **simulation** (idle, jardin, « steal », pets et œufs) est le premier genre en joueurs en direct, avec **environ 36 % des joueurs** selon un snapshot de novembre 2026 ([Statroblox](https://statroblox.com/guides/most-popular-roblox-genres)). Elle est aussi première en revenu total estimé ([profitable.app](https://profitable.app/roblox/genres)). Mais ce total cache une concentration brutale. Dans la plupart des sous-genres de simulation, **les 2 premiers jeux captent plus de 80 % des revenus** ([RoWatcher](https://rowatcher.com/news/roblox-genre-opportunity-map-2026-where-smart-developers-are-building-next)). Le revenu mensuel **médian** par jeu est d'ailleurs plus élevé ailleurs : environ **1 084 $** en Sports & Racing, **1 018 $** en Roleplay et **943 $** en Shooter, selon les estimations ([profitable.app](https://profitable.app/roblox/stats)). Pour un débutant, la moyenne d'un genre compte moins que la place qu'il peut y prendre.

En novembre 2026, les plus gros revenus vont à **RIVALS** (FPS de duels), **Steal An Egg** et **Blox Fruits**, d'après le classement Top Earning ([Statroblox](https://statroblox.com/leaderboards/chart)). Les montants estimés illustrent bien la faiblesse des trackers. RoWatcher donne à RIVALS **8 à 15 M$/mois** ([RoWatcher](https://rowatcher.com/news/the-10-highest-earning-roblox-games-in-2026-and-what-they-mean-for-the-platform)). BloxBunny ne lui donne que **796 K$** ([BloxBunny](https://bloxbunny.com/top-earning-games)). **Ces chiffres ne servent qu'à donner un ordre de grandeur.**

### Ce qui est saturé, ce qui monte

| Statut | Genres / formats | Signal |
|---|---|---|
| **Saturé ou en déclin** | Simulateurs basiques, obbies, clones « +1 », clones brainrot/garden | 189 simulateurs lancés au T4 2025 et CCU moyen par jeu en baisse de 20 % début 2026 ([RoLearn](https://rolearn.dev/trend-reports/genre-shift-2026-predictions/)). Fatigue signalée sur les « +1 » ([Forgeguides](https://forgeguides.com/en/guides/roblox-top-20-most-played-games-july-2026/)) |
| **En croissance** | Survie et horreur co-op, social-idle hybrides, FPS compétitif, crossovers d'IP | Survie : +13 % en une semaine (nov. 2026) ([Statroblox](https://statroblox.com/guides/most-popular-roblox-genres)). Semaine du 28/09 : « CCU +39 %, les jeux d'œufs et K-Pop Demon Hunters dominent » ([RoWatcher](https://rowatcher.com/news/roblox-week-in-numbers-2026-w40)) |
| **Sous-représenté selon Roblox** | RPG, stratégie, shooter (demande forte des plus âgés), mélanges de genres sociaux | Programme Incubator de mars 2026 ([Roblox Newsroom](https://about.roblox.com/newsroom/2026/03/roblox-announces-incubator-jumpstart-creator-programs)) ; « social co-opetition » ([Roblox Genre Insights](https://about.roblox.com/newsroom/2024/07/roblox-genre-insights-what-will-you-create-next)) |

### Les tendances culturelles de fin 2026

La grande vague de l'automne est **Steal An Egg**, créé le 25 juillet 2026, avec un pic autour de **12 à 14 M de joueurs simultanés** en septembre–octobre. Le chiffre exact dépend du tracker : 14,3 M sur [RoStats](https://rostats.io/records), 12,4 M sur [RBLXSTAT](https://rblxstat.com/games/10563114921). Une autre source parle de **6,3 M**, ce qui est un conflit non résolu ([lolga](https://www.lolga.com/news/what-is-the-future-of-steal-an-egg-private-servers-cheating-penalties-or-more)). Il était encore n°1 hebdomadaire mi-novembre ([RoStats charts](https://rostats.io/charts)). Les autres moteurs culturels sont les suivants :

- les restes de la vague **« Italian brainrot »** ;
- l'IP Netflix **K-Pop Demon Hunters**, avec plus de 110 M de visites ([Rolimons](https://www.rolimons.com/game/118806061296143)) ;
- l'**horreur/anomalie** : Animal Hospital a atteint un pic de 1,27 M CCU en juillet ([adellion](https://adellion.com/roblox-horror-games)) ;
- le **cozy/idle** (jardin) ;
- les jeux d'**anime**.

La formule gagnante combine une boucle sociale « collectionner, voler, défendre » avec un thème meme ou une IP, et des clips courts sur TikTok et YouTube. Point important : **plus de 80 % des 100 jeux les plus joués ont utilisé des outils d'IA** dans le mois précédent ([MassivelyOP](https://massivelyop.com/2026/10/30/roblox-marks-a-rise-in-revenue-more-gen-ai-games-and-a-chase-for-over-18-users-in-third-quarter-earnings-report/)). Cloner coûte donc presque rien, et une fenêtre de tendance ne dure que quelques semaines.

### Le contexte plateforme : moins d'argent par jeune, plus d'adultes

Au T3 2026, la plateforme recule par rapport au boom de 2025. Elle compte **138 M de DAU**, environ **34 Md d'heures** (−15 %), **1,697 Md$ de bookings** (−12 %) et un revenu de **1,57 Md$** (+16 %) ([lettre aux actionnaires T3 2026](https://s27.q4cdn.com/984876518/files/content_files/Q3-2026-Earnings-Shareholder-Letter.pdf) ; [gaming.net](https://gaming.net/roblox-q3-revenue-rises-16-as-bookings-fall-12-to-1-7-billion)). Un résumé de presse donne 29 Md d'heures au lieu de 34 : **sources en conflit**. Les prévisions du T4 sont aussi en baisse (−10 à −15 %). La croissance vient des adultes. Les 18+ représentent **37 % des DAU dont l'âge a été vérifié aux États-Unis** (contre 33 % au T2) et **monétisent au moins 50 % de plus** que les moins de 18 ans ([lettre T3 2026](https://s27.q4cdn.com/984876518/files/content_files/Q3-2026-Earnings-Shareholder-Letter.pdf)). Elle vient aussi de l'Inde (+37 % de DAU) et du Japon (+33 %). Enfin, environ **80 % de l'audience joue sur téléphone** ([Naavik](https://naavik.co/deep-dives/the-state-of-ugc-games-2026/)). L'interface doit donc être pensée d'abord pour le mobile, sans exception.

### Ce qu'un solo peut réellement espérer gagner

Les gains suivent une loi de puissance. Le top 1 000 a touché en moyenne **1,4 M$** sur juillet 2025 – juin 2026. Le **médian, sur plus de 42 000 participants DevEx, est d'environ 1 500 $** ([TechSpot](https://www.techspot.com/news/113855-roblox-top-creators-making-65-million-year-while.html)). Quelques cas auto-déclarés donnent un ordre de grandeur, **non vérifié** :

| Joueurs simultanés (CCU) | Revenu déclaré | Source |
|---|---|---|
| ~2 100 CCU au pic | ~1,39 M Robux en 56 jours | [sozai.app](https://sozai.app/transcript/2k-ccu-roblox-game-earnings/) |
| ~13 100 CCU | ~25 000 $/mois | [sozai.app](https://sozai.app/transcript/made-25070-month-roblox-game/) |
| ~38 000 CCU (jeu co-détenu) | ~119 300 $/mois | [sozai.app](https://sozai.app/transcript/roblox-game-119300-month-38k-ccu/) |

Un objectif « rentable » réaliste pour un solo est donc **1 000 à 5 000 CCU soutenus**, soit quelques milliers à environ 10 000 $ par mois. Au-delà, il faut une équipe ou un partenaire.

## Ce que les hits 2025–2026 enseignent : prototype éclair, boucle sociale, rendez-vous fixes

### Vue d'ensemble

| Jeu | Équipe / origine | Temps de dev initial | Pic CCU | Boucle centrale | Déclencheur du décollage |
|---|---|---|---|---|---|
| **Grow a Garden** (mars 2025) | Un ado de 16 ans (BMWLux), puis le studio Splitting Point (~12 devs) à partir de ~1 000 CCU | **~3 jours** | ~21–22 M | Planter, attendre en temps réel, récolter, vendre, acheter mieux. Restocks, météo, mutations | Mises à jour hebdomadaires, admin abuse, TikTok du dev (12 M d'abonnés) |
| **Steal a Brainrot** (mai 2025) | SpyderSammy sous DoBig Studios. Droits d'un jeu antérieur rachetés, communauté d'environ 22 M de membres | Inconnu | ~25 M (record Roblox) | Acheter des brainrots qui génèrent de l'argent par seconde. Les autres peuvent les voler. Bouclier temporaire | Thème meme TikTok, admin abuse 2 fois par semaine sur tous les serveurs |
| **99 Nights in the Forest** (juin 2025) | Groupe Grandma's Favourite Games (jeux antérieurs) | Inconnu | ~14,2 M | Survie co-op en runs (« survivre 99 nuits ») et monnaie méta (diamants) | Tendance « survive N days » lancée par Dead Rails, update Halloween |
| **Dead Rails** (fév. 2025) | RCM Games, environ 70 jeux. **Pas un solo** | Inconnu | ~1,48 M | Run co-op en train sur 80 km : recherche de ressources, zombies | Promo officielle Roblox, clip TikTok à 499 K likes, créateurs |
| **The Forge** (nov. 2025) | Équipe non confirmée | Inconnu | ~1,05 M en moins de 2 semaines | Miner, forger des armes uniques, combattre | Inconnu. Effondrement ensuite à ~1,5 K CCU |
| **RIVALS** | Nosniy Games (19 jeux, un seul vrai succès) | Inconnu | ~964 K | Duels FPS de 1v1 à 5v5, premier à 5 manches | Profondeur compétitive, joueurs PC et adultes |
| **Steal An Egg** (juil. 2026) | Lié au portfolio Misfits Gaming (non vérifié) | Inconnu | 6 à 14 M (**conflit**) | Variante « Steal a ___ » avec des œufs | Rotation du thème sur une mécanique déjà validée |

Sources : [Wikipedia GaG](https://en.wikipedia.org/wiki/Grow_a_Garden), [GamesBeat](https://gamesbeat.com/janzen-madsen-interview/), [Wikipedia SAB](https://en.wikipedia.org/wiki/Steal_a_Brainrot), [Eldorado](https://www.eldorado.gg/blog/steal-a-brainrot-en/sammy-steal-a-brainrot-guide/), [Rolimons 99 Nights](https://www.rolimons.com/game/79546208627805), [GameAnalytics Dead Rails](https://www.gameanalytics.com/blog/dead-rails-and-the-hit-makers-formula), [Rolimons The Forge](https://www.rolimons.com/game/76558904092080), [RoWatcher RIVALS](https://rowatcher.com/games/6035872082/rivals), [OtakuKart](https://otakukart.com/robloxs-steal-an-egg-reaches-6-billion-visits-and-14-2-million-peak-concurrent-players/).

### La boucle : un minuteur, une rareté, une vitrine sociale, un rendez-vous

Les deux plus gros succès, Grow a Garden et Steal a Brainrot, partagent quatre ingrédients :

1. un **revenu passif ou une croissance sur minuteur**, techniquement simple (« boring idle tech », de simples boucles serveur selon [DEV Community](https://dev.to/wlz/why-grow-a-garden-and-steal-a-brainrot-bet-on-boring-idle-tech-the-luau-loop-behind-2djf)) ;
2. une **échelle de raretés** avec des mutations ;
3. une **base visible** que les autres joueurs voient ou peuvent piller ;
4. des **événements serveur à heure fixe**. Pour Steal a Brainrot, l'admin abuse dure 30 à 45 minutes, le mardi à 18 h ET et le samedi à 15 h ET, sur **tous les serveurs à la fois**, avec des multiplicateurs de chance ×15 ([Eldorado](https://www.eldorado.gg/blog/steal-a-brainrot-en/steal-a-brainrot-admin-abuse-schedule-explained/)).

Ces rendez-vous créent des pics énormes. La « Admin Abuse War » du 23 août 2025 a porté Grow a Garden à environ **22,3 M de CCU** ([GaG Fandom](https://growagarden.fandom.com/wiki/Admin_Abuse_War)). Les jeux de survie, eux, misent sur des **runs courtes en co-op avec un objectif chiffré** (80 km, 99 nuits) et une monnaie permanente entre les runs. Ce format se prête très bien au stream.

### La monétisation : une échelle de prix répétée partout

Les hits empilent toujours les mêmes étages de prix :

| Étage | Prix observés | Exemples |
|---|---|---|
| Achat impulsif | 37–199 R$ | « Take Player's Fruit » 37 R$ (GaG), Blackhole Slap 199 R$ (SAB) |
| Pass central | 299–499 R$ | 2x Money 299 R$, VIP 499 R$ (SAB) ; VIP Dress to Impress 799 R$ à vie |
| Packs dégressifs | 1 / 3 / 10 unités | Super Seed : 199 / 575 / 1 699 R$ (GaG) |
| Boost social de serveur | ~249 R$ / 15 min | Server Luck 2x (SAB) : un seul acheteur, tout le serveur en profite |
| Ancre « baleine » | 2 000–10 000 R$ | Admin Panel SAB : prix cités de 2 299 à 9 999 R$ (**conflit selon la date**) |

Sources : [SAB Fandom](https://stealabrainrot.fandom.com/wiki/Gamepasses_and_Dev_Products), [GaG Fandom](https://growagarden.fandom.com/wiki/Limited_Time_Shop), [Sportskeeda](https://www.sportskeeda.com/roblox-news/dress-impress-gamepasses-all-passes-price-details), [Buffget](https://buffget.com/news/steal-a-brainrot-2x-luck-review-worth-249-robux).

**Aucune source ne donne la répartition entre passes, produits répétables et événements.** On peut penser que les produits répétables (œufs, lucky blocks, boosts, skips) dominent, puisqu'un pass ne s'achète qu'une fois, mais c'est une inférence. L'idée la plus intéressante est l'**achat social** : le boost de serveur ou l'admin panel profite à tous les joueurs présents, et il fait donc lui-même la publicité de l'achat.

### Le mythe du solo : le prototype est solo, la croissance ne l'est pas

Le modèle réel se fait en deux temps. Un solo ou un ado sort un prototype en quelques jours. Le jeu atteint environ **1 000 CCU** organiques, et un studio habitué au live-ops entre au capital puis publie des mises à jour chaque semaine. C'est le seuil auquel Splitting Point a agi sur Grow a Garden ([GamesBeat](https://gamesbeat.com/janzen-madsen-interview/)). **Aucun méga-hit de 2025–2026 n'a été construit et développé à grande échelle par une seule personne** selon les sources trouvées. Dead Rails, souvent présenté comme « solo », vient d'un groupe d'environ 70 jeux. À l'échelle modeste, en revanche, il existe des succès solo : un étudiant est monté à plus de 7 000 CCU et a reçu une offre de rachat de 24 000 $ pour 70 % du jeu (récit non vérifié, [daily.dev](https://daily.dev/posts/i-made-a-successful-roblox-game-to-prove-it-s-not-luck-mds7nwwho)).

Les hits retombent vite. Sur environ 28 jeux passés au-dessus de 1 M de CCU, la **baisse médiane depuis le pic est de 90,9 %** ([MaxPowerGaming](https://www.maxpowergaming.co/post/the-million-player-curse-why-roblox-s-biggest-hits-struggle-to-last)). Plants vs Brainrots est passé de 8,65 M à environ 2 400 CCU, et The Forge de 1 M à environ 1 500. Les clones tardifs échouent pour plusieurs raisons :

- ils n'ont ni l'audience, ni la cadence de mises à jour, ni le réseau de créateurs de l'original ;
- les communautés se moquent des copies ;
- les procès arrivent : Spyder Games a attaqué un clone sur Fortnite ([PC Gamer](https://www.pcgamer.com/games/a-brainrot-themed-roblox-game-is-taking-a-brainrot-themed-fortnite-game-to-court-for-being-a-copy/)).

La leçon s'appelle « MAYA » (*most advanced yet acceptable*) : une boucle familière dans un habillage neuf ([GameAnalytics](https://www.gameanalytics.com/blog/dead-rails-and-the-hit-makers-formula)).

## L'algorithme depuis juin 2026 : les 3 premières minutes et le retour entre amis sur 28 jours

### Ce qui a changé le 15 juin 2026

Le « Recommended For You » (RFY) de l'accueil est passé d'une fenêtre d'évaluation de **7 jours à 28 jours**. Il mesure la rétention par tranches : **J1, J2–7 et J8–28**. Les signaux pris en compte sont le temps de jeu, les jours joués, les sessions qualifiées, les **jours de co-play intentionnel**, les **jours de dépense** et les Robux dépensés ([DevForum](https://devforum.roblox.com/t/recommended-for-you-algorithm-improvements-that-better-value-long-term-retention/4684575)). L'ancien indicateur qPTR a été supprimé. Il est remplacé par le **PTR** (part des joueurs qui lancent le jeu après l'avoir vu) et le **taux de rebond au premier lancement**, mesuré sur deux fenêtres : moins de 60 s et 61 à 180 s. Ce dernier est un signal négatif et compte parmi les « plus importants ». Le temps de jeu compté est plafonné à **60 minutes par joueur, par jeu et par jour** ([Creator Hub – Discovery](https://create.roblox.com/docs/discovery)). Quatre signaux par joueur seraient classés « Important » : le co-play intentionnel, les sessions qualifiées, les jours de dépense et les Robux dépensés. Le tableau officiel n'a pas pu être lu en entier : **c'est à confirmer** ([Zehn Studio](https://zehn-studio26.com/news/recommended-for-you-discovery-rollout/)). Une source date le début de l'ajustement à **avril** plutôt qu'à juin ([godisageek](https://godisageek.com/2026/08/roblox-9-billion-algorithm-change/)).

Roblox a assumé le coût de ce changement. L'action a chuté d'environ **27 % le 31 juillet 2026** et les bookings du T3 ont été annoncés en baisse de 14 à 18 %. Roblox estime que les gains de rétention compenseront ([Yahoo Finance/Reuters](https://finance.yahoo.com/markets/stocks/articles/roblox-set-worst-one-day-154930126.html)). Concrètement, un design qui cherche à encaisser vite (gacha agressif, mur payant dès le début) est désormais pénalisé. Une dépense régulière étalée sur plusieurs jours vaut mieux qu'un gros achat unique.

### La règle qui change tout pour la pub

**Seul le trafic organique venu du RFY compte dans le classement.** Les joueurs arrivés par la pub, la curation, les amis, la recherche, les réseaux sociaux ou la rubrique « Continuer » sont exclus du calcul ([Discovery FAQ](https://create.roblox.com/docs/discovery-faq)). L'étape de sélection initiale (« retrieval ») ne demande qu'un « très faible nombre de parties, quelle que soit la source ». Le jeu est ensuite testé sur un petit échantillon et reçoit plus d'impressions si sa rétention tient. Autrement dit, **la pub et les influenceurs servent à démarrer le moteur, pas à classer le jeu**. Il faut aussi soigner les visuels de la page du jeu :

- Activez **3 à 5 miniatures** pour profiter de la personnalisation des miniatures, qui donne en moyenne +8,5 % ([DevForum](https://devforum.roblox.com/t/get-your-thumbnails-ready-for-thumbnail-personalization/3226599)).
- Depuis le 19 octobre 2026, un jeu qui garde la miniature par défaut serait exclu de l'accueil (source tierce, **à vérifier**, [Zehn Studio](https://zehn-studio26.com/news/brand-world-launch-playbook/)).

Il faut sans doute **environ 4 semaines** avant que le signal se stabilise. C'est une inférence, Roblox ne l'a pas confirmé.

### Les chiffres à viser

| Indicateur | Médiane (jeux ≥ 1 M MAU) | Top 1 % | Cible réaliste pour notre MVP |
|---|---|---|---|
| Rétention J1 | 10,3 % | 22,2 % | **≥ 15 %** |
| Rétention J7 | 1,6 % | 9,1 % | **≥ 4 %** |
| Rétention J30 | ~0,5 % | n.d. | ≥ 1 % |
| Durée de session | 9,8 min (p75 : 12,0) | p99 : 21,1 min | **≥ 12 min** |
| Part de payeurs | 3,8 % | n.d. | ≥ 3 % |
| ARPPU | 0,70 $ (**conflit** avec le Benchmarks Hub) | 55,31 $ | à comparer dans le tableau de bord Roblox |

Sources : [GameAnalytics 2026](https://www.gameanalytics.com/reports/2026-roblox-report) ; [gamedevreports](https://gamedevreports.substack.com/p/gameanalytics-key-roblox-and-roblox). Ces médianes ne couvrent que des jeux à au moins 1 M de MAU. Pour l'ensemble des nouveaux jeux, les vrais chiffres sont plus bas (biais du survivant). Le meilleur point de comparaison est le **tableau de bord Creator Analytics**, qui compare chaque indicateur aux percentiles 50–90 de jeux similaires. Son exemple documenté donne une fourchette J1 de 12,1 % à 18,7 % ([Creator Hub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/analytics/analytics-dashboard.md)). Les seuils de « 20 % bon / 40 % excellent » qui circulent viennent de petits échantillons de jeux déjà gagnants. Ne vous y fiez pas.

### Ce que coûtent la pub et les influenceurs

Les **Sponsored experiences** passent par l'Ads Manager et sont facturées au **coût par partie jouée** (CPP). Une partie compte quand le joueur clique, arrive sur la page du jeu et le rejoint dans l'heure. Roblox annonce un **CPP moyen inférieur à 0,01 $**, en baisse de 71 % ([DevForum RDC 2025](https://devforum.roblox.com/t/ads-for-creators-rdc-recap-and-what%E2%80%99s-next/3929106)). Ses benchmarks de novembre 2025 donnent **0,0073 $** pour l'objectif « Maximize Plays », **0,0113 $** pour « Drive Retention » et **0,0187 $** pour « Acquire New Users » ([DevForum](https://devforum.roblox.com/t/ads-manager-updates-home-search-combined-new-benchmarks-and-sunsetting-the-classic-flow/4084863)). Un vendeur de services marketing affirme plutôt **0,45 $ par partie**, soit environ 50 fois plus. **C'est un conflit majeur**, et ce chiffre vient d'une source intéressée ([bloxg](https://bloxg.com/statistics/roblox-advertising-benchmarks)). Les études d'incrémentalité de 2026 donnent un gain médian de **+14 % de sessions incrémentales**, et les 21 campagnes testées ont toutes apporté des parties supplémentaires ([DevForum RDC 2026](https://devforum.roblox.com/t/ads-manager-rdc-recap-earnings-roas-reporting-incrementality/4909790)). Le nouvel emplacement mis en avant sur l'accueil exige un **minimum de 5 000 $** (non confirmé, [clipclip](https://clipclip.io/guides/roblox-ads-cost)).

Pour les influenceurs, les prix viennent surtout de vendeurs : **20 à 200 $ la vidéo** chez les micro-créateurs, 200 à 2 000 $ en milieu de gamme, plus de 2 000 $ pour les gros. Le CPP implicite serait de 0,08 à 0,35 $ ([bloxg](https://bloxg.com/guides/roblox-marketing) ; [MetaClip](https://metaclip.app/guides/roblox-influencer-marketing)). Une tactique peu chère qui a déjà marché : **offrir des objets en jeu à de petits créateurs** en échange de vidéos ([DevForum](https://devforum.roblox.com/t/first-time-solo-dev-seeking-advice-on-game-launch-procedures/4551629)). Avec un budget limité, voici la meilleure façon de dépenser :

1. **100 à 200 $** en « Maximize Plays », soit environ 10 000 à 20 000 parties au tarif officiel, pour *mesurer* le PTR, le rebond et J1 sur une vraie cohorte. La rétention est visible par source d'acquisition.
2. Ne passer à l'objectif « Earnings » (optimisé pour le retour sur dépense pub) qu'une fois la conversion au niveau du benchmark.
3. Ne **jamais** payer pour faire grossir un jeu qui ne retient pas ses joueurs.

## Les règles qui touchent votre portefeuille

### Combien vous touchez vraiment

Sur un game pass ou un produit de développeur, le créateur garde **70 % des Robux** ([Creator Hub](https://create.roblox.com/docs/production/earn-on-roblox)). Le taux DevEx de base est de **0,0038 $ par Robux** pour les Robux gagnés depuis le 5 septembre 2025 (avant : 0,0035 $). Depuis le **8 juin 2026**, un taux **majoré de 42 %, soit environ 0,0054 $**, s'applique aux dépenses des **joueurs américains de 18 ans et plus dont l'âge a été vérifié**, dans les jeux éligibles. Il couvre les passes, abonnements, certains objets et serveurs privés. Le pays est déterminé par la localisation économique : un VPN ne compte pas ([Roblox Newsroom](https://about.roblox.com/newsroom/2026/04/roblox-fuels-high-fidelity-games-over-18-players-increases-qualifying-devex-rate-42) ; [Creator Hub 18+](https://create.roblox.com/docs/production/monetization/18-plus-devex-rate)). Un jeu éligible doit apparemment être **en R15 uniquement**. Les sources formulent cette règle différemment mais vont dans le même sens, et la liste complète des critères n'a pas pu être lue. Une source parle de 0,0035/0,0050 pour les 17+ : c'est probablement une version périmée.

Pour retirer de l'argent, il faut avoir **13 ans ou plus**, cumuler **30 000 Robux gagnés** et être en règle avec les conditions d'utilisation. Les sites qui parlent de 100 000 Robux ou de Premium obligatoire contredisent la documentation officielle ([Creator Hub – DevEx](https://create.roblox.com/docs/production/monetization/developer-exchange)).

| Ce que dépense le joueur | Ce que vous touchez (taux de base) | Joueur US 18+ vérifié, jeu éligible |
|---|---|---|
| 100 R$ | 70 R$ → **0,27 $** | **0,38 $** |
| 399 R$ (pass) | 279 R$ → **1,06 $** | **1,51 $** |
| 30 000 R$ gagnés (seuil de retrait) | **114 $** | **162 $** |

Roblox résume lui-même la part créateur à **environ 25 %** de ce que paie le joueur ([Creator Hub](https://create.roblox.com/docs/get-started/monetization)). Pour les adultes américains, elle monte à 37,8 % ([Zacks](https://www.zacks.com/stock/news/2951426/)). Il existe aussi des revenus d'appoint :

- **Creator Rewards** : 5 R$ par « Active Spender » (joueur ayant dépensé au moins 9,99 $ sur 60 jours) qui joue au moins 10 minutes par jour, si votre jeu fait partie des 3 premiers qu'il ouvre ce jour-là. S'y ajoutent 35 % des 100 premiers dollars dépensés par les nouveaux joueurs pendant leurs deux premiers mois ([Creator Hub](https://create.roblox.com/docs/en-us/creator-rewards.md)). En pratique, c'est faible : un dev rapporte **80 R$** pour environ 10 000 visites ([DevForum](https://devforum.roblox.com/t/how-much-you-earn-from-creator-rewards/4068829)).
- **Rewarded Video** : publicités récompensées, accessibles au-delà de **2 000 visiteurs uniques par mois**, pour les créateurs de 13 ans et plus avec 2FA ([DevForum](https://devforum.roblox.com/t/rewarded-video-ads-are-now-available-to-all-ads-eligible-creators/4063278)).
- **Abonnements** : 70 % par mois, puis 100 % à partir du 2e mois s'ils sont facturés en monnaie locale, selon la documentation ([Creator Hub](https://create.roblox.com/docs/production/monetization/subscriptions)). **Une autre note n'a pas pu confirmer ce partage**, donc vérifiez avant de vous appuyer dessus.

### Objets aléatoires payants : autorisés, mais sous conditions strictes

Les « paid random items » (œufs, caisses, roues, boosts de chance, systèmes de pity) sont permis à trois conditions ([Creator Hub](https://create.roblox.com/docs/production/monetization/paid-random-items)) :

1. **Afficher toutes les issues avec leurs probabilités chiffrées** avant l'achat, et mettre ces probabilités à jour pendant un boost.
2. Appeler `PolicyService:GetPolicyInfoForPlayerAsync()`. Si `ArePaidRandomItemsRestricted` est vrai (historiquement aux Pays-Bas et en Belgique), il faut retirer la fonction ou proposer une voie gratuite.
3. Respecter `IsPaidItemTradingAllowed` pour les échanges.

La politique a été mise à jour le **19 août 2026**. Depuis avril 2026, les conditions d'utilisation exigent aussi de respecter les lois sur les **loot boxes, les « dark patterns » et les fonctions addictives** ([DevForum](https://devforum.roblox.com/t/updates-to-the-roblox-terms-of-use-april-2026/4548394?page=2)). Les minuteurs FOMO agressifs et la fausse rareté deviennent donc un risque juridique, pas seulement un risque d'image. Conseil pratique pour le MVP : **vendre des produits au contenu connu** et ajouter l'aléatoire payant plus tard, une fois l'interface de probabilités et le filtre PolicyService codés et testés.

### Tranches d'âge et publication tous âges

Depuis juin 2026, les comptes sont répartis en trois catégories : **Roblox Kids (5–8 ans)**, **Roblox Select (9–15 ans)** et **standard (16+)**. Les comptes Kids ne voient que les jeux classés Minimal ou Mild, et les comptes Select vont jusqu'à Moderate ([TechCrunch](https://techcrunch.com/2026/04/13/roblox-introduces-kids-and-select-accounts-for-age-appropriate-access-to-games-and-chat/)). Publier pour tous les âges demande :

- une **pièce d'identité vérifiée et la 2FA** ;
- des **frais de publication remboursables ou un abonnement** (Roblox Plus), dont le montant exact n'est pas confirmé ;
- une **revue en trois temps** : éligibilité, filtrage automatique, période d'évaluation ([Creator Hub](https://create.roblox.com/docs/production/publishing/kids-and-select)).

Une revue accélérée coûte **100 000 Robux remboursables par jeu**. Point clé : **un jeu qui n'a pas encore passé la revue reste accessible aux 16+** si son créateur a vérifié son âge ([DevForum](https://devforum.roblox.com/t/roblox-kids-and-select-global-launch-upcoming-updates-to-eligibility-ads-manager-and-expedited-review/4685717)). Les hangouts sociaux libres et le dessin libre sont exclus des comptes Kids/Select, et le chat exige une vérification d'âge partout ([Roblox Newsroom](https://about.roblox.com/newsroom/2026/06/age-based-roblox-kids-and-select-accounts-now-globally-available)). **Ne faites donc pas dépendre la boucle du chat.** Les parents peuvent plafonner les dépenses mensuelles des moins de 13 ans, ce qui favorise les petits achats répétés ([Help Roblox](https://en.help.roblox.com/hc/en-us/articles/30428310121620-Parental-Controls-Overview)).

### Propriété intellectuelle et prix régionaux

Utiliser des personnages protégés (anime, dessins animés, IP Netflix) sans licence expose à des retraits DMCA. Les récidivistes voient leur compte **définitivement supprimé**, ce qui signifie perdre aussi les revenus DevEx ([Creator Hub – DMCA](https://create.roblox.com/docs/production/publishing/dmca-guidelines)). La voie légale passe par le programme de licences de Roblox ([IP licensing FAQ](https://create.roblox.com/docs/ip-licensing/faq)). Un format meme original est moins risqué qu'un personnage sous copyright, mais aucun texte officiel ne traite explicitement des memes. Côté prix, la **tarification gérée** (« Managed pricing ») combine optimisation et prix régionaux en une seule option, activée par défaut pour les passes ([Creator Hub](https://create.roblox.com/docs/production/monetization/managed-pricing)). Si votre jeu permet les échanges ou les cadeaux, utilisez `GetUsersPriceLevelsAsync`. Sinon, un objet acheté moins cher dans un pays à prix bas peut être revendu ailleurs avec profit (arbitrage) ([Creator Hub](https://create.roblox.com/docs/production/monetization/regional-pricing)).

## Trois concepts originaux taillés pour un solo et l'algorithme 28 jours

Les trois concepts suivent les leçons ci-dessus. Ce sont des boucles systémiques (code et interface plutôt que modèles 3D), avec des assets gratuits du Creator Store, des primitives, des particules et Roblox Cube pour les rares objets sur mesure. Chacun vise un plaisir immédiat en moins de 60 secondes (contre le rebond), donne un avantage au jeu entre amis (co-play) et offre une raison de revenir chaque semaine (J8–28). Aucun ne dépend du chat. Les notes sur 5 sont mes estimations, pas des mesures.

### Tableau comparatif

| Critère (/5, 5 = meilleur) | **A. Potion Panique** | **B. Enchères Mystères** | **C. Ligue des Cartes Pliées** |
|---|---|---|---|
| Potentiel de revenus | 3,5 | **4** | 3 |
| Faisabilité solo | **4,5** | 3,5 | 4 |
| Rapidité de lancement | **4** | 3,5 | 3 |
| Risque (5 = risque faible) | **3,5** | 3 | 2 |
| **Total /20** | **15,5** | 14 | 12 |
| Public naturel | Tous âges (Mild) | 13+ / 16+ | 16+ / adultes |

### Concept A : Potion Panique (atelier de potions coopératif)

**Pitch.** Vous et vos amis tenez une boutique de potions. Des clients font la queue. Vous lancez des ingrédients dans un chaudron, la couleur et l'écume annoncent la recette, vous servez. Une potion ratée explose et vous transforme, vous ou vos amis : tête géante, mini-avatar, flottaison, avatar couleur arc-en-ciel.

**Boucle centrale (30 s).** Prendre des ingrédients sur les étagères, les déposer dans le chaudron, obtenir une potion (avec une rareté et une chance de mutation), servir un client PNJ, encaisser des pièces. Les pièces servent à acheter de meilleurs chaudrons, de nouvelles étagères et de nouvelles recettes. Entre les sessions, les chaudrons continuent de mijoter, ce qui donne un revenu idle à la reconnexion.

**Ce qui le rend original.** Le genre « boutique » existe déjà, mais pas avec la **potion comme effet sur l'avatar**. C'est un moteur de clips naturel : « j'ai bu la potion légendaire et mon ami est devenu géant ». Les effets utilisent seulement le `Scale` R15, des couleurs et des particules. Il n'y a aucun modèle 3D à faire.

**Viral hook.** Des potions « à lancer » sur les autres joueurs (avec consentement : seuls les amis et les membres de la boutique peuvent être visés, et on peut se protéger). Une potion de serveur achetée transforme tout le monde pendant 60 secondes, ce qui fait un achat social visible.

**Accroches de rétention et de co-play pour l'algorithme 28 jours.**

- **Co-play** : une boutique partagée, avec **+25 % de vitesse par ami présent** (plafonné à 4). Des « commandes géantes » demandent deux joueurs en même temps. Bonus d'invitation.
- **J1 et J2–7** : un grimoire de 60 à 100 recettes à découvrir (de simples données dans `src/shared/Config`), une récompense de connexion quotidienne et une « potion du jour » à 3 commandes.
- **J8–28** : un **rendez-vous fixe**, le « Sabbat du samedi » (une heure de chances ×5 et de clients rares, animée en direct par vous, comme l'admin abuse). Une saison de 28 jours avec un classement des boutiques et une décoration exclusive en fin de saison.

**Échelle de prix (Robux).**

| Produit | Type | Prix |
|---|---|---|
| Potion « farce » serveur (tout le monde rétrécit 60 s) | Produit répétable, social | 49 R$ |
| Sac d'ingrédients rares (contenu connu) ×1 / ×3 / ×10 | Produit répétable, dégressif | 99 / 249 / 699 R$ |
| Accélérateur de mijotage 30 min | Produit répétable | 129 R$ |
| Chaudron ×2 (permanent) | Game pass | 249 R$ |
| VIP boutique (+1 étagère, tag, décoration) | Game pass | 399 R$ |
| Assistant automatique (sert les clients en idle) | Game pass | 499 R$ |
| Chaudron légendaire cosmétique (aura serveur) | Ancre « baleine » | 2 499 R$ |
| Plus tard : « Chaudron mystère » (aléatoire payant) | Avec probabilités et PolicyService | 149 R$ |

**MVP minimal.** Une seule boutique-instance par groupe (de 1 à 4 joueurs par parcelle sur un serveur de 16 à 20 joueurs). 12 ingrédients et 30 recettes. 3 niveaux de chaudron. 8 effets d'avatar. Des clients PNJ en R15 avec des tenues gratuites. Sauvegarde ProfileStore. 3 passes et 3 produits. Un tutoriel de 45 secondes intégré au jeu, sans texte long. 3 à 5 miniatures.

**Roadmap jusqu'au MVP (4 semaines).**

| Semaine | Objectif | Livrables |
|---|---|---|
| 1 | Valider la boucle en 1 minute | Prototype en primitives : ingrédient → chaudron → potion → client → pièces. Tester sur 5 amis : comprennent-ils sans explication ? |
| 2 | Progression et persistance | ProfileStore, achats d'améliorations, grimoire, revenu idle, Config d'équilibrage, serveur qui fait autorité sur tout |
| 3 | Social et monétisation | Boutiques partagées, bonus d'ami, effets d'avatar, `ProcessReceipt` idempotent, 3 passes et 3 produits, interface mobile |
| 4 | Lancement test | Quotidiens, premier Sabbat, miniatures, analytics, publication 16+, pub de 100 à 200 $, mesure de J1, du rebond et de la session |

### Concept B : Enchères Mystères (salle des ventes en direct)

**Pitch.** Toutes les 3 minutes, un lot scellé (caisse, valise, conteneur) passe aux enchères devant tout le serveur. On n'en voit que quelques indices : silhouette, poids, provenance. Le gagnant l'ouvre devant tout le monde, avec une animation de révélation. Il expose ensuite ses trouvailles dans son musée, qui attire des visiteurs et rapporte un revenu passif, ou il les revend.

**Boucle centrale.** Observer les indices, enchérir en pièces du jeu, révéler le contenu, estimer sa valeur, exposer ou revendre, améliorer le musée, puis viser des lots plus chers.

**Ce qui le rend original.** C'est un format « Storage Wars » encore absent des tendances repérées. Le moment social vient de la **guerre d'enchères** en direct, pas du vol. Pour éviter qu'un serveur vide tue l'ambiance, des enchérisseurs PNJ aux personnalités marquées (« la Comtesse », « le Brocanteur ») relancent les enchères.

**Viral hook.** La révélation d'un objet légendaire dans un lot acheté 50 pièces, qui donne des réactions de stream et des clips TikTok. Une « Vente Flash » achetée par un joueur fait passer un lot rare devant tout le serveur.

**Rétention et co-play.**

- **Co-play** : le mode « Associés » (2 amis mettent leurs mises en commun et partagent le butin) et un musée co-détenu.
- **J2–7** : des sets de collection à compléter, avec un bonus quand un set est fini.
- **J8–28** : la « Grande Vente » à heure fixe chaque jour, la « Vente des Collectionneurs » hebdomadaire animée en direct, et un classement des musées sur 28 jours.

**Échelle de prix.**

| Produit | Type | Prix |
|---|---|---|
| Vente Flash serveur | Produit répétable, social | 99 R$ |
| Loupe d'expert (révèle un indice) | Produit répétable | 49 R$ |
| Sac de pièces ×1 / ×3 / ×10 | Produit répétable | 99 / 279 / 799 R$ |
| Musée +6 vitrines | Game pass | 299 R$ |
| Revenu musée ×2 | Game pass | 399 R$ |
| Marteau de commissaire-priseur doré (cosmétique et titre) | Ancre « baleine » | 1 999 R$ |
| « Lot privé » (aléatoire payant) | Probabilités affichées et PolicyService **obligatoires** | 149 R$ |

**Points d'attention.** Le thème frôle l'esthétique du jeu d'argent. Gardez des enchères **en monnaie du jeu uniquement**, sans échange d'objets contre des Robux, et ne lancez pas le « Lot privé » sans affichage des probabilités. Avec un public jeune, la revue Kids/Select sera plus délicate. Il faut beaucoup d'objets (60 au minimum), mais ils peuvent être présentés sous forme d'**icônes 2D** ou de modèles gratuits. L'économie (inflation, duplication) est le principal risque technique.

**MVP minimal.** Une salle des ventes, 1 enchère toutes les 3 minutes, 5 enchérisseurs PNJ, 60 objets répartis sur 5 raretés et 6 sets, un musée personnel avec revenu idle, la revente au comptoir et 2 passes + 3 produits.

**Roadmap (4 semaines).** Semaine 1 : enchère serveur avec PNJ et révélation, testées entre amis. Semaine 2 : objets en Config, raretés, musée, ProfileStore, protection anti-duplication. Semaine 3 : Associés, Vente Flash, passes, interface mobile. Semaine 4 : Grande Vente quotidienne, miniatures, lancement 16+ et pub de test.

### Concept C : Ligue des Cartes Pliées (auto-battler de cartes)

**Pitch.** Un auto-battler au tour par tour en interface 2D. On compose un deck de 8 créatures en origami, on le place sur une grille de 3×3, et le combat se joue tout seul en 30 secondes. Il y a des duels classés, du 2v2 entre amis et des saisons.

**Pourquoi l'envisager.** La **stratégie est sous-représentée** selon Roblox, alors que les joueurs plus âgés la demandent ([Roblox Newsroom](https://about.roblox.com/newsroom/2026/03/roblox-announces-incubator-jumpstart-creator-programs)). Le jeu est presque entièrement en interface, donc idéal pour Claude. Les saisons classées soutiennent bien la rétention J8–28. Enfin, le jeu attire les adultes, qui monétisent plus et ouvrent droit au taux DevEx majoré.

**Pourquoi c'est risqué.** Aucun jeu de cartes ne figure parmi les hits Roblox récents. Expliquer les règles en moins de 60 secondes est difficile, et le taux de rebond risque d'être élevé. Il faut **40 illustrations au minimum**, en 2D originales : IA générative ou dessin simple, à faire modérer, et attention à la propriété intellectuelle. Le jeu se clippe aussi moins bien sur TikTok.

**Monétisation.** Un pass de saison (499 R$), des boosters de 5 cartes à contenu **affiché** (149 R$, ou aléatoire avec probabilités affichées), des cosmétiques de plateau (99 à 399 R$) et un dos de carte holographique « baleine » (1 999 R$). Pas d'achat de puissance pure : le classé doit rester juste.

**MVP minimal.** 40 cartes, un mode contre IA, un 1v1 asynchrone (qui affronte le deck sauvegardé d'un autre joueur, sans netcode temps réel), un classement simple, 1 pass et 2 produits. Roadmap : semaine 1, moteur de combat en Luau avec tests unitaires ; semaine 2, deckbuilding et interface ; semaine 3, 1v1 asynchrone, classement et ProfileStore ; semaine 4, illustrations, 2v2 avec un ami, puis lancement.

## Recommandation et décision stratégique

### Commencer par Potion Panique

**Potion Panique** obtient la meilleure note pour plusieurs raisons. C'est le concept qui fonctionne déjà avec un seul joueur (clients PNJ) mais qui devient meilleur à plusieurs, ce qui en fait le signal co-play parfait. Il est lisible en 10 secondes, donc il limite le rebond de moins de 60 s. Il produit des clips naturels grâce aux effets d'avatar. Il reste compatible avec le classement « Mild » des jeux tous âges. Enfin, ses besoins en 3D se limitent à des étagères, un chaudron et des particules. Enchères Mystères a un potentiel de revenus légèrement supérieur, mais dépend d'un serveur bien rempli et d'une économie plus fragile. Il peut devenir le **deuxième jeu**, ou un mode « vente aux enchères d'ingrédients rares » dans Potion Panique si la rétention tient. Gardez la discipline des hits : si après le test publicitaire de la semaine 4 le J1 reste **sous 10 %** malgré deux itérations, changez de concept plutôt que de polir.

### La décision clé : tous âges plutôt que 18+ exclusif

Je recommande un **jeu conçu pour tous les âges (contenu Mild), lancé d'abord pour les 16+, puis soumis à la revue Kids/Select dès que J1 est validé. Il doit être construit en R15 uniquement** pour toucher quand même le taux majoré sur les dépenses des adultes américains. Le raisonnement chiffré est le suivant. Le taux majoré ajoute **42 % sur la seule part des revenus** qui vient d'adultes américains vérifiés. Or les États-Unis et le Canada pèsent environ 53 % des bookings (907 M$ sur 1 697 M$, d'après [Investing.com](https://au.investing.com/news/stock-market-news/roblox-q3-2026-slides-first-user-decline-marks-inflection-point-93CH-4727761)), et les 18+ ne forment que 37 % des DAU américains vérifiés. Pour un jeu grand public, le gain total reste donc probablement de l'ordre de **+10 à +20 % des revenus** (estimation personnelle, non sourcée). À l'inverse, un jeu exclusivement adulte se prive des 9–15 ans et oblige à choisir les genres que les adultes préfèrent (shooter, RPG, stratégie), qui sont justement les plus durs à faire en solo. Le chemin 16+ d'abord a aussi un avantage pratique : il permet de publier **immédiatement**, puisqu'un jeu pas encore revu reste visible aux 16+, sans attendre la revue ni payer la revue accélérée de 100 000 R$. La seule exception est Ligue des Cartes Pliées, qui gagnerait à cibler franchement les 16+/adultes si vous la choisissez. Incertitude à lever : on ne sait pas si un jeu ouvert à tous les âges reste « éligible » au taux 18+. Les critères complets n'ont pas pu être lus, donc **vérifiez la page officielle** avant de figer ce choix.

### Tes tâches

- Activer la **2FA** et la **vérification d'identité** sur le compte Roblox. Vérifier ton âge (nécessaire pour publier en 16+ et pour la revue tous âges).
- Lire et confirmer sur le Creator Hub les points suivants : les critères d'éligibilité du [taux DevEx 18+](https://create.roblox.com/docs/production/monetization/18-plus-devex-rate), le montant des frais de publication tous âges et le partage des abonnements.
- Prévoir **100 à 200 $** de budget Ads Manager pour la semaine 4. Préparer 3 à 5 miniatures et une icône. Je peux décrire les compositions, mais c'est à toi de les produire ou de les valider.
- Recruter 5 à 10 testeurs (amis, Discord) pour le test de la semaine 1, et réserver un créneau fixe chaque samedi pour animer le « Sabbat » en direct.
- Créer un compte TikTok ou YouTube Shorts pour poster les clips d'effets de potion. Le dev qui se met en scène a été un moteur pour Grow a Garden.

## Conclusion

Ce qui a changé en 2026, c'est que la discoverability ne s'achète plus : elle se mérite sur 28 jours. Les joueurs payés via la pub ne sont pas comptés dans le classement. Pour un solo, c'est une bonne nouvelle déguisée. Le budget publicitaire n'a plus besoin d'être gros : 100 à 200 $ suffisent pour être testé par l'algorithme. Ce qui décide du résultat, c'est la qualité des 3 premières minutes et la raison de revenir avec un ami, deux choses que le code et le game design contrôlent mieux que la 3D. L'autre enseignement est que le danger principal n'est pas de rater le lancement mais de mal gérer le succès. Les hits perdent environ 90 % de leur pic, et tous les méga-hits ont fini par s'appuyer sur une équipe. Il faut donc concevoir dès le premier jour un rythme de mises à jour hebdomadaires tenable seul, grâce à du contenu piloté par la Config et des événements live peu coûteux. Il faut aussi accepter qu'au-delà de quelques milliers de joueurs simultanés, la décision rentable sera peut-être de s'associer avec un studio, ou de vendre une partie du jeu, plutôt que de tout porter seul.
