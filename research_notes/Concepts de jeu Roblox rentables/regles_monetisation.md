# Roblox platform rules and economics affecting game monetization (state as of Nov 2026)

> Method note: In this session the direct page fetch tool could not reach create.roblox.com or about.roblox.com (blocked at the network level). Every finding below comes from web search result summaries of official pages (Creator Hub docs, DevForum, Roblox newsroom) and from press coverage. I could not read the full official pages, so figures should be checked on the live page before going into a business plan. Items marked **[UNVERIFIED]** come only from third-party or SEO sites.

## 1. DevEx exchange rate and eligibility

### Takeaway
The base DevEx rate is **$0.0038 per earned Robux** for Robux earned on or after 5 Sept 2025 (it was $0.0035 before). Since **8 June 2026** a **42% higher rate (~$0.0054/Robux)** applies to qualifying spend from **age-checked U.S. players 18+** in eligible games. To cash out you need **30,000 earned Robux**, must be **13 or older**, and must be in good standing under the Terms of Use and Community Standards.

### Cited Findings
- At RDC25 (Sept 2025) Roblox announced that the DevEx rate would rise from $0.0035 to $0.0038 per Robux for all creators, about 8.5% more. — [DevForum: RDC25 What we announced](https://devforum.roblox.com/t/rdc25-what-we-announced/3920245); [gam3s.gg](https://gam3s.gg/news/roblox-increases-creator-payouts)
- The new rate applies only to Robux earned on or after 5 Sept 2025. Older Robux still convert at $0.0035. A DevForum thread reported payouts made at the old rate for recently earned Robux, and staff explained that recently granted Robux can still be at the old rate. — [DevForum thread](https://devforum.roblox.com/t/robux-being-exchanged-at-the-old-rate-despite-being-earned-after-september-5th/3981600); [generalistprogrammer guide](https://generalistprogrammer.com/tutorials/roblox-devex-guide-how-to-cash-out-robux)
- The exact increase is 0.0035 × 1.0857 ≈ 0.0038, so the "8.5%" figure is rounded. — [DevForum](https://devforum.roblox.com/t/incorrect-devex-rate-percentage-update-85-claim-is-not-accurate-%F0%9F%A5%80%E2%98%A0%EF%B8%8F/3920224)
- On 30 Apr 2026 Roblox announced a 42% DevEx increase for spend by age-checked U.S. players 18+, effective 8 June 2026. It covers game passes, Robux subscriptions, select in-game items and private servers. "U.S." is determined by economic location, and VPN use does not qualify. — [Roblox Newsroom](https://about.roblox.com/newsroom/2026/04/roblox-fuels-high-fidelity-games-over-18-players-increases-qualifying-devex-rate-42); [Net Influencer](https://www.netinfluencer.com/roblox-to-raise-developer-exchange-rate-for-games-aimed-at-18-plus-players-as-adult-cohort-surges/)
- The official "U.S. 18+ exchange rate" doc gives **0.0054** for qualifying Earned Robux in eligible games (0.0038 × 1.42 ≈ 0.0054, which matches). — [Creator Hub: U.S. 18+ exchange rate](https://create.roblox.com/docs/production/monetization/18-plus-devex-rate)
- Zacks frames the change as the creator's effective share of adult U.S. spend rising from 26.6% to 37.8%. — [Zacks](https://www.zacks.com/stock/news/2951426/)
- There is a conflict on avatar-rig eligibility. The search summary of the official doc mentions an R6-related rule (players must not be able to spawn as or switch to R6), while several third-party sources say eligible games must use R15. Both readings point the same way: R15-only games qualify. I could not read the exact wording. — [Creator Hub 18+ rate](https://create.roblox.com/docs/production/monetization/18-plus-devex-rate); [creation.dev](https://www.creation.dev/learn/roblox-us-18-plus-devex-rate-increase-2026)
- Roblox's stated rationale is that the 18–34 cohort monetizes more than 50% higher than under-18 users in the U.S. In Q1 2026 Roblox also moved from self-reported to "age-checked" age data. — [Roblox Newsroom](https://about.roblox.com/newsroom/2026/04/roblox-fuels-high-fidelity-games-over-18-players-increases-qualifying-devex-rate-42)
- Eligibility requirements: at least 13 years old, at least 30,000 Earned Robux, and compliance with the ToU and Community Standards. Each request is reviewed, and Roblox does not pre-guarantee eligibility. — [Creator Hub: Developer Exchange](https://create.roblox.com/docs/production/monetization/developer-exchange); [Help: DevEx Eligibility FAQ](https://en.help.roblox.com/hc/cs/articles/27954482561300-DevEx-Eligibility-General-Questions)
- Claims that the threshold is 100,000 Robux or requires Premium come only from third-party sites and contradict the official 30,000 figure. — [rolearn.dev](https://rolearn.dev/guidance/roblox-devex-requirements-2026) **[UNVERIFIED / likely wrong]**
- Scale: DevEx payouts were $423M in Q1 2026, up 50% year on year. — [Roblox Q1 2026 Shareholder Letter](https://s27.q4cdn.com/984876518/files/doc_financials/2026/q1/Q1-2026-Earnings-Shareholder-Letter.pdf)

### Inferences
- A game aimed at adults (age-checked 18+, U.S., R15) earns about 42% more cash per Robux of qualifying spend than an all-ages game. This is a significant design lever, but it pulls against the large under-16 audience.
- At the base rate, $1 of DevEx needs about 263 earned Robux.

### Gaps
- I could not confirm whether DevEx now requires ID verification beyond the existing tax/KYC onboarding. Since ID verification is now required to publish to all ages (section 4), it is probably already in place for most commercial creators.
- I could not read the full list of "eligible game" criteria for the 18+ rate (for example whether a maturity label is required), nor whether the 18+ uplift has been extended outside the U.S.
- Pending/escrow holding period for earned Robux: one search summary mentions a 30-day escrow note on the official monetization page. I could not confirm which revenue types it covers. **[UNVERIFIED]**

## 2. Revenue split: game passes, developer products, subscriptions, UGC, paid access, Creator Rewards

### Takeaway
Creators keep **70% of Robux** on game passes and developer products (30% marketplace fee). After DevEx conversion Roblox itself calls the creator's effective cash share about **25%** of what players spend, or about 37.8% for qualifying adult U.S. spend after June 2026. UGC avatar items sold in your own game return 70% (30% creator plus 40% seller). Experience subscriptions exist, but I could not confirm their exact split.

### Cited Findings
- Game passes and developer products: the creator receives 70% and the remaining 30% is Roblox's Marketplace Fee. — [Creator Hub: Earn on Roblox](https://create.roblox.com/docs/production/earn-on-roblox)
- UGC on the Avatar Marketplace: Roblox keeps a 40% seller portion plus a 30% market fee and the creator gets 30%. If the item sells inside a game, that game's owner gets the 40% seller portion. If you sell your own item in your own game you get 70% in total. — [Creator Hub: Earn on Roblox](https://create.roblox.com/docs/production/earn-on-roblox)
- Roblox's own monetization page lists about a 25% developer share after Developer Exchange. — [Creator Hub: Get started with monetization](https://create.roblox.com/docs/get-started/monetization)
- Experience subscriptions have been available since Nov 2023, with fixed monthly price tiers. — [DevForum: Create and manage subscriptions](https://devforum.roblox.com/t/create-and-manage-subscriptions-within-your-experience/2600664)
- Sources conflict on the subscription split. One says it is 70% to the creator like other in-experience sales. A third-party site claims 70% in the first month and no fee on renewals. — [rowatcher.com](https://rowatcher.com/news/roblox-monetization-strategies-that-actually-work-in-2026) **[UNVERIFIED]**
- Paid-access experiences priced at $9.99 or more get a higher revenue share (DevForum announcement, late 2024). — [DevForum: Higher Revenue Share for $9.99+ Paid Access](https://devforum.roblox.com/t/earn-a-higher-revenue-share-for-999-paid-access-experiences/3294010)
- Creator Rewards replaced Engagement-Based Payouts in July 2025. Among its components, an experience earns 5 Robux/day when it is one of the first three an "Active Spender" plays for 10+ minutes in a day. Roblox says amounts may change. — [Creator Hub: Creator Rewards](https://create.roblox.com/docs/creator-rewards); [DevForum: Introducing Creator Rewards](https://devforum.roblox.com/t/introducing-creator-rewards-earn-more-by-growing-the-community/3777628)
- Roblox Plus is a newer subscription with its own Creator Hub page. It is referenced as a requirement for some creator privileges (see sections 4 and 5). — [Creator Hub: Roblox Plus](https://create.roblox.com/docs/en-us/production/monetization/roblox-plus.md)
- Press reports that Roblox will take a cut of in-game brand-deal and integration revenue starting in 2027 under new advertising rules. — [PocketGamer.biz](https://www.pocketgamer.biz/roblox-to-take-cut-of-in-game-brand-deals-from-2027-under-new-advertising-rules); [Net Influencer](https://www.netinfluencer.com/roblox-to-take-cut-of-creator-brand-deal-revenue-starting-2027/)
- A third-party site reports that 2D avatar creators' revenue share was cut from 70% to 30% in 2026, and a second article from the same site gives different numbers. — [tech-insider.org](https://tech-insider.org/roblox-2d-creator-revenue-share-cut-2026/) **[UNVERIFIED, internally inconsistent]**

### Inferences
- Rough cash math at the base rate: a 100-Robux pass gives the creator 70 Robux, which is $0.266 at $0.0038. Under the 18+ U.S. rate it is $0.378.
- The brand-deal cut from 2027 matters if the business model relies on sponsorships.

### Gaps
- I could not confirm the official revenue share for experience subscriptions, the exact uplift for paid access at $9.99+, or the percentage of the 2027 brand-deal cut.

## 3. Paid random items / loot boxes

### Takeaway
Paid random items are allowed but tightly regulated. Before purchase you must disclose every possible outcome with **numerical odds**, explain boost and pity mechanics, and honour **regional restrictions** via `PolicyService` (Netherlands and Belgium historically). Restricted users cannot buy them or trade their results. The English policy page was last updated on **19 Aug 2026**, and that version expanded the covered mechanics.

### Cited Findings
- The policy covers random items bought directly with Robux or indirectly through Robux-bought in-game currency, for example prize wheels and gem or spin-ticket purchases. — [Creator Hub: Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items)
- Covered types include capsules, enhancements, combinations and probability modifiers (luck boosts). The newer version also names pity systems and rate-up scrolls. — [Creator Hub: Paid random items (en-us)](https://create.roblox.com/docs/en-us/production/monetization/paid-random-items)
- Odds disclosure: all possible outcomes with numerical odds must be shown, and items with identical odds can be grouped under one percentage. Paid boosts must be explained before purchase, and the displayed odds must update while a boost is active. — [Creator Hub: Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items)
- Regional restrictions: `PolicyService:GetPolicyInfoForPlayerAsync()` returns `ArePaidRandomItemsRestricted` and `IsPaidItemTradingAllowed`. If a player is restricted you must remove the feature, block the purchase or route the player away. Restricted users may not trade paid random results. — [Creator Hub (zh-tw)](https://create.roblox.com/docs/zh-tw/production/monetization/paid-random-items)
- Allowed alternatives for restricted users are an unpaid, earnable path to the same item, or showing outcomes in a fixed order before purchase. — [Creator Hub: Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items)
- Historical enforcement: in Sept 2022 Adopt Me was disabled in the Netherlands and Belgium as part of a Roblox compliance push. — [Game Developer](https://www.gamedeveloper.com/game-platforms/-i-roblox-i-game-i-adopt-me-i-ends-netherlands-service-due-to-loot-boxes)
- Background: the Netherlands treated certain loot boxes as unlawful from 2018, Belgium classifies them as gambling, and a 2025 Antwerp court decision reinforced their illegality. — [siege.gg](https://siege.gg/news/several-eu-countries-have-introduced-stricter-regulations-on-loot-boxes-in-games-in-2025); [GamesRadar](https://gamesradar.com/belgium-deems-loot-boxes-dangerous-to-children-and-society-threatens-publishers-with-prison-and-fines)
- The Experience Questionnaire (a compliance tool) drives regional availability. Developers report that answering "does not respect ArePaidRandomItemsRestricted" leads to the game being restricted in the Netherlands. — [DevForum: Experience Questionnaire](https://devforum.roblox.com/t/new-compliance-tool-experience-questionnaire/1659703?page=4)
- The April 2026 Terms of Use require creators to comply with laws applicable to their experiences, explicitly including laws on loot boxes, dark patterns and other potentially addictive features. — [DevForum: ToU update April 2026](https://devforum.roblox.com/t/updates-to-the-roblox-terms-of-use-april-2026/4548394?page=2)

### Inferences
- Build odds UIs, boost-aware odds and a PolicyService gate in from day one. Otherwise the game risks being geo-restricted through the questionnaire and becoming a liability under the ToU.

### Gaps
- I found no reliable source on the full current list of restricted countries as of Nov 2026, or on 2026 enforcement actions against specific games.

## 4. Age verification, age tiers, under-13 / under-16 rules, parental controls, spending limits, legal pressure

### Takeaway
2026 restructured the platform. Facial age checks (via Persona) or ID became mandatory for chat in Jan 2026. Since June 2026 accounts are split into **Roblox Kids (5–8)**, **Roblox Select (9–15)** and **standard (16+)**, and kids' tiers only see games with suitable maturity labels that have **passed a review**. To publish to all ages, creators must be **ID-verified with 2FA** and pay a **refundable fee or hold a subscription**. Parents can cap monthly spending for children under 13. These changes are driven by state AG suits, a federal MDL and a securities suit.

### Cited Findings
- As of Jan 2026, chat worldwide requires a facial age estimation (Persona) or ID. Users who skip it get a no-chat experience. — [Dataconomy](https://dataconomy.com/2026/01/08/roblox-mandates-facial-verification-for-global-chat-access/); [Malwarebytes](https://www.malwarebytes.com/blog/news/2026/04/roblox-clamps-down-on-chats-and-age-checks-as-legal-pressure-builds)
- Three account tiers launched worldwide in June 2026: Kids (5–8), Select (9–15) and standard (16+), with automatic progression at 9 and 16. Kids see only Minimal/Mild maturity-labelled games, and Select sees up to Moderate. — [ABC7](https://abc7news.com/post/roblox-launches-3-age-based-account-tiers-worldwide-kids-select-standard/19318759/); [TechCrunch](https://techcrunch.com/2026/04/13/roblox-introduces-kids-and-select-accounts-for-age-appropriate-access-to-games-and-chat/); [Roblox Newsroom](https://about.roblox.com/en-au/newsroom/2026/04/introducing-roblox-kids-and-select-accounts)
- Publishing to all ages (including Kids/Select) requires account good standing, ID verification (government ID or linked parental account) and 2FA, plus one of: a publishing fee or a subscription. — [Creator Hub: Roblox Kids and Select](https://create.roblox.com/docs/production/publishing/kids-and-select)
- Games reach Kids/Select through a three-part review: creator eligibility, automated safety screening and an evaluation period. The rollout started 19 May 2026 in New Zealand, the Netherlands, Australia and Indonesia. Games that have not passed remain available to 16+ users if the creator is age-checked. An optional **expedited review costs a refundable 100,000 Robux per game**. — [DevForum: Kids and Select Global Launch](https://devforum.roblox.com/t/roblox-kids-and-select-global-launch-upcoming-updates-to-eligibility-ads-manager-and-expedited-review/4685717); [DevForum: New Publishing Requirements](https://devforum.roblox.com/t/new-publishing-requirements-evaluation-process-for-games/4573166)
- Earlier April 2026 press coverage said an active Roblox Plus subscription was required. Current docs offer a fee or subscription as alternatives. — [Khaleej Times](https://www.khaleejtimes.com/entertainment/gaming/roblox-launches-age-based-accounts-expanded-parental-controls) (older; superseded by docs)
- Developers complain about a "100k Robux / 500 engaged users" barrier to Kids/Select visibility for beginners. — [DevForum thread](https://devforum.roblox.com/t/the-100k-robux-500-engaged-users-paywall-for-kids-select-categories-visibility-is-deeply-unfair-to-beginner-developers/4737268) (user complaint, not official)
- Parental controls: parents can set a monthly cap on Robux and subscription spending, block individual games, and manage chat up to age 15. From age 13 spending limits no longer apply, but parents can still receive spending notifications. Robux transfer defaults are 500/day and 1,000/month. — [Help: What happens as my child gets older](https://en.help.roblox.com/hc/en-us/articles/30428367965460-What-happens-as-my-child-or-teen-gets-older-on-Roblox); [Help: Parental Controls Overview](https://en.help.roblox.com/hc/en-us/articles/30428310121620-Parental-Controls-Overview)
- Gift cards and console purchases (e.g. Xbox) may fall outside Roblox-set limits. — [walkthroughs.net](https://walkthroughs.net/roblox-parental-controls-2026-screen-time-spending-limits-explained) **[third-party]**
- Legal pressure:
  - An Alabama settlement requires age checks (facial estimation or ID) for all new and existing accounts from 1 May 2026. — [Malwarebytes](https://www.malwarebytes.com/blog/news/2026/04/roblox-clamps-down-on-chats-and-age-checks-as-legal-pressure-builds)
  - Nebraska and Oklahoma have filed state AG suits. — [Reclaim the Net](https://reclaimthenet.org/oklahoma-roblox-lawsuit-child-safety-biometric-age-verification)
  - A federal MDL was created in 2026 before Judge Seeborg (N.D. Cal.) over grooming and exploitation claims. — [Malwarebytes](https://www.malwarebytes.com/blog/news/2026/04/roblox-clamps-down-on-chats-and-age-checks-as-legal-pressure-builds); [The Next Web](https://thenextweb.com/news/roblox-age-gated-account-tiers-kids-select-child-safety)
  - A securities class action alleges investors were misled about the age-assurance rollout (class period 30 Oct 2025 to 30 Apr 2026). — [Biometric Update](https://www.biometricupdate.com/202607/lawsuit-alleges-roblox-misled-investors-about-age-assurance-6-7b-loss)
- Age checks slowed DAU growth, per press reports. — [pulse.bot](https://www.pulse.bot/entertainment/news/robloxs-daily-users-continue-to-drop-as-age-checks-slow-growth-884035a5-0005-4699-8bac-27204fd2c8f0/) (aggregator)

### Inferences
- A new commercial game has two paths. **Path A**: target 16+/18+, with lighter review and the higher U.S. DevEx rate. **Path B**: target all ages, which means ID + 2FA + a fee or subscription, a passed safety evaluation, and a Minimal/Mild or Moderate maturity label.
- Parent spending caps for under-13s mean the monthly spend ceiling per child is set by parents, which favours cheap, recurring purchases over large ones in kids' games.

### Gaps
- I found no explicit 2026 rule banning particular monetization mechanics targeted at Kids/Select accounts, for example whether paid random items are blocked for Kids accounts. Check the Kids & Select doc directly.
- The exact publishing fee amount (other than the 100k expedited review) and the subscription option are unconfirmed.
- I did not verify the current status (Nov 2026) of the MDL and the state suits.

## 5. Misleading monetization, pay-to-win, marketplace/community standards 2025–2026, IP and memes

### Takeaway
I found no single "dark patterns" policy document. The binding hooks are the **April 2026 ToU**, which requires creators to obey laws on loot boxes, dark patterns and addictive features, the paid-random-items policy, and the Community Standards. I found no explicit ban on pay-to-win. IP is enforced through **DMCA takedowns and strikes, with permanent termination for repeat infringers**. Unlicensed copyrighted characters are a real takedown risk, and Roblox offers an IP-licensing program as the legal route.

### Cited Findings
- April 2026 ToU (effective about 30 Apr 2026): creators must comply with applicable laws "including but not limited to laws governing loot boxes, dark patterns, or other potentially addictive features". Developers on the forum found the scope unclear. — [DevForum: ToU update April 2026](https://devforum.roblox.com/t/updates-to-the-roblox-terms-of-use-april-2026/4548394?page=2)
- A complaint naming loot boxes, FOMO and fake scarcity as dark patterns on Roblox was reportedly filed with a federal regulator, and Roblox disputes it. — [Instreamly](https://instreamly.com/posts/loot-boxes-fomo-and-fake-scarcity-8-dark-patterns-brands-must-audit-before-launching-in-roblox/) **[UNVERIFIED; regulator not named]**
- Marketplace changes on 7–14 July 2026: publishing avatar items reportedly requires ID verification or a linked parent account, 2FA, and active Plus or Premium. — [tech-insider.org](https://tech-insider.org/roblox-2d-creator-revenue-share-cut-2026/) **[third-party; verify]**
- DMCA: only rights holders or their agents can file. Strikes are issued only for DMCA notices, not for automated filtering. Repeat-infringer terminations are permanent. Counter-notices go to copyright_agent@roblox.com. — [Creator Hub: DMCA guidelines](https://create.roblox.com/docs/production/publishing/dmca-guidelines)
- The IP guidelines page was updated Oct 2026 and covers trademark reporting and an EU Digital Services Act route. — [Creator Hub: IP guidelines](https://create.roblox.com/docs/production/publishing/ip-guidelines.md)
- Roblox runs an IP licensing program (licensed brands for creators). — [Creator Hub: IP licensing FAQ](https://create.roblox.com/docs/ip-licensing/faq)
- Avatar-item IP rules forbid unlicensed third-party IP. — [Creator Hub: Intellectual property (marketplace)](https://create.roblox.com/docs/en-us/marketplace/intellectual-property)

### Inferences
- Meme-based games (original meme formats) carry lower risk than games built on copyrighted characters such as anime or cartoon IP. The latter can be taken down at any time, with strikes that endanger the account and therefore DevEx income. Use the IP licensing program or original characters.
- Given the ToU language and the regulatory focus, treat FOMO timers, fake scarcity and opaque odds as legal risk, not just reputational risk.

### Gaps
- I found no official Roblox rule explicitly on pay-to-win, and no official text on memes or parody.
- Rights Manager was not documented in my results.

## 6. Price optimization, regional pricing and subscription tools

### Takeaway
Roblox now bundles **price optimization and regional pricing into "Managed pricing"**, a single opt-in in Creator Hub. Regional pricing covers passes (Apr 2025), developer products (late 2025) and avatar items. Official docs say regional pricing is on by default for passes via Managed pricing. Subscriptions use fixed monthly tiers.

### Cited Findings
- Managed pricing is a unified Creator Hub system that combines price optimization and regional pricing under a single opt-in. It suggests prices from signals such as demand, conversion, spend and spender penetration by country. — [Creator Hub: Managed pricing](https://create.roblox.com/docs/production/monetization/managed-pricing); [DevForum: Managed Pricing announcement](https://devforum.roblox.com/t/managed-pricing-one-system-for-better-pricing-and-earnings-growth/4684738)
- Regional pricing for passes opened to all creators as an opt-in on 24 Apr 2025. — [DevForum: Regional Pricing for Passes](https://devforum.roblox.com/t/introducing-regional-pricing-for-passes/3621382)
- Regional pricing for developer products: the creator sets a default price and Roblox adjusts it by region. — [DevForum: Regional Pricing for Developer Products](https://devforum.roblox.com/t/introducing-regional-pricing-for-developer-products/3971235)
- Regional pricing for avatar items has also been announced. — [DevForum: Regional Pricing for Avatar Items](https://devforum.roblox.com/t/regional-pricing-for-avatar-items/3676358)
- Official docs say regional pricing is enabled by default for all new and existing passes through Managed pricing. Third-party sites give a default-on date of 30 Mar 2026, which I could not verify. — [Creator Hub: Regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing); [creation.dev](https://www.creation.dev/learn/roblox-regional-pricing-game-passes-guide)
- Games with trading or gifting must use `GetUsersPriceLevelsAsync` to prevent cross-region arbitrage. — [Creator Hub: Regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing)
- Experience subscriptions use fixed monthly price tiers (since Nov 2023). — [DevForum](https://devforum.roblox.com/t/create-and-manage-subscriptions-within-your-experience/2600664)
- The Ads Manager is getting changes tied to the Kids/Select launch. — [DevForum: Kids and Select Global Launch](https://devforum.roblox.com/t/roblox-kids-and-select-global-launch-upcoming-updates-to-eligibility-ads-manager-and-expedited-review/4685717)

### Inferences
- If the game has trading or gifting, design the economy assuming regional prices, so that cheap-region purchases cannot be resold or gifted at a markup.
- Managed pricing reduces the need for manual A/B price testing, but creators still choose the default price anchors.

### Gaps
- I could not confirm whether developer products are default-on in Managed pricing, or the exact Ads Manager changes.
- I found no official subscription price tier list for 2026.
