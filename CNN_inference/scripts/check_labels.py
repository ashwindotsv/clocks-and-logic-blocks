# ============================================================
# Visual sanity check (multi-label): 4x4 grid, random images,
# each titled with which of the 3 flags are true
# ============================================================
import os
import pandas as pd
import matplotlib.pyplot as plt
from PIL import Image

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(SCRIPT_DIR, "..", "idd_train_labels.csv")

train_df = pd.read_csv(CSV_PATH)

# Grab 16 random images (no seed = different set each run)
samples = train_df.sample(16)

fig, axes = plt.subplots(4, 4, figsize=(16, 16))

for ax, (_, row) in zip(axes.flatten(), samples.iterrows()):
    img = Image.open(row["img_path"])
    ax.imshow(img)

    # Build a short title showing which flags are true for this image
    flags = []
    if row["vehicle_present"]:
        flags.append("vehicle")
    if row["non_drivable_present"]:
        flags.append("non_drivable")
    if row["living_thing_present"]:
        flags.append("living_thing")

    title = ", ".join(flags) if flags else "none"
    ax.set_title(title, fontsize=10)
    ax.axis("off")

plt.tight_layout()
plt.savefig(os.path.join(SCRIPT_DIR, "..", "label_sanity_check.png"))
plt.show()