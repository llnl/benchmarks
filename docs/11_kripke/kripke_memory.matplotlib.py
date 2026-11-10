import csv
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter


data_file = Path(__file__).parent / "data" / "kripke_memory_usage_rocm.csv"
with data_file.open(newline="") as stream:
    rows = list(csv.DictReader(stream))

nodes = [int(row["Size"]) for row in rows]
fom_per_gpu = [float(row["Node Memory (GB)"]) for row in rows]

fig, ax = plt.subplots(figsize=(12, 5.6))
ax.plot(
    nodes,
    fom_per_gpu,
    color="#00ad55",
    marker="o",
    label="Node Memory (GB)",
)
ax.set_title("Kripke: El Capitan Memory Usage (GB) for 1-Node (4 GPUs)")
ax.set_xlabel("Total Problem Size")
ax.set_ylabel("Node Memory (GB)")
ax.set_xticks(nodes)
ax.xaxis.set_major_formatter(FormatStrFormatter("%d"))
plt.setp(ax.get_xticklabels(), rotation=45, ha="right", rotation_mode="anchor")
ax.set_ylim(0, 450)
ax.yaxis.set_major_formatter(FormatStrFormatter("%.2E"))
ax.grid(True, alpha=0.35)
ax.legend(loc="upper left", frameon=False)
fig.tight_layout()
fig.savefig(Path(__file__).parent / "plots" / "kripke_memory_usage_rocm.png", dpi=150)
plt.close(fig)
