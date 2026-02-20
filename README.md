# kevin-analytics

Five SQL case studies built to answer real business questions.
Each one goes from raw data to a recommendation, not just a query

**Databases:** Chinook (music store), Northwind (retail/orders)
**Tools:** SQLite, Python, pandas, matplotlib

---

## The five questions

| Case | Question | Database | Key technique |
|------|----------|----------|---------------|
| [01](01_who_are_our_best_customers/) | Who are our best customers? | Chinook | RFM segmentation, reactivation targeting |
| [02](02_are_we_keeping_customers/) | Are we keeping customers? | Chinook | Cohort retention, heatmap |
| [03](03_where_money_comes_from/) | Where does the money come from? | Northwind | Revenue breakdown, concentration risk |
| [04](04_what_changed_vs_last_period/) | What changed vs last period? | Northwind | Variance analysis, price vs volume effects |
| [05](05_where_users_drop_off/) | Where do users drop off? | Synthetic | Funnel analysis, conversion by step |

---

## How each case is structured

Every folder has the same pattern:

- The SQL that answers the question
- A Python script that exports CSVs and charts
- A data checks file verifying the numbers are trustworthy
- A README with the finding and a concrete recommendation

---

## Running it yourself
```bash
git clone https://github.com/YOUR_USERNAME/kevin-analytics
cd kevin-analytics
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

Download the databases:
```bash
curl -L -o data/chinook.sqlite \
  https://github.com/lerocha/chinook-database/raw/master/ChinookDatabase/DataSources/Chinook_Sqlite.sqlite

curl -L -o data/northwind.db \
  https://github.com/jpwhite3/northwind-SQLite3/raw/main/dist/northwind.db
```

Then run any case:
```bash
python 01_who_are_our_best_customers/run_top_customers.py
python 02_are_we_keeping_customers/run_cohort_retention.py
python 03_where_money_comes_from/run_sales_breakdown.py
python 04_what_changed_vs_last_period/run_variance.py
python 05_where_users_drop_off/generate_funnel.py
```

---

## What I was going for

Most SQL practice stops at "here's the output." I wanted each case
to end with a decision: who to contact, what to fix, where to focus.

That's the gap between writing queries and doing analysis.

---
Aidar Kenzhebaev