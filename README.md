# kevin-analytics

Five mini case studies where SQL answers a business question and ends with a decision.
But not just queries ;) It has recommendations, checks, and outputs

**Databases:** Chinook (music store), Northwind (retail/orders)  
**Tools:** SQLite, Python, pandas, matplotlib

## The five questions

| Case | Question | Database | Key technique |
|------|----------|----------|---------------|
| [01](01_who_are_our_best_customers/) | Who are our best customers? | Chinook | RFM segmentation, reactivation targeting |
| [02](02_are_we_keeping_customers/) | Are we keeping customers? | Chinook | Cohort retention, retention heatmap |
| [03](03_where_money_comes_from/) | Where does the money come from? | Northwind | Revenue breakdown, concentration risk |
| [04](04_what_changed_vs_last_period/) | What changed vs last period? | Northwind | Variance analysis (price vs volume) |
| [05](05_where_users_drop_off/) | Where do users drop off? | Synthetic | Funnel analysis, step conversion, experiment plan |

## What’s inside each case

Each folder follows the same pattern:
- SQL that answers the question
- Python script that exports CSVs + charts
- data checks to sanity-check the numbers
- README with the finding and a concrete “therefore we should…” recommendation

## Run it locally

```bash
git clone https://github.com/aidaken/kevin-analytics.git
cd kevin-analytics

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
````

Download the databases:

```bash
mkdir -p data

curl -L -o data/chinook.sqlite \
  https://github.com/lerocha/chinook-database/raw/master/ChinookDatabase/DataSources/Chinook_Sqlite.sqlite

curl -L -o data/northwind.db \
  https://github.com/jpwhite3/northwind-SQLite3/raw/main/dist/northwind.db
```

Run any case:

```bash
python 01_who_are_our_best_customers/run_top_customers.py
python 02_are_we_keeping_customers/run_cohort_retention.py
python 03_where_money_comes_from/run_sales_breakdown.py
python 04_what_changed_vs_last_period/run_variance.py
python 05_where_users_drop_off/generate_funnel.py
```

## Why I built this

A lot of SQL practice stops at “here’s the output.”
I built these to practice the real job: turn data into a decision and explain the tradeoffs

---

Aidar Kenzhebaev