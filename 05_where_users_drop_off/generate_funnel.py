import pandas as pd
import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt

# synthetic funnel -- clearly labeled, built to demo the analysis pattern
np.random.seed(42)

steps = [
    ("Visited landing page",     10000),
    ("Started signup",            6200),
    ("Verified email",            4100),
    ("Added payment method",      2300),
    ("Completed first order",     1400),
]

df = pd.DataFrame(steps, columns=["step", "users"])
df["step_rate"] = df["users"] / df["users"].shift(1)
df["overall_rate"] = df["users"] / df["users"].iloc[0]

out = Path("05_where_users_drop_off/outputs")
out.mkdir(exist_ok=True)
df.to_csv(out / "funnel_steps.csv", index=False)

fig, ax = plt.subplots(figsize=(10, 5))
colors = ["#2196F3"] * len(df)
bars = ax.barh(df["step"][::-1], df["users"][::-1], color=colors)

for bar, val in zip(bars, df["users"][::-1]):
    ax.text(bar.get_width() + 100, bar.get_y() + bar.get_height()/2,
            f"{val:,}", va="center", fontsize=10)

ax.set_xlabel("Users")
ax.set_title("Signup funnel (simulated data)")
ax.set_xlim(0, 12000)
plt.tight_layout()
plt.savefig(out / "funnel_chart.png", dpi=200)
print(df.to_string(index=False))
