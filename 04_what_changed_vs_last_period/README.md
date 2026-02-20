# Question No. 4: What changed vs last period?

**Database:** Northwind (orders + products)
**Tools:** SQLite, Python, pandas, matplotlib

---

## Why I looked at this

Case 3 told me where the money comes from. This case asks the annoying
follow-up finance question: what changed recently, and what drove it?

I compared the most recent 90 days vs the 90 days before that, then
decomposed each category's change into price vs volume effects.

---

## What I found

Overall net sales fell 1.6% in the current period.

Prior (2023-05-02 to 2023-07-30): $9,999,621
Current (2023-07-31 to 2023-10-28): $9,841,190
Change: -$158,432 (-1.58%)

Almost every category dropped. Beverages was the only one that grew.

The driver split is the interesting part. Beverages grew mostly on
price (+$63.6K price effect) even though volume was slightly down
(-$5.4K). So customers bought a bit less but paid more per unit.

Dairy Products fell the opposite way. Volume drove most of the decline
(-$74.1K qty effect), with price actually helping a bit (+$20.9K).
Units sold dropped, not the price point.

This looks more like a volume problem in a few categories, not a
discount problem. Discount effect was near zero across the board.

---

## How I got here

Built a clean line item table with net sales at the order line level:
net_sales = UnitPrice x Quantity x (1 - Discount)

Defined two 90-day windows dynamically from the max order date in
the dataset so the query stays reusable on any snapshot.

For each category I split the net change into three effects:
- Volume effect: (current_units - prior_units) x prior_avg_price
- Price effect: (current_avg_price - prior_avg_price) x current_units
- Discount effect: negative of the change in total discount dollars

Note: the chart uses $K formatting because the changes are in the
thousands range, not millions.

---

## What I would do next

The three biggest declines, Produce (-$60K), Dairy Products (-$53K),
and Confections (-$40K), account for most of the overall drop.

Two follow-ups I would run next:
1) Break the category declines by country and by product to find
   where the volume drop is actually concentrated.
2) Check whether the drop is fewer orders or smaller baskets
   by comparing order count vs units vs average order value.

Therefore, we should investigate Produce and Dairy at the customer
level, because the category number masks whether this is one or two
large customers pulling back or broad softness, and that changes
the response entirely.

---

## Files

| File | What it does |
|------|-------------|
| `sales_lines.sql` | Base line items with net sales calculation |
| `periods.sql` | Defines prior vs current 90-day windows |
| `variance_overall.sql` | Overall net sales change between periods |
| `variance_by_category.sql` | Category change + price/volume decomposition |
| `run_variance.py` | Exports CSVs and saves chart |
| `outputs/variance_overall.csv` | Overall period summary |
| `outputs/variance_by_category.csv` | Category detail with driver effects |
| `outputs/category_movers.png` | Net change by category (green/red) |