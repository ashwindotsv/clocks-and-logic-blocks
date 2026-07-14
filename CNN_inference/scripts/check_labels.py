import pandas as pd
import matplotlib.pyplot as plt
from PIL import Image
import os

# Build a path relative to THIS script's location, not the working directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(SCRIPT_DIR, "..", "idd_train_labels.csv")

train_df = pd.read_csv(CSV_PATH)

label_names = {0: "clear road", 1: "congested", 2: "other/non-drivable"}

N_SAMPLES = 5

fig, axes = plt.subplots(3, N_SAMPLES, figsize=(4 * N_SAMPLES, 12))

for row_idx, class_id in enumerate([0, 1, 2]):
    samples = train_df[train_df["label"] == class_id].sample(N_SAMPLES)

    for col_idx, (_, row) in enumerate(samples.iterrows()):
        img = Image.open(row["img_path"])
        ax = axes[row_idx, col_idx]
        ax.imshow(img)
        ax.set_title(f"{label_names[class_id]} (label={class_id})")
        ax.axis("off")

plt.tight_layout()
plt.savefig(os.path.join(SCRIPT_DIR, "..", "label_sanity_check.png"))
plt.show()