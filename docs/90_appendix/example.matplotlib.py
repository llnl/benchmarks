#!/usr/bin/env python3

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import pandas as pd


def percent_to_float(percent_str):
    """Convert from percentage to float."""
    return float(percent_str.rstrip("%")) / 100.0


df = pd.read_csv("example.csv")
np_array = df.to_numpy()

x_string = np_array[:, 0]
y = np_array[:, 2]

# Apply the function to the array using np.vectorize
vectorized_func = np.vectorize(percent_to_float)
x = vectorized_func(x_string)

# Create a figure and an axes object
# plt.rcParams["font.family"] = "serif"  # Set default globally
# plt.rcParams["font.size"] = 12 # Set default font size for all text
plt.rcParams["font.family"] = "sans-serif"
plt.rcParams["font.sans-serif"] = ["Helvetica"] + plt.rcParams["font.sans-serif"]
plt.rcParams["font.size"] = 18  # Set default font size for all text
width_pixels = 1024
height_pixels = 768
display_dpi = 100
fig, ax = plt.subplots(
    figsize=(width_pixels / display_dpi, height_pixels / display_dpi), dpi=display_dpi
)

# Plot the data on the axes
ax.plot(
    x,
    y,
    label="Discovery",
    marker="o",
    fillstyle="none",
    linestyle="-",
    color="r",
    markersize=12,
)

# Add labels and a title
ax.set_title(
    "Matplotlib: APP Scaling on HAL 9000 Utilizing All Memory Circuits",
    fontname="serif",
    fontsize=18,
    fontweight="bold",
)
ax.set_xlabel("Memory Percentage")
ax.set_ylabel("No. of Active Cameras")
ax.set_xlim(0, 1)
ax.set_ylim(40, 80)
ax.legend()

# Apply the PercentFormatter
# xmax=1.0 specifies that the value 1.0 should be displayed as 100%.
# decimals=None automatically determines the optimal number of decimal places.
formatter = mtick.PercentFormatter(xmax=1.0, decimals=None)
ax.xaxis.set_major_formatter(formatter)

# Ticks, Major and Minor Gridlines are nice
ax.minorticks_on()
ax.grid(which="major", linestyle=":", linewidth="0.1", color="gray")
# ax.grid(which='minor', linestyle=':', linewidth='0.5', color='gray')

# Display or save the plot
# plt.show()
plt.savefig("example-matplotlib.png")
