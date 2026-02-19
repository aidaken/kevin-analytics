import sqlite3
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt

db_path = Path("data/chinook.sqlite")
sql_path = Path("01_who_are_our_best_customers/value_tiers.sql")
out_dir = Path("01_who_are_our_best_customers/outputs")
out_dir.mkdir(parents=True, exist_ok=True)

conn = sqlite3.connect(db_path)
sql = sql_path.read_text()

df = pd.read_sql_query(sql, conn)

csv_path = out_dir / "value_tiers_summary.csv"
df.to_csv(csv_path, index=False)

ax = df.plot(kind="bar", x="value_tier", y="revenue_sum", legend=False)
ax.set_title("Revenue by customer tier (Chinook)")
ax.set_ylabel("Revenue")
plt.tight_layout()

img_path = out_dir / "value_tiers_revenue.png"
plt.savefig(img_path, dpi=200)

print("Saved CSV:", csv_path)
print("Saved PNG:", img_path)


