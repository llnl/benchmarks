import csv
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter


data_file = Path(__file__).parent / "data" / "amg2023_problem2_weak_rocm.csv"
with data_file.open(newline="") as stream:
    rows = list(csv.DictReader(stream))

nodes = [int(row["Nodes"]) for row in rows]
fom_per_gpu = [float(row["FOM"]) for row in rows]

fig, ax = plt.subplots(figsize=(12, 5.6))
ax.plot(
    nodes,
    fom_per_gpu,
    color="#00ad55",
    marker="o",
    label="FOM",
)
ax.set_title("AMG2023: Weak Scaling for Problem 2, 350 x 350 x 350")
ax.set_xlabel("Nodes")
ax.set_ylabel("FOM\n[nnz_AP / (Setup Phase Time + Solve Phase Time) / GPU]")
ax.set_xscale("log", base=2)
ax.set_xticks(nodes)
ax.xaxis.set_major_formatter(FormatStrFormatter("%d"))
ax.set_ylim(5e+07, 1.4e+08)
ax.yaxis.set_major_formatter(FormatStrFormatter("%.2E"))
ax.grid(True, alpha=0.35)
ax.legend(loc="upper left", bbox_to_anchor=(1.02, 1.0), frameon=False)
fig.tight_layout()
fig.savefig(Path(__file__).parent / "plots" / "amg2023_problem2_weak_rocm.png", dpi=150)
plt.close(fig)
