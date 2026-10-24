import csv
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter


data_file = Path(__file__).with_name("branson_cuda_throughput.csv")
with data_file.open(newline="") as stream:
    rows = list(csv.DictReader(stream))

photons_per_node = [float(row["Photons/Node"]) for row in rows]
fom = [float(row["FOM (Photons/s)"]) for row in rows]

fig, ax = plt.subplots(figsize=(12, 5.6))
ax.plot(
    photons_per_node,
    fom,
    color="#00ad55",
    marker="o",
    label="FOM (Photons/s/node)",
)
ax.set_title("Branson: Throughput FOM, 1 Node (4 GPUs)")
ax.set_xlabel("Photons/node")
ax.set_ylabel("FOM\n[Photons/s/node]")
ax.xaxis.set_major_formatter(FormatStrFormatter("%.2E"))
ax.yaxis.set_major_formatter(FormatStrFormatter("%.2E"))
ax.grid(True, alpha=0.35)
ax.legend(loc="upper left", bbox_to_anchor=(1.02, 1.0), frameon=False)
fig.tight_layout()
fig.savefig(Path(__file__).with_name("branson_cuda_throughput.png"), dpi=150)
plt.close(fig)
