import csv
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter


data_file = Path(__file__).with_name("branson_rocm_memoryusage.csv")
with data_file.open(newline="") as stream:
    rows = list(csv.DictReader(stream))

photons_per_node = [float(row["Photons/Node"]) for row in rows]
memory_per_node = [float(row["Memory Usage/Node (GB)"]) for row in rows]

fig, ax = plt.subplots(figsize=(12, 5.6))
ax.plot(
    photons_per_node,
    memory_per_node,
    color="#00ad55",
    marker="o",
    label="Memory Usage/Node (GB)",
)
ax.set_title("Branson: El Capitan Single Node Memory Usage")
ax.set_xlabel("Photons/Node")
ax.set_ylabel("Memory Usage/Node\n[GB]")
ax.xaxis.set_major_formatter(FormatStrFormatter("%.2E"))
ax.yaxis.set_major_formatter(FormatStrFormatter("%.2f"))
ax.grid(True, alpha=0.35)
ax.legend(loc="upper left", bbox_to_anchor=(1.02, 1.0), frameon=False)
fig.tight_layout()
fig.savefig(Path(__file__).with_name("branson_rocm_memoryusage.png"), dpi=150)
plt.close(fig)
