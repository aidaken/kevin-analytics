import sqlite3
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt

db_path = Path("data/northwind.db")
sql_path = Path("05_where_users_drop_off/customer_funnel_northwind.sql")
out_dir = Path("05_where_users_drop_off/outputs")
out_dir.mkdir(parents=True, exist_ok=True)

with sqlite3.connect(db_path) as conn:
    funnel = pd.read_sql_query(sql_path.read_text(), conn)

csv_path = out_dir / "customer_funnel.csv"
funnel.to_csv(csv_path, index=False)

ax = funnel.plot(kind="bar", x="step", y="users", legend=False)
ax.set_title("Customer funnel (Northwind)")
ax.set_xlabel("")
ax.set_ylabel("Customers")
plt.xticks(rotation=20, ha="right")
plt.tight_layout()

img_path = out_dir / "customer_funnel.png"
plt.savefig(img_path, dpi=200)

print("Saved:", csv_path)
print("Saved:", img_path)
print(funnel.to_string(index=False))
