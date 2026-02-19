import sqlite3
import pandas as pd
from pathlib import Path

db_path = Path("data/chinook.sqlite")
sql_path = Path("01_who_are_our_best_customers/final_targets.sql")
out_dir = Path("01_who_are_our_best_customers/outputs")
out_dir.mkdir(parents=True, exist_ok=True)

conn = sqlite3.connect(db_path)
df = pd.read_sql_query(sql_path.read_text(), conn)

csv_path = out_dir / "target_list.csv"
df.to_csv(csv_path, index=False)

print("Saved CSV:", csv_path)
print("Rows:", len(df))
print(df.head(10).to_string(index=False))
