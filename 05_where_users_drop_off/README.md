# Question No. 5: Where do users drop off?

**Dataset:** Synthetic signup funnel (see data note below)
**Tools:** Python, pandas, matplotlib

---

## Data reality check

Northwind and Chinook don't store the full acquisition funnel. Both
databases mostly include customers who already purchased, so lifecycle
drop-off comes out flat (93/93/93 or 59/59/59). That's not a bug
in the query, it's just missing the pre-purchase population.

To still demonstrate funnel analysis, I built a synthetic signup
funnel and ran the same analysis you'd run on real event logs.

---

## The funnel

| Step | Users | Step rate | Overall rate |
|------|------:|----------:|-------------:|
| Visited landing page | 10,000 | 100% | 100% |
| Started signup | 6,200 | 62% | 62% |
| Verified email | 4,100 | 66% | 41% |
| Added payment method | 2,300 | 56% | 23% |
| Completed first order | 1,400 | 61% | 14% |

---

## What I found

Overall conversion is 14%. Only 1,400 out of 10,000 visitors make
it to first order.

Biggest absolute loss is landing page to signup start: 3,800 users
(38%) bounce before even trying. That's usually a positioning, trust,
or unclear value problem, not a product friction problem.

Highest relative drop is verified email to payment method: 1,800
users (44%) drop right before the money moment. Common reasons are
the form feels long, they don't have a card ready, or last-second
trust anxiety about security or hidden fees.

Email verification drops 2,100 users (34%). Usually one of the
cheapest fixes since it's mostly copy and deliverability.

---

## What I would do next

Two experiments worth running first:

1) Email verification: A/B test a shorter email with one clear CTA
or a magic link. Goal is to lift verify rate by 5 to 10 percentage
points.

2) Payment method: fewer fields, better defaults, Apple Pay / Google
Pay if possible, plus trust cues explaining why payment info is
needed upfront. Goal is to lift payment-add rate by 10 to 20
percentage points.

Impact math (example scenario): if verify goes 66% to 74% (+8pp)
and payment goes 56% to 71% (+15pp):

Current: 10,000 x 0.62 x 0.66 x 0.56 x 0.61 = ~1,400 first orders
New:     10,000 x 0.62 x 0.74 x 0.71 x 0.61 = ~2,000 first orders

That's roughly +600 extra first orders per 10,000 visitors.
At $30 average order value, that's ~$18K in added first-order
revenue per 10,000 visitors before any retention effect.

Therefore, we should prioritize payment friction first because it's
the most revenue-proximate leak (44% drop at the money step), and
run a landing page trust test in parallel since it's the largest
volume leak.

Weekly metric to watch: first order conversion rate and time to
first order.

---

## Segmentation template (for real event data)

If we had event logs with country or channel at each step, here is
how I would compute step conversion by segment:
```sql
-- requires event logs: user_id, country, step
WITH step_dim AS (
  SELECT 'Visited landing page'  AS step, 1 AS step_order UNION ALL
  SELECT 'Started signup',                2               UNION ALL
  SELECT 'Verified email',                3               UNION ALL
  SELECT 'Added payment method',          4               UNION ALL
  SELECT 'Completed first order',         5
),
step_counts AS (
  SELECT e.country, e.step, d.step_order, COUNT(DISTINCT e.user_id) AS users
  FROM funnel_events e
  JOIN step_dim d ON d.step = e.step
  GROUP BY 1, 2, 3
),
paired AS (
  SELECT
    country, step, users,
    LAG(users) OVER (PARTITION BY country ORDER BY step_order) AS prev_users
  FROM step_counts
)
SELECT
  country, step, users,
  ROUND(1.0 * users / NULLIF(prev_users, 0), 4) AS step_rate
FROM paired
ORDER BY step_rate ASC;
```

This surfaces which segments have unusually high drop-off at specific
steps, which is where you'd focus fixes first.

---

## Files

| File | What it does |
|------|-------------|
| `generate_funnel.py` | Builds synthetic funnel + exports chart |
| `outputs/funnel_steps.csv` | Step-level conversion table |
| `outputs/funnel_chart.png` | Horizontal bar chart |

---
Aidar