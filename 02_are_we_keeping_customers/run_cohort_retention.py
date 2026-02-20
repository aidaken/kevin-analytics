import sqlite3
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt

db_path = Path("data/chinook.sqlite")
sql_path = Path("02_are_we_keeping_customers/cohort_retention.sql")
out_dir = Path("02_are_we_keeping_customers/outputs")
out_dir.mkdir(parents=True, exist_ok=True)

conn = sqlite3.connect(db_path)
df = pd.read_sql_query(sql_path.read_text(), conn)

long_csv = out_dir / "retention_long.csv"
df.to_csv(long_csv, index=False)

pivot = (
    df.pivot(index="cohort_month", columns="month_index", values="retention_rate")
      .sort_index()
      .fillna(0)
)

# optional: only show first N months (makes it way more readable)
max_month = 24
if max_month is not None:
    pivot = pivot.loc[:, pivot.columns <= max_month]

wide_csv = out_dir / "retention_matrix.csv"
pivot.to_csv(wide_csv, index=True)

fig, ax = plt.subplots(figsize=(12, 6))
im = ax.imshow(pivot.values, aspect="auto", interpolation="nearest")

ax.set_title("Cohort retention heatmap")
ax.set_xlabel("Month index")
ax.set_ylabel("Cohort month")

# x ticks: don’t label every single month, it becomes a barcode
x_labels = list(pivot.columns)
x_step = 3  # change to 2, 4, 6 if you want
x_pos = list(range(0, len(x_labels), x_step))
ax.set_xticks(x_pos)
ax.set_xticklabels([str(x_labels[i]) for i in x_pos], rotation=0)

# y ticks: if there are too many cohorts, skip some labels
y_labels = list(pivot.index)
max_y_labels = 12
y_step = max(1, len(y_labels) // max_y_labels)
y_pos = list(range(0, len(y_labels), y_step))
ax.set_yticks(y_pos)
ax.set_yticklabels([str(y_labels[i]) for i in y_pos])

plt.colorbar(im, ax=ax)
plt.tight_layout()

img_path = out_dir / "retention_heatmap.png"
plt.savefig(img_path, dpi=200, bbox_inches="tight")

print("Saved:", long_csv)
print("Saved:", wide_csv)
print("Saved:", img_path)
print("Rows:", len(df))
print("Months shown:", int(pivot.columns.max()))
