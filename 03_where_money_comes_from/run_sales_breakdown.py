import sqlite3
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

# This script pulls sales breakdown data from the Northwind database and generates charts.
db_path = Path("data/northwind.db")
out_dir = Path("03_where_money_comes_from/outputs")
out_dir.mkdir(parents=True, exist_ok=True)

def pull(sql_file):
    with sqlite3.connect(db_path) as conn:
        return pd.read_sql_query(Path(sql_file).read_text(), conn)

by_category = pull("03_where_money_comes_from/sales_by_category.sql")
by_country  = pull("03_where_money_comes_from/sales_by_country.sql")
top_products = pull("03_where_money_comes_from/top_products.sql")

by_category.to_csv(out_dir / "sales_by_category.csv", index=False)
by_country.to_csv(out_dir  / "sales_by_country.csv",  index=False)
top_products.to_csv(out_dir / "top_products.csv",     index=False)

fmt = mtick.FuncFormatter(lambda x, _: f"${x/1e6:.0f}M")

ax = by_category.head(10).plot(kind="bar", x="category_name", y="net_sales", legend=False)
ax.set_title("Top categories by net sales")
ax.set_ylabel("Net sales")
ax.set_xlabel("Category")
ax.yaxis.set_major_formatter(fmt)
plt.tight_layout()
plt.savefig(out_dir / "top_categories.png", dpi=200)

plt.clf()
ax = by_country.head(10).plot(kind="bar", x="ship_country", y="net_sales", legend=False)
ax.set_title("Top countries by net sales")
ax.set_ylabel("Net sales")
ax.set_xlabel("Country")
ax.yaxis.set_major_formatter(fmt)
plt.tight_layout()
plt.savefig(out_dir / "top_countries.png", dpi=200)

print("Saved CSVs + charts in:", out_dir)
print("Rows:", len(by_category), len(by_country), len(top_products))
