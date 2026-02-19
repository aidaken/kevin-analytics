# Question No. 1: Who are Our Best Customers?
Database: Chinook (music store)
Tools: SQLite, Python, pandas, matplotlib

---

## Why I looked at this
Before any decision in marketing or retention, you need to know who is actually driving revenue, and whether the business is dangerously dependent on a handful of people. That's what I wanted to find out.

I have three questions:
1) Who spends the most? (I need to make 4 groups so it is easier for business to target)
2) Is revenue spread out or sitting on top of few customers?
3) Which customers used to spend but have gone quiet, and are they worth chasing?

## What I found
1) No single group is holding the business hostage, that's a healthy sign.

2) The revenue is actually pretty evenly distributed across four groups:
|Tier  | Customers | Revenue| Share |
|------|-----------|--------|-------|
| VIP        | 15  | $654   | 28.1% |
| Core       | 15  | $584   | 25.1% |
| Occasional | 15  | $563   | 24.2% |
| Low        | 14  | $527   | 22.6% |

The real story is in the middle. 34 customers generating around 57% of revenue

3)The problem has 1 aspect to solve, which is at-risk segment. 13 customers who collectively spent $496 but haven't purchased in about 459 days on average. They bought 6-7 times each, and then just stopped.

---

## How I got here

Step 1: Ranked all 59 customers in database by total spend using a simple invoice join.

Step 2: Ran data checks before trusting anything. Confirmed the join didnt duplicate rows, totals reconcile ($2,328.60 matches across both aggregations), no nulls or negative values. More details in 'data_checks.md' :)

Step 3: Split customers into 4 tiers/groups using NTILE(4) on total spend

Step 4: Layered in recency (days since last order) to find who is gone quiet despite having a solid purchase behavior

Step 5: Checked who has actually come back after long gaps before. If someone returned after 180+ days of silence at least 1 time, they are more likely to do it again. Hannah S., Jennifer P., and Dominique L. each did it three times.

Step 6: Built a prioritized outreach list with three tiers:
- P0: Luis Rojas, high spender, 434 days silent, needs to be handled manually
- P1: At-risk customers with proven comeback history (most likely to respond and come back)
- P2: At-risk customers with no prior returns

---

## What I would do next

Run a two-wave reactivation campaign targeting the at-risk segment.
Start with P1, they have already shown that they will come back. A/B test a discount offer vs. a "we miss you, please come back". Measure retur rate and revenue within 30 days. If P1 converts well, expand to P2 with a similar approach.
For P0, we need to make one personal email which worth more than a batch campaign.
Success metric: % of targeted customers who make a purchase within 30 days, and total revenue recovered from reactivated customers.
Full target list: 'outputs/target_list.csv'

---

## Files

| File                | What it does |
|---------------------|-------------|
| `top_customers.sql` | Ranks customers by total spend |
| `checks.sql`        | 5 data quality checks |
| `value_tiers.sql`   | Splits into VIP / Core / Occasional / Low |
| `revenue_share.sql` | Revenue % by tier |
| `rfm_lite.sql`      | Adds recency + risk segments |
| `reactivation_history.sql` | Finds customers who've returned after long gaps 
| `final_targets.sql` | Prioritized outreach list |
| `outputs/target_list.csv` | Ready to use |
| `metrics_notes.md`  | Exact metric definitions |
| `schema_notes.md`   | Tables and columns used |
| `data_checks.md`    | Verification results |

---

### Thank you for your time reading all of it!!
Aidar Kenzhebaev

