# Exec Summary, Case 5: Where do users drop off?

Goal: Find the biggest drop-offs in onboarding and prioritize fixes that move first-order conversion.

Data: Synthetic signup funnel. Northwind/Chinook don’t include pre-purchase users, so acquisition funnels come out flat. Synthetic data lets us demonstrate the same funnel method used on real event logs.

Key funnel metrics (per 10,000 visitors):
- First order conversion: 14% (1,400 users)
- Biggest volume leak: Landing -> Signup start (3,800 users lost, 38%)
- Biggest revenue-proximate leak: Verified email -> Payment method (1,800 users lost, 44%)

Main insight:
- Landing -> Signup is a trust/messaging problem (positioning, social proof, clarity).
- Payment method is the “money moment” and the highest-friction commitment step.

Recommendation:
- Prioritize reducing payment friction first (largest revenue-proximate leak).
- Run landing page trust/messaging tests in parallel (largest volume leak).

Experiments:
1) Email verification
   - Shorter email, single CTA or magic link
   - Target: +5 to +10pp verify rate

2) Payment method
   - Fewer fields, better defaults, add Apple Pay / Google Pay if possible
   - Add trust cues (why needed, security line, no hidden fees)
   - Target: +10 to +20pp payment-add rate

Impact example:
- If verify improves 66% -> 74% and payment improves 56% → 71%,
  first orders rise from ~1,400 → ~2,000 (+600 per 10,000 visitors).
- At $30 AOV, that’s ~$18K added first-order revenue per 10,000 visitors (before retention).

Weekly metrics to track:
- First order conversion rate
- Time to first order
