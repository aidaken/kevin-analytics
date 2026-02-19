import sqlite3
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt

db_path = Path("data/chinook.sqlite")
sql_path = Path("01_who_are_our_best_customers/top_customers.sql")
out_dir = Path("01_who_are_our_best_customers/outputs")
out_dir.mkdir(parents=True, exist_ok=True)

conn = sqlite3.connect(db_path)
sql = sql_path.read_text()

df = pd.read_sql_query(sql, conn)

csv_path = out_dir / "top_customers.csv"
df.to_csv(csv_path, index=False)

ax = df.head(10).plot(kind="bar", x="customer_name", y="total_spent", legend=False)
ax.set_title("Top 10 customers by total spent (Chinook)")
ax.set_ylabel("Total spent")
plt.tight_layout()

img_path = out_dir / "top_customers.png"
plt.savefig(img_path, dpi=200)

print("Saved CSV:", csv_path)
print("Saved PNG:", img_path)
