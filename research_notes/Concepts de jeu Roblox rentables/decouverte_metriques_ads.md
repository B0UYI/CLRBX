# Roblox discovery, key metrics and paid acquisition (state as of November 2026)

> Method note: these notes come from web search results only. Direct page fetches were blocked by the session's network policy, which does not allow about.roblox.com, devforum.roblox.com, create.roblox.com or gameanalytics.com. Quotes and figures from official Roblox pages are therefore taken from search snippets and secondary summaries, not from reading the full pages. Each item is labelled **[Official]**, **[3rd-party]** or **[Uncertain]**.

## 1. What Roblox has officially said about its recommendation algorithm (2025–2026), and what changed in 2026

### Takeaway
The biggest 2026 change landed around 15 June 2026. "Recommended For You" (RFY) on Home moved from a 7-day evaluation window to a 28-day one that measures long-term retention (D1, D2–7, D8–28). qPTR (qualified play-through rate) was dropped and replaced by PTR plus "first play bounce rate". Only organic RFY traffic counts in the ranking stage. Roblox accepted the short-term monetization cost on purpose: the stock fell 27% on 31 July 2026 and Q3 2026 bookings were guided down 14–18% year on year.

### Cited Findings
- **[Official]** Roblox's "Optimizing Discovery: How Great Games Reach Millions of Players on Roblox" (newsroom, June 2026) is the reference text for the new discovery approach — [Roblox Newsroom](https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox)
- **[Official]** DevForum post "Recommended For You Algorithm Improvements That Better Value Long-Term Retention". RFY now measures retention over Day 1, Day 2–7 and Day 8–28, using playtime, play days, qualified play sessions, intentional co-play days, spend days and Robux spent. qPTR was removed and PTR plus first-play bounce rates were added, "to separate play-through, session quality and retention measurement" — [DevForum](https://devforum.roblox.com/t/recommended-for-you-algorithm-improvements-that-better-value-long-term-retention/4684575)
- **[3rd-party]** The rollout is dated 15 June 2026 — [Zehn Studio](https://zehn-studio26.com/news/recommended-for-you-retention-update/); [sozai.app transcript](https://sozai.app/transcript/roblox-algorithm-changes-june-2026/)
- **[Official]** Signal definitions from the Discovery doc. **Play-through rate** is the rate at which users play your game after seeing it in RFY. **First play bounce rate** is the rate at which users leave your game after a short session, measured in two windows: under 60 s and 61–180 s. It is a negative signal and among the "most important" ones. Only players who joined organically from RFY count. Playtime is capped at 60 min per user, per game, per day — [Creator Hub – Discovery](https://create.roblox.com/docs/discovery)
- **[3rd-party / Uncertain]** Weighting: four signals marked "Important", all per user: intentional co-play days, qualified play sessions, spend days and Robux spent. The other signals are averaged over D1 / D2–7 / D8–28. The official table could not be read in full, and the relative weight of the D1 / D2–7 / D8–28 buckets has not been published — [Zehn Studio](https://zehn-studio26.com/news/recommended-for-you-discovery-rollout/); [allthings.how](https://allthings.how/robloxs-new-recommended-for-you-algorithm-rewards-games-that-keep-you-hooked/)
- **[Official]** Exposure mechanics from the Discovery FAQ:
  - The *retrieval* stage needs only "a very low minimum number of plays from any source".
  - The *ranking* stage then tests the game on a small set of users and keeps monitoring retention. If performance improves, impressions increase.
  - Roblox **does not count** the engagement, monetization or retention of users first acquired through ads, curation, friends, search, social media or any other source in the ranking stage.
  - Returning traffic from "Continue" does not count either.
  - It is "very unlikely" a game has a strong D8–28 signal if D1 and D2–7 are poor, and some genres naturally have lower D8–28 retention.

  — [Creator Hub – Discovery FAQ](https://create.roblox.com/docs/discovery-faq)
- **[Official, 2025]** An earlier step in March–April 2025 improved the RFY algorithm and added discovery analytics for creators — [DevForum 2025](https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441). Tests of RFY improvements were already running at the end of 2024 — [DevForum](https://devforum.roblox.com/t/testing-improvements-to-the-%E2%80%9Crecommended-for-you%E2%80%9D-algorithms/3275201)
- **[3rd-party, financial press]** Market impact:
  - On 31 July 2026 RBLX closed down about 27% at $35.60, roughly $9B of market value lost and the worst day on record.
  - Q2 2026 bookings were $1.56B, at the low end of guidance.
  - Q3 guidance was $1.58–1.65B (−14% to −18% YoY), the first guided decline since the IPO, and the full-year outlook was withdrawn.
  - Roblox said the change was deliberate: retention-heavy games gain visibility even when they generate less spending per hour, and internal tests suggest retention gains will outweigh the drop.
  - Other headwinds cited: weaker under-13 users in the US, and age verification introduced in November 2025.

  — [Yahoo Finance/Reuters](https://finance.yahoo.com/markets/stocks/articles/roblox-set-worst-one-day-154930126.html); [Deutsche Bank via Yahoo](https://finance.yahoo.com/markets/stocks/articles/deutsche-bank-sees-jarring-signs-171700088.html); [godisageek](https://godisageek.com/2026/08/roblox-9-billion-algorithm-change/)
- **[Conflict]** One source says the adjustment toward retention began in **April** 2026, before the June announcement — [godisageek](https://godisageek.com/2026/08/roblox-9-billion-algorithm-change/). Other sources say June — [lensblox](https://lensblox.com/blog/roblox-algorithm-change-2026-explained/)
- **[Official, 2024]** Thumbnail personalization: creators activate 2 to 5 thumbnails, and Roblox shows each user the best-performing one. It launched to all creators on 13 Nov 2024, with an average qPTR lift of +8.5% and up to +50% for some games — [DevForum](https://devforum.roblox.com/t/get-your-thumbnails-ready-for-thumbnail-personalization/3226599); [DevForum July 2024 test](https://devforum.roblox.com/t/testing-personalized-thumbnails-in-home-this-july/3039419)
- **[Official, 2026]** On 24 Aug 2026 new Open Cloud APIs arrived: Analytics, Events, Experiments and Thumbnail Personalization — [DevForum](https://devforum.roblox.com/t/new-opencloud-apis-for-analytics-events-experiments-and-thumbnail-personalization/4828676). **[3rd-party]** The Experiments API reportedly does not cover thumbnails, so you cannot read which thumbnail "won" through it. The feature behaves like a multi-armed bandit rather than a classic A/B test — [Zehn Studio](https://zehn-studio26.com/news/experiment-targeting-and-analytics-apis/)
- **[3rd-party]** There is no native A/B testing for game **icons**, only thumbnails (as of May 2026) — [creatorxp.gg](https://creatorxp.gg/guides/roblox-game-icon-mistakes)
- **[3rd-party, needs verification]** Two changes in October 2026:
  - From 12 Oct, how impressions, clicks and plays from Home, Search and Charts are recorded changed. Counts may rise and PTR may dip slightly.
  - From 19 Oct, Home recommendations exclude games that only have the default thumbnail.

  — [Zehn Studio](https://zehn-studio26.com/news/brand-world-launch-playbook/)
- **[Official, 2025]** Search moved into the new Ads Manager flow at the end of 2025, adding promoted Search results — [DevForum RDC 2025 recap](https://devforum.roblox.com/t/ads-for-creators-rdc-recap-and-what%E2%80%99s-next/3929106)
- **[3rd-party]** The Charts ("Top Trending", "Up-and-Coming") show a % change and a player count, plus a "New" label for games found in the last 14 days. Roblox publishes no ranking method for them — [roblox.com/charts/up-and-coming](https://www.roblox.com/charts/up-and-coming); [RoStats](https://rostats.io/top/top-trending)

### Inferences
- For a new game, organic RFY traffic is the only traffic that "trains" the ranking. Ads, influencers and Discord can get the game past the retrieval threshold, which is low, but their players do not count in the scoring. Paid UA starts the engine; it does not rank the game.
- Since June 2026, the first 3 minutes (bounce under 60 s and 61–180 s), co-play with friends and returns from D2 to D28 count more than monetization per hour. Short-term "cash-grab" designs (aggressive gacha, early paywall) are penalised relative to before. Spend days and Robux spent still count, though, so regular spending spread over many days is better than a single big purchase.
- With a 28-day window, a new game probably needs about 4 weeks before its full signal stabilises. This is a likely implication, not an officially confirmed one.
- Thumbnails matter more than before: a default thumbnail is excluded from Home, and PTR is a lead signal. Running 3–5 thumbnails through personalization from launch day is a no-cost lever.

### Gaps
- No official ranking method found for Today's Picks (editorial curation?), the Charts (Top Trending, Up-and-Coming), Search ranking or friend activity. The "Today's Picks" sort could not be documented at all.
- Exact signal weights and how cold start works under the 28-day window have not been published.
- Full texts of the June 2026 newsroom post and the DevForum post could not be read (domains blocked).

## 2. Benchmarks: D1/D7/D30 retention, session length, payer conversion, ARPDAU/ARPPU

### Takeaway
GameAnalytics 2026 (games with ≥1M MAU, Aug 2025–Jul 2026) gives a median of 10.3% D1, 1.6% D7 and about 0.5% D30. The top 1% reach 22.2% D1 and 9.1% D7. The median session is 9.8 min per game. About 3.8% of players pay. Median ARPPU figures are inconsistent across sources. The Roblox dashboard benchmarks against the 50th–90th percentile of similar games, and its sample D1 range is 12.1% to 18.7%.

### Cited Findings
- **[Official]** The Creator Analytics dashboard benchmarks each KPI (retention, ARPDAU, ARPPU, conversion) against the 50th–90th percentile of "similar experiences". The documented example D1 range is 12.11%–18.73%. Roblox advises getting payer conversion and ARPPU "comparable or above" your similar-game benchmark — [Creator Hub – Analytics dashboard (GitHub creator-docs)](https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/analytics/analytics-dashboard.md); [Creator Hub – Analytics](https://create.roblox.com/docs/production/analytics)
- **[Official, 2025]** You can now view retention by acquisition source and choose your benchmark set — [DevForum](https://devforum.roblox.com/t/analytics-view-retention-by-acquisition-source-and-select-your-benchmark-set/4010157); [Acquisition doc](https://create.roblox.com/docs/production/analytics/acquisition)
- **[3rd-party, strong]** GameAnalytics "2026 Roblox Benchmark Report":
  - Sample: over 500 titles (538 per the hub) with ≥1M MAU between 1 Aug 2025 and 31 Jul 2026.
  - Retention: median D1 10.3% and D7 1.6%; top 1% D1 22.2% and D7 9.1%.
  - Warning from the report: the D1 "good" and "excellent" thresholds of 20% and 40% that circulate come from small samples of games that were already successful.

  — [GameAnalytics 2026](https://www.gameanalytics.com/reports/2026-roblox-report); [gamedevreports summary](https://gamedevreports.substack.com/p/gameanalytics-key-roblox-and-roblox)
- **[3rd-party]** D30 median of about 0.5%, from a secondary write-up of the same report — [gamedevreports](https://gamedevreports.substack.com/p/gameanalytics-key-roblox-and-roblox)
- **[3rd-party]** Session length per game: p25 7.3 min, p50 9.8, p75 12.0, p90 14.7, p95 16.6, p99 21.1. The per-player median session is 7.28 min — [GameAnalytics 2026](https://www.gameanalytics.com/reports/2026-roblox-report)
- **[3rd-party]** Payer conversion: 3.80% of players spent something over the year, down from 4.2% two years earlier — [gamedevreports](https://gamedevreports.substack.com/p/gameanalytics-key-roblox-and-roblox)
- **[Uncertain / Conflict]** ARPPU:
  - Secondary summary: median $0.70, top 1% $55.31 — [gamedevreports](https://gamedevreports.substack.com/p/gameanalytics-key-roblox-and-roblox)
  - The GameAnalytics Benchmarks Hub shows unlabelled values of 4.73, 10.93, 25.43 and 212.94 USD, which do not reconcile with the summary — [GameAnalytics Hub](https://www.gameanalytics.com/benchmarks-hub)
  - 2025 report: ARPPU around $5.42 at p98 for the shortest-session bucket — [GameAnalytics 2025](https://www.gameanalytics.com/reports/2025-roblox-report)
- **[Official]** Discovery playtime counts at most 60 min per user, per game, per day — [Creator Hub – Discovery](https://create.roblox.com/docs/discovery)

### Inferences
- Practical targets for a new game, using the GameAnalytics 2026 percentiles:
  - D1: ≥12–15% to sit above the median; ≥20% to be in roughly the top few percent.
  - D7: ≥3–5% is good (median 1.6%); 9% is top 1%.
  - Session length: ≥12 min (p75).
- The sample covers only games with ≥1M MAU, so the medians for *all* new games are probably lower (survivorship bias).
- The Roblox dashboard benchmark (similar games, p50–p90) is the best comparison for a specific genre.

### Gaps
- No reliable public ARPDAU benchmark found.
- No ARPPU or retention benchmarks by genre found.
- The ARPPU figures conflict and could not be checked against the primary report.

## 3. Sponsored experiences / Ads Manager in 2026: how they work, cost, minimum budgets, effectiveness

### Takeaway
Sponsored experiences are bought through Ads Manager on a cost per play (CPP) basis, with objectives for Plays, new users, and Earnings (optimised for ROAS). Roblox says the average CPP is now **under $0.01** and 71% cheaper. Third-party figures are much higher ($0.05–0.45) and are vendor marketing, so unreliable. In 2026 Roblox added Unified Attribution (May), Estimated ROAS and incrementality studies: a median +14% in incremental sessions, and 21 of 21 campaigns produced incremental plays. Players acquired through ads do not count in RFY ranking.

### Cited Findings
- **[Official]** Billing is cost per play: you pay per Play. A Play is a click on the sponsored experience, a landing on its detail page, then a join within 1 hour. The "Highly Engaged Player" objective has a higher CPP because the audience is smaller. The Earnings objective targets likely spenders and also has a higher CPP — [Creator Hub – Ads Manager](https://create.roblox.com/docs/production/promotion/ads-manager)
- **[Official, RDC Sept 2025]** CPP is "over 71% cheaper thanks to performance improvements… you can now get a player into your experience for less than $0.01". The Earnings objective (ROAS) is rolling out to nearly 30,000 eligible games. Rewarded Video is opening to tens of thousands of creators. Promoted Search results arrive at the end of 2025 — [DevForum RDC 2025 recap](https://devforum.roblox.com/t/ads-for-creators-rdc-recap-and-what%E2%80%99s-next/3929106)
- **[Official, 2025]** An earlier post says the average CPP for "Maximize Plays" campaigns is under $0.01. Other 2025 additions: an "Acquire new users" objective, continuous campaigns and more — [DevForum Leveling Up Ads Manager](https://devforum.roblox.com/t/leveling-up-ads-manager-with-new-features/3587640); [DevForum Acquire New Users](https://devforum.roblox.com/t/ads-manager-updates-acquire-new-users-continuous-campaigns-and-more/3862159); [More Ads Manager Upgrades](https://devforum.roblox.com/t/more-ads-manager-upgrades/3659656)
- **[Official, 2026]** "Ads Manager Updates – Maximize Earnings, Attribution Updates, New Tile in Beta". Earnings attributed to ads were "meaningfully higher" than for Plays campaigns, and most were ROAS-positive within 30 days. A new featured Home tile is in beta, with a **$5K USD minimum** campaign investment for that tile — [DevForum](https://devforum.roblox.com/t/ads-manager-updates-maximize-earnings-attribution-updates-new-tile-in-beta-other-updates/4623762); budget detail via [bloxg / clipclip](https://clipclip.io/guides/roblox-ads-cost) **[Uncertain]**
- **[Official, RDC Sept 2026]** "Ads Manager RDC Recap: Earnings, ROAS Reporting & Incrementality":
  - Unified Attribution launched in May 2026.
  - Randomised incrementality studies: "All 21 campaigns brought incremental plays", with a median +14% in incremental play sessions for users exposed to ads.
  - New "Estimated ROAS" metric gives an early read weeks before earnings fully accrue.
  - Reporting now includes Creator Rewards, Immersive Ads and Rewarded Video earnings.

  — [DevForum](https://devforum.roblox.com/t/ads-manager-rdc-recap-earnings-roas-reporting-incrementality/4909790)
- **[Official]** New advertising policies and standards apply in 2026 — [DevForum](https://devforum.roblox.com/t/new-advertising-policies-standards/4527365). Paid-access and 17+ experiences can now be advertised — [DevForum](https://devforum.roblox.com/t/advertising-paid-access-restricted-17-experiences/3432252)
- **[3rd-party / Uncertain]** Minimum budget:
  - One guide says the docs set no minimum, and the first card payment is $5.
  - Others suggest $1/day minimum and $10–50/day for testing, or $10–20/day with $50+/day recommended.

  — [clipclip.io](https://clipclip.io/guides/roblox-ads-cost); [bloxg guide](https://bloxg.com/guides/roblox-ads-guide)
- **[3rd-party / Conflict]** CPP estimates that contradict the official figure:
  - $0.01–0.05 per visit.
  - $0.10–0.50 per click.
  - Average CPP of $0.45 for Sponsored Experiences, from bloxg, a seller of marketing services that claims data from 850+ games.
  - 4–12 Robux per visit, from DevForum developer reports (older).

  — [bloxg benchmarks](https://bloxg.com/statistics/roblox-advertising-benchmarks); [Gupta Media 2025](https://www.guptamedia.com/insights/roblox-advertising); [bloxg cost](https://bloxg.com/how-much-does-roblox-marketing-cost)
- **[Official, older, 2023]** Sponsored experiences moved to Ads Manager in 2023, with a minimum bid of 0.01 ad credit per play. Developers complained about rising costs — [DevForum 2023](https://devforum.roblox.com/t/sponsored-experiences-moving-to-ads-manager/2661756)
- **[3rd-party]** "Roblox Ads in 2026: The Break-Even Math Small Devs Ignore". Its argument: paid UA is profitable only if LTV per acquired player is above CPP — [RoWatcher](https://rowatcher.com/news/roblox-ads-in-2026-the-break-even-math-small-devs-ignore)

### Inferences
- At under $0.01 per play, 10,000 plays cost under about $100. That clears the "very low minimum number of plays" retrieval threshold. RFY scoring then depends only on the organic cohort, so ads are mainly a way to get *tested*, plus a direct ROAS lever once monetization works.
- Recommended sequence for a small game:
  1. Plays objective with a small budget, to validate PTR, bounce and D1 on a real cohort (retention is visible by acquisition source).
  2. Earnings objective only once ARPPU and conversion reach the benchmark.
- Using official LTV figures (median ARPPU of $0.70 × 3.8% conversion ≈ $0.027 per player) is uncertain. Even so, a CPP under $0.01 looks ROAS-positive for a median game, which is consistent with Roblox's claim of "most ROAS-positive within 30 days". This is a fragile calculation.

### Gaps
- No official minimum budget found, apart from the $5K for the featured Home tile.
- No 2026 CPM published.
- No official 2026 CPP by objective (Earnings or new users) found.

## 4. Other UA channels (YouTube/TikTok creators, influencers, Discord): what works for small developers

### Takeaway
Influencer prices vary widely and come mostly from vendors or marketplaces. Ranges: micro creators $20–2,000 per video, mid-tier $200–10,000, macro $2,000–20,000+. The common advice is many small creators rather than one large one. Because of the 2026 algorithm, these players do not count in RFY scoring. They mainly help with the retrieval threshold, social proof (co-play with friends) and building a community that returns (D8–28).

### Cited Findings
- **[3rd-party]** YouTube 2025–2026: micro $500–2,000, mid-tier $5,000–10,000, 1M+ subscribers $20,000+. Roblox creators charge 30–50% less than Fortnite creators. Collabstr listings in Oct 2026 ran from $50 (2 UGC videos) to $450 (one TikTok). Recommendation: several small or mid creators, paid per view rather than per post — [MetaClip](https://metaclip.app/guides/roblox-influencer-marketing)
- **[3rd-party, vendor]** Micro (1K–50K followers) $20–200 per video, mid $200–2,000, macro $2,000–20,000+. Estimated average CPP: micro $0.08, mid $0.15, macro $0.35, vs $0.45 for Sponsored. Indie budgets of $50–200/month; launch baseline of $2,000–5,000 over 7 days — [bloxg marketing guide](https://bloxg.com/guides/roblox-marketing); [bloxg benchmarks](https://bloxg.com/statistics/roblox-advertising-benchmarks); [bloxg indie](https://bloxg.com/roblox-indie-developer-marketing)
- **[3rd-party]** Small creators list videos at under $50; channels with 200K+ views start at about $100–200 per video — [bloxg cost](https://bloxg.com/how-much-does-roblox-marketing-cost)
- **[3rd-party]** Launch checklist and "blue ocean" strategy (pick a niche with little competition) — [RoWatcher checklist](https://rowatcher.com/news/the-complete-roblox-game-launch-checklist-for-2026); [RoWatcher blue ocean](https://rowatcher.com/news/why-nobody-finds-your-roblox-game-and-the-blue-ocean-strategy-that-fixes-it)
- **[3rd-party]** Analysis of what makes a new game take off — [Dubit](https://dubit.io/library/what-makes-a-new-roblox-game-take-off)
- **[Official]** Friends and social traffic do not count in RFY ranking. "Intentional co-play days" is an "Important" signal — [Discovery FAQ](https://create.roblox.com/docs/discovery-faq); [DevForum 4684575](https://devforum.roblox.com/t/recommended-for-you-algorithm-improvements-that-better-value-long-term-retention/4684575)

### Inferences
- Influencer CPP ($0.08–0.35, vendor estimates) looks 10–40 times more expensive than Roblox's official native CPP (under $0.01). Influencers are worth it for community, virality and wishlist-style effects, not raw volume.
- Discord, group shouts and in-game invitations build co-play and returns, which feed the 2026 "Important" signals.

### Gaps
- No independent small-developer postmortem with actual spend vs. results found for 2025–2026.
- No hard data on Discord or TikTok effectiveness found; the prices are mostly vendor claims.

## 5. Monetization beyond purchases: Creator Rewards, immersive and rewarded ads, subscriptions, commerce, DevEx

### Takeaway
Creator Rewards (launched July 2025) pays **5 Robux per Active Spender** who plays ≥10 min per day, counting only the first 3 experiences that user opens that day. It also includes Audience Expansion: 35% of the first $100 spent by new or returning users during their first 2 months. Rewarded Video opened to all ads-eligible creators in Feb 2026 (games over 2,000 monthly visitors). Subscriptions pay 70%, rising to 100% in later months for local-currency subscriptions. Shopify commerce has existed since May 2025. DevEx standard rate: $0.0038 per Robux, and $0.0054 for US 18+ spend since June 2026.

### Cited Findings
- **[Official]** Daily Engagement Rewards rules:
  - 5 Robux per user who spends ≥10 min in the experience in a day.
  - Only the first 3 experiences that user opens that day count.
  - The user must be an "Active Spender" (≥$9.99 spent in the last 60 days).
  - Automatic for all creators from 24 July 2025, with a 60-day holding period.
  - Audience Expansion: 35% of the first $100 in Robux purchases by new or returning users during their first two months.

  — [Creator Hub – Creator Rewards](https://create.roblox.com/docs/en-us/creator-rewards.md); [DevForum launch](https://devforum.roblox.com/t/introducing-creator-rewards-earn-more-by-growing-the-community/3777628)
- **[3rd-party / Uncertain]** A threshold of 100+ DAU sustained for 60 days is mentioned but not confirmed officially — [LootTally](https://loottally.com/premium-payouts-calculator). Creator Rewards replaces Premium Payouts and the Creator Affiliate program — [Roblox wiki](https://roblox.fandom.com/wiki/Creator_Rewards)
- **[Official]** Rewarded Video is available to all ads-eligible creators since Feb 2026. Requirements: creator 13+ (previously 18+) with 2FA; public, unrestricted experience with >2,000 unique monthly visitors; no free-form user creation and no AI interaction — [DevForum](https://devforum.roblox.com/t/rewarded-video-ads-are-now-available-to-all-ads-eligible-creators/4063278); [DevForum 2025](https://devforum.roblox.com/t/more-creators-can-now-use-rewarded-video-ads/3838678)
- **[3rd-party, RDC Sept 2026]** Planned items:
  - A Studio plug-in with 2D/3D templates in Q4 2026.
  - A rewarded video surface before gameplay starts.
  - A multi-reward option later.
  - Advertiser side: >90% completion and >95% viewability across >1,000 brands.

  — [MediaPost 15/09/2026](https://www.mediapost.com/publications/article/417959/roblox-eyes-expanded-placements-for-rewarded-vid.html); [eMarketer](https://www.emarketer.com/content/roblox-expands-rewarded-video-tools-creators-advertisers)
- **[Uncertain]** Ad revenue for creators:
  - About 452 Robux (≈$1.59) per 1,000 immersive video views, and there is often too little ad inventory to fill placements (developer analysis on DevForum).
  - Rewarded video at an estimated $6–12 eCPM (ROLearn estimate).

  — [DevForum RDC recap p.2](https://devforum.roblox.com/t/ads-for-creators-rdc-recap-and-what%E2%80%99s-next/3929106?page=2); [ROLearn](https://rolearn.dev/insights/rewarded-video-ads-new-revenue-stream/)
- **[Official]** Subscriptions: revenue arrives in Robux. Payout is 70% per month for Robux pricing; for local-currency pricing it is 70% in the first month and 100% in later months. Local currency requires an account verified by ID or phone and is unavailable in India, Japan, Türkiye and others — [Creator Hub – Subscriptions](https://create.roblox.com/docs/production/monetization/subscriptions)
- **[Official, May 2025]** Shopify integration (Commerce APIs) lets creators sell physical products in all-ages experiences, to US users aged 13+.
  - Creator requirements: 18+, ID, email and 2FA verified, a Shopify merchant, in good standing.
  - Bundling a physical product with a digital item requires ≥100K average DAU and 1M Robux earned in 3 months, or $50K of ad spend in agreement with Roblox.

  — [Roblox Newsroom](https://corp.roblox.com/newsroom/2025/05/roblox-launches-shopify-integration-amp-licensing-program); [DevForum](https://devforum.roblox.com/t/expanding-how-commerce-can-help-you-earn-and-grow-your-communities/3651181); [TechCrunch](https://techcrunch.com/2025/05/15/roblox-now-lets-creators-sell-physical-products-within-their-experiences)
- **[3rd-party, multiple sources]** DevEx rates:
  - $0.0038 per Robux for Robux earned from 5 Sept 2025 (previously $0.0035).
  - $0.0054 from 8 June 2026 for developer products, passes, subscriptions and private servers bought by age-verified US players aged 18+ in eligible games.
  - Minimum cash-out of 30,000 Robux.

  — [howcreatorsgetpaid](https://howcreatorsgetpaid.com/platforms/roblox/); [robloxdownloads](https://robloxdownloads.com/news/roblox-creator-devex-payout-boost-monetization/); [devexcalculator](https://devexcalculator.org/roblox-stats/). **[Conflict]** One source gives $0.0035 as the base and $0.0050 for 17+ spend — [sqmagazine](https://sqmagazine.co.uk/roblox-game-creation-and-monetization-statistics/)
- **[3rd-party]** DevEx fees: Q1 2026 $423M, Q2 2026 $363M (+15% YoY); 2025 total about $1.503B — [sqmagazine](https://sqmagazine.co.uk/roblox-game-creation-and-monetization-statistics/); [devexcalculator](https://devexcalculator.org/roblox-stats/)

### Inferences
- Rough estimate of Creator Rewards: 1,000 qualifying Active Spenders per day × 5 R$ = 5,000 R$ per day ≈ $19 per day at $0.0038. Since only spenders count, the share of qualifying DAU is unknown and probably low. This is a supplement, not a core business model.
- Rewarded video is an incremental lever once a game passes 2,000 monthly visitors, but immersive ad fill is reportedly weak.
- Subscriptions (recurring income, 100% after the first month in local currency) fit well with the shift toward D8–28 retention.

### Gaps
- Official Creator Rewards payout volumes per DAU are not published.
- The official 2026 immersive ad payout rate was not found.
- 2026 status of Shopify commerce (new markets or partners) not confirmed.
- Official DevEx text for the $0.0054 rate not read directly (domain blocked).
