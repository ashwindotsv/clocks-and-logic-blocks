# ============================================================
# Frequency check: how common is each of the 6 level1Id categories
# ============================================================
import os
import glob
import numpy as np
from PIL import Image
import pandas as pd

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Real level1Id groups, from AutoNUE/public-code anue_labels.py
LEVEL1_CATEGORIES = {
    "drivable":      0,
    "non_drivable":  1,
    "living_thing":  2,
    "vehicle":       3,
    "roadside_obj":  4,
    "far_objects":   5,
}

MIN_PIXEL_FRAC = 0.02  # a category "counts" as present if it covers at least 2% of the image

def count_categories(img_root, mask_root):
    counts = {name: 0 for name in LEVEL1_CATEGORIES}
    total_images = 0

    for scene in os.listdir(img_root):
        img_folder = os.path.join(img_root, scene)
        mask_folder = os.path.join(mask_root, scene)
        if not os.path.isdir(img_folder) or not os.path.isdir(mask_folder):
            continue

        for img_path in glob.glob(os.path.join(img_folder, "*_image.jpg")):
            img_id = os.path.basename(img_path).replace("_image.jpg", "")
            mask_path = os.path.join(mask_folder, f"{img_id}_label.png")
            if not os.path.exists(mask_path):
                continue

            mask = np.array(Image.open(mask_path))
            total_pixels = mask.size
            total_images += 1

            for name, level1_id in LEVEL1_CATEGORIES.items():
                frac = (mask == level1_id).sum() / total_pixels
                if frac > MIN_PIXEL_FRAC:
                    counts[name] += 1

    return counts, total_images

counts, total_images = count_categories(
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/leftImg8bit/train",
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/gtFine/train"
)

print(f"Total images checked: {total_images}\n")
result_df = pd.DataFrame(
    [(name, count, f"{100*count/total_images:.1f}%") for name, count in counts.items()],
    columns=["category", "num_images", "pct_of_dataset"]
).sort_values("num_images", ascending=False)

print(result_df.to_string(index=False))