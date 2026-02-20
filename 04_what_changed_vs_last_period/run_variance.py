import sqlite3
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

db_path = Path("data/northwind.db")
out_dir = Path("04_what_changed_vs_last_period/outputs")
out_dir.mkdir(parents=True, exist_ok=True)

def pull_multi(sql_file: str) -> pd.DataFrame:
    sql = Path(sql_file).read_text()
    parts = [p.strip() for p in sql.split(";") if p.strip()]
    setup = ";\n".join(parts[:-1]) + ";" if len(parts) > 1 else ""
    final = parts[-1] + ";"

    with sqlite3.connect(db_path) as conn:
        if setup:
            conn.executescript(setup)
        return pd.read_sql_query(final, conn)

overall = pull_multi("04_what_changed_vs_last_period/variance_overall.sql")
by_cat = pull_multi("04_what_changed_vs_last_period/variance_by_category.sql")

overall.to_csv(out_dir / "variance_overall.csv", index=False)
by_cat.to_csv(out_dir / "variance_by_category.csv", index=False)

fmt = mtick.FuncFormatter(lambda x, _: f"${x/1e3:.0f}K")

by_cat_sorted = by_cat.sort_values("net_change", ascending=False).copy()
colors = ["green" if v >= 0 else "crimson" for v in by_cat_sorted["net_change"]]

fig, ax = plt.subplots(figsize=(10, 5))
ax.bar(by_cat_sorted["category_name"], by_cat_sorted["net_change"], color=colors)
ax.set_title("Net sales change vs prior period by category")
ax.set_xlabel("Category")
ax.set_ylabel("Net change ($K)")
ax.yaxis.set_major_formatter(fmt)
ax.axhline(0, color="black", linewidth=0.8)
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.savefig(out_dir / "category_movers.png", dpi=200)

print("Saved:", out_dir / "variance_overall.csv")
print("Saved:", out_dir / "variance_by_category.csv")
print("Saved:", out_dir / "category_movers.png")
