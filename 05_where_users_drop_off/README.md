# Question No. 5: Where do users drop off?

**Dataset:** Synthetic signup funnel (see data note below)
**Tools:** Python, pandas, matplotlib

---

## Data reality check

Northwind and Chinook don't store the full acquisition funnel. Both
databases only include customers who already purchased, so any
lifecycle drop-off analysis comes out flat (93/93/93 or 59/59/59).
That's not a bug in the query, it's the dataset telling you it
doesn't contain pre-purchase population data.

To actually demonstrate funnel analysis, I built a synthetic signup
funnel based on typical B2C fintech conversion benchmarks and ran
the analysis on that. The technique is identical to what you'd run
on real event logs.

---

## The funnel

| Step | Users | Step rate | Overall rate |
|------|-------|-----------|--------------|
| Visited landing page | 10,000 | | 100% |
| Started signup | 6,200 | 62% | 62% |
| Verified email | 4,100 | 66% | 41% |
| Added payment method | 2,300 | 56% | 23% |
| Completed first order | 1,400 | 61% | 14% |

---

## What I found

Only 14 out of 100 visitors make it to their first order.

The single worst handoff is landing page to signup start. 38% of
visitors bounce before even trying. That's usually a messaging or
trust problem, not product friction. You fix it with better copy
and social proof, not engineering work.

The payment method step loses 44% of people who got that far. This
is the most common abandonment point in fintech onboarding. Three
likely causes: unexpected form complexity, user doesn't have their
card nearby, or they lose confidence right before committing money.

Email verification drops 34%. That's high and usually the easiest
to fix operationally.

---

## What I would do next

Two experiments worth running first:

1) For email verification: A/B test a shorter confirmation email
with one clear CTA. Expected lift is 5 to 10 percentage points.

2) For payment method: test breaking it into two lighter screens
and adding trust signals like an encryption badge and a one-line
explainer on why payment info is needed upfront.

Fixing both steps could recover 800 to 1,200 additional users
through to first order. At a $30 average order value that's
$24K to $36K in recovered first-order revenue per 10,000 visitors.

Therefore, we should prioritize reducing payment friction first
because it has the biggest absolute user loss (1,800 people) and
is directly tied to revenue, not just activation rate.

---

## Segmentation template (for real event data)

If we had event logs with country or channel at each step, here is
how I would compute step conversion by segment to find where friction
is localized:
```sql
-- requires event-level funnel logs with user_id, country, step
WITH step_counts AS (
  SELECT country, step, COUNT(DISTINCT user_id) AS users
  FROM funnel_events
  GROUP BY 1, 2
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

This would surface which countries or channels have unusually high
drop-off at specific steps, which is where you'd focus first.

---

## Files

| File | What it does |
|------|-------------|
| `generate_funnel.py` | Builds synthetic funnel + exports chart |
| `outputs/funnel_steps.csv` | Step-level conversion table |
| `outputs/funnel_chart.png` | Horizontal bar chart |

---
Aidar