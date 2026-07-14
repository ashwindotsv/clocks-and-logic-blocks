# ============================================================
# Category frequency check + DEBUG VERSION
# ============================================================
import os
import glob
import numpy as np
from PIL import Image
import pandas as pd
import matplotlib.pyplot as plt

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Candidate category IDs (these may turn out to be incorrect,
# which is exactly what we're debugging)
CANDIDATE_CATEGORIES = {
    "person":       6,
    "animal":       7,
    "rider":        8,
    "motorcycle":   9,
    "bicycle":      10,
    "autorickshaw": 11,
    "car":          12,
    "truck":        13,
    "bus":          14,
}

MIN_PIXEL_FRAC = 0.005  # 0.5%

def count_categories(img_root, mask_root):

    counts = {name: 0 for name in CANDIDATE_CATEGORIES}
    total_images = 0

    debug_done = False

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

            # ===================================================
            # DEBUG SECTION (runs only once)
            # ===================================================
            if not debug_done:

                unique, pixel_counts = np.unique(mask, return_counts=True)

                print("\n==============================")
                print("DEBUG: FIRST MASK INFORMATION")
                print("==============================")

                print("\nUnique labels:")
                print(unique)

                print("\nPixel count per label:")

                total = mask.size

                for u, c in zip(unique, pixel_counts):
                    print(
                        f"Label {u:3d} : "
                        f"{c:8d} pixels "
                        f"({100*c/total:.2f}%)"
                    )

                plt.figure(figsize=(8, 8))
                plt.imshow(mask, cmap="tab20")
                plt.title("First Segmentation Mask")
                plt.colorbar()
                plt.show()

                debug_done = True
            # ===================================================

            total_pixels = mask.size
            total_images += 1

            for name, class_id in CANDIDATE_CATEGORIES.items():

                frac = (mask == class_id).sum() / total_pixels

                if frac > MIN_PIXEL_FRAC:
                    counts[name] += 1

    return counts, total_images


counts, total_images = count_categories(
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/leftImg8bit/train",
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/gtFine/train"
)

print("\n==============================")
print(f"Total images checked: {total_images}")
print("==============================\n")

result_df = pd.DataFrame(
    [
        (name, count, f"{100*count/total_images:.1f}%")
        for name, count in counts.items()
    ],
    columns=["category", "num_images", "pct_of_dataset"]
).sort_values("num_images", ascending=False)

print(result_df.to_string(index=False))