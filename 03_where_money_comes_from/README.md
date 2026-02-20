# Question No. 3: Where does the money come from?
Database: Northwind (orders + products)  
Tools: SQLite, Python, pandas, matplotlib

## Why I looked at this
Before trying to grow revenue, I wanted to see what is already carrying the business.
Which categories matter most, which countries matter most, and whether we are over dependent on a few big movers.

## How I measured it
I used net sales at the line item level:

net_sales = UnitPrice * Quantity * (1 - Discount)

Northwind does not include real product cost here, so I am not calling this profit.
This is sales after discount.

## What I found

### 1) Category mix matters a lot
Top categories by net sales:
- Beverages: $92.16M (20.6%)
- Confections: $66.34M (14.8%)
- Meat/Poultry: $64.88M (14.5%)
- Dairy Products: $58.02M (12.9%)
- Condiments: $55.80M (12.4%)

Top 3 categories are about 49.8% of net sales.
Top 5 categories are about 75.2% of net sales.

### 2) Countries are top heavy, but less than categories
Top countries by net sales:
- USA: $63.86M (14.2%)
- Germany: $59.09M (13.2%)
- France: $49.12M (11.0%)
- Brazil: $46.25M (10.3%)
- UK: $36.26M (8.1%)

Top 5 countries are about 56.8% of net sales.

### 3) Product concentration is real
The top product alone is a big chunk of revenue:
- Côte de Blaye: $53.27M (11.9% of total net sales)

That is a concentration risk. If this product stockouts, gets delisted, or gets discounted too hard, topline will take a hit.

## What I would do next
Therefore, we should focus on the top categories in the top countries, and audit the top products, especially Côte de Blaye,
because that is where most net sales live, and we expect the biggest ROI from tightening pricing, discount rules, and inventory planning.

Two follow ups I would run:
1) Discount rate by category and country, to see where we are giving away money.
2) Sales trend by month, to see if any category or country is growing or shrinking.

## Files
| File | What it does |
|------|--------------|
| `sales_base.sql` | Base sales lines table with joins + net sales |
| `checks.sql` | Sanity checks for discounts, nulls, totals |
| `sales_by_category.sql` | Net sales by category + share |
| `sales_by_country.sql` | Net sales by ship country + share |
| `top_products.sql` | Top products by net sales |
| `run_sales_breakdown.py` | Exports CSVs + saves charts |
| `outputs/sales_by_category.csv` | Category breakdown |
| `outputs/sales_by_country.csv` | Country breakdown |
| `outputs/top_products.csv` | Top products |
| `outputs/top_categories.png` | Chart |
| `outputs/top_countries.png` | Chart |
