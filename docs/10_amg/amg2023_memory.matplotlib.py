import csv
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter


def load_memory_data(filename):
    with (Path(__file__).parent / "data" / filename).open(newline="") as stream:
        rows = list(csv.DictReader(stream))
    return (
        [int(row["n"]) for row in rows],
        [float(row["Node Memory (GB)"]) for row in rows],
    )


problem1_n, problem1_memory = load_memory_data(
    "amg2023_problem1_memory_usage_rocm.csv"
)
problem2_n, problem2_memory = load_memory_data(
    "amg2023_problem2_memory_usage_rocm.csv"
)

fig, ax = plt.subplots(figsize=(12, 5.6))
ax.plot(
    problem1_n,
    problem1_memory,
    color="#00ad55",
    marker="o",
    label="Problem 1",
)
ax.plot(
    problem2_n,
    problem2_memory,
    color="#0072b2",
    marker="s",
    label="Problem 2",
)
ax.set_title("AMG2023: El Capitan Memory Usage on 1 Node (4 GPUs), problem size/GPU n x n x n")
ax.set_xlabel("n")
ax.set_ylabel("Node Memory (GB)")
ax.set_xticks(sorted(set(problem1_n + problem2_n)))
ax.xaxis.set_major_formatter(FormatStrFormatter("%d"))
ax.set_ylim(0, 240)
ax.yaxis.set_major_formatter(FormatStrFormatter("%.2f"))
ax.grid(True, alpha=0.35)
ax.legend(loc="upper left", frameon=False)
fig.tight_layout()
fig.savefig(Path(__file__).parent / "plots" / "amg2023_memory_usage_rocm.png", dpi=150)
plt.close(fig)
