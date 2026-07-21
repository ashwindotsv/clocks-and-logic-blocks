"""
Visual comparison grid: original image | colorized ground truth mask | your flags

This is the "50-100 misclassified images" deliverable, adapted since
you don't have a trained segmentation model yet. For now this shows
ALL images where non_drivable_present=1 but the raw non-drivable pixel
coverage is small (< 5%) - i.e. exactly the "empty road flagged
non-drivable" cases your prof is worried about. This directly targets
his stated concern instead of just showing random samples.

Once you train a segmentation model, swap this for actual prediction
vs ground truth comparison (root cause iii).
"""

import os
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from PIL import Image

GT_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\gtFine\train"
IMG_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\leftImg8bit\train"
OUT_DIR = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference"

IGNORE_ID = 255
NON_DRIVABLE_ID = 1
FLAG_THRESHOLD = 0.01          # matches your Stage 1 script
SUSPICIOUS_CEILING = 0.05      # "small sliver" cutoff for flagging suspicious cases
MAX_SAMPLES = 100

# colors for level1Id 0-5, index = level1Id value
LEVEL1_COLORS = [
    "#404040",  # 0 drivable       - dark gray
    "#e6194B",  # 1 non_drivable   - red (the one we care about)
    "#3cb44b",  # 2 living_thing   - green
    "#4363d8",  # 3 vehicle        - blue
    "#ffe119",  # 4 roadside_obj   - yellow
    "#911eb4",  # 5 far_objects    - purple
]
CMAP = ListedColormap(LEVEL1_COLORS)

def find_pairs(img_root, gt_root):
    pattern = os.path.join(img_root, "**", "*_image.jpg")
    pairs = []
    for img_path in glob.glob(pattern, recursive=True):
        scene = os.path.basename(os.path.dirname(img_path))
        img_id = os.path.basename(img_path).replace("_image.jpg", "")
        mask_path = os.path.join(gt_root, scene, f"{img_id}_label.png")
        if os.path.exists(mask_path):
            pairs.append((img_path, mask_path, img_id))
    return pairs

def main():
    pairs = find_pairs(IMG_ROOT, GT_ROOT)
    print(f"Found {len(pairs)} image/mask pairs. Scanning for suspicious cases...")

    suspicious = []
    for img_path, mask_path, img_id in pairs:
        mask = np.array(Image.open(mask_path))
        valid = mask[mask != IGNORE_ID]
        if valid.size == 0:
            continue
        nd_frac = (valid == NON_DRIVABLE_ID).sum() / valid.size
        flagged = nd_frac > FLAG_THRESHOLD
        if flagged and nd_frac < SUSPICIOUS_CEILING:
            suspicious.append((img_path, mask_path, img_id, nd_frac))

    print(f"Found {len(suspicious)} suspicious cases "
          f"(flagged non_drivable_present=1 but <5% of pixels are actually non-drivable).")

    suspicious = suspicious[:MAX_SAMPLES]
    n = len(suspicious)
    if n == 0:
        print("No suspicious cases found in this range - try adjusting SUSPICIOUS_CEILING.")
        return

    cols = 3
    rows = n
    fig, axes = plt.subplots(rows, cols, figsize=(12, 4 * rows))
    if rows == 1:
        axes = axes.reshape(1, -1)

    for i, (img_path, mask_path, img_id, nd_frac) in enumerate(suspicious):
        img = Image.open(img_path)
        mask = np.array(Image.open(mask_path))

        axes[i, 0].imshow(img)
        axes[i, 0].set_title(f"{img_id} - original", fontsize=9)
        axes[i, 0].axis("off")

        display_mask = np.where(mask == IGNORE_ID, 0, mask)  # map ignore to 0 for display only
        axes[i, 1].imshow(display_mask, cmap=CMAP, vmin=0, vmax=5)
        axes[i, 1].set_title("ground truth mask (red=non_drivable)", fontsize=9)
        axes[i, 1].axis("off")

        axes[i, 2].axis("off")
        axes[i, 2].text(
            0.05, 0.5,
            f"non_drivable pixel frac: {nd_frac:.2%}\n"
            f"threshold: {FLAG_THRESHOLD:.0%}\n"
            f"-> flagged non_drivable_present = 1\n\n"
            f"but only {nd_frac:.1%} of the image\n"
            f"is actually non-drivable pixels.",
            fontsize=10, va="center"
        )

    plt.tight_layout()
    out_path = os.path.join(OUT_DIR, "suspicious_nondrivable_flags.png")
    plt.savefig(out_path, dpi=100)
    print(f"\nSaved grid to: {out_path}")
    print(f"({n} images shown, out of {len(suspicious)} total suspicious cases found)")

if __name__ == "__main__":
    main()
