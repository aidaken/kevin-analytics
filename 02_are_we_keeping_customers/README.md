# Question No. 2: Are we keeping customers?
Database: Chinook (music store)  
Tools: SQLite, Python, pandas, matplotlib

---

## Why I looked at this
Revenue is cool, but retention is the real health check.  
If people buy once and disappear, you’re just refilling a leaking bucket.

So I wanted to answer one thing:  
**Do customers come back… and if yes, when?**

---

## What I found
1) **Month 1 retention is ~30.5%** (18 out of 59 customers came back the next month).  
So most customers don’t repeat right away.

2) **Retention is spiky, not “monthly smooth”.**  
In this month-index setup (exact-month repeat), months 2 / 4 / 5 are 0% — that doesn’t mean “everyone churned”.
It means purchases aren’t happening on a clean monthly cycle. People come back in waves.

3) **The biggest checkpoints here are month 1 and month 3**:
- Month 1: **0.305**
- Month 3: **0.373**
- Month 6: **0.305**

If we want to move the needle, we should focus on getting people to purchase again early (first 1–3 months).

---

## How I got here
Step 1: Converted invoice dates into **order months** (`YYYY-MM-01`).  
Step 2: Defined `cohort_month` = the customer’s first purchase month.  
Step 3: Created `month_index` = how many months after cohort_month the purchase happened.  
Step 4: For each cohort + month_index, counted **active customers** and divided by cohort size:  
`retention_rate = active_customers / cohort_size`  
Step 5: Exported a long table + matrix + heatmap so it’s readable fast.

**Notes (so the chart doesn’t lie):**
- I built a full `cohort_month × month_index` grid (0–24) and filled missing months with 0 (so we don’t hide gaps).
- Cohorts with <3 customers are noisy (one person can make retention look like 100%), so I focus on cohorts with 3+ customers when interpreting.
- Heatmap is capped to the first 24 months and only labeled every 3 months (full 59 months is unreadable in a static PNG).

---

## What I would do next
If month-1 retention is low, the fix isn’t “more acquisition”.  
It’s improving the first repeat purchase loop right after purchase #1.

**Therefore, we should push a simple reactivation nudge in the first 1–3 months** (email/offer/recommendations),
because that’s where most drop-off happens, and we expect higher repeat purchases and more stable revenue.

Success metric:
- Month-1 retention lift
- Repeat purchase rate within 30 / 90 days
- Revenue from repeat customers

---

## Files
| File | What it does |
|------|--------------|
| `cohort_retention.sql` | Builds cohort retention table (full grid, months 0–24) |
| `checks.sql` | Sanity checks (bounds, month0 behavior, etc.) |
| `retention_summary.sql` | Weighted retention curve + worst cohorts |
| `run_cohort_retention.py` | Exports CSVs + saves heatmap PNG |
| `outputs/retention_long.csv` | cohort_month × month_index (long table) |
| `outputs/retention_matrix.csv` | retention matrix (wide table) |
| `outputs/retention_heatmap.png` | heatmap image |
| `repeat_within_90_days.sql` | Single headline: % of customers who repurchase within 90 days |
