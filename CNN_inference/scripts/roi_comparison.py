"""
ROI-based non-drivable labeling comparison.

Compares 5 labeling methods x 4 thresholds = 20 combinations:
  - whole_image   (original method, for baseline reference)
  - bottom_half   (y: 50-100%, x: 0-100%)
  - roi_1         (x: 30-70%, y: 60-100%)
  - roi_2         (x: 25-75%, y: 55-100%)
  - roi_3         (x: 40-60%, y: 65-100%)

thresholds tested: 5%, 10%, 15%, 20%

For each combination, reports:
  1. How many images get labeled non_drivable overall
  2. Of the 482 images that were "ambiguous" under the original whole-image
     1% method (flagged non_drivable but <5% actual non-drivable pixels),
     how many FLIP to drivable under this method. if this is high (most of the 482
     flip), the ROI fix works.
"""

import os
import glob
import numpy as np
import pandas as pd
from PIL import Image

GT_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\gtFine\train"
IMG_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\leftImg8bit\train"
OUT_DIR = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference"

IGNORE_ID = 255
NON_DRIVABLE_ID = 1

# Original method's settings, used to define "the 482 ambiguous cases"
ORIGINAL_THRESHOLD = 0.01
AMBIGUOUS_CEILING = 0.05  # same definition as visual_comparison.py

THRESHOLDS = [0.05, 0.10, 0.15, 0.20]

# (name, x_range, y_range) as fractions of (W, H). y=0 is top of image.
ROI_DEFS = {
    "whole_image": (0.0, 1.0, 0.0, 1.0),
    "bottom_half": (0.0, 1.0, 0.5, 1.0),
    "roi_1":       (0.30, 0.70, 0.60, 1.0),
    "roi_2":       (0.25, 0.75, 0.55, 1.0),
    "roi_3":       (0.40, 0.60, 0.65, 1.0),
}

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

def non_drivable_fraction(mask, x0, x1, y0, y1):
    H, W = mask.shape
    region = mask[int(y0 * H):int(y1 * H), int(x0 * W):int(x1 * W)]
    valid = region[region != IGNORE_ID]
    if valid.size == 0:
        return 0.0
    return (valid == NON_DRIVABLE_ID).sum() / valid.size

def main():
    pairs = find_pairs(IMG_ROOT, GT_ROOT)
    print(f"Found {len(pairs)} image/mask pairs.\n")

    # Pass 1: compute the ROI fraction for every method, for every image, once.
    records = []
    for img_path, mask_path, img_id in pairs:
        mask = np.array(Image.open(mask_path))
        row = {"img_id": img_id}
        for method_name, (x0, x1, y0, y1) in ROI_DEFS.items():
            row[method_name] = non_drivable_fraction(mask, x0, x1, y0, y1)
        records.append(row)

    df = pd.DataFrame(records)

    # Identify the "482 ambiguous cases" from the original method:
    # flagged non_drivable at 1% threshold, but <5% actual non-drivable pixels
    df["orig_flagged"] = df["whole_image"] > ORIGINAL_THRESHOLD
    df["orig_ambiguous"] = df["orig_flagged"] & (df["whole_image"] < AMBIGUOUS_CEILING)
    n_ambiguous = df["orig_ambiguous"].sum()
    print(f"Ambiguous cases (matches your earlier 482 count): {n_ambiguous}\n")

    # Pass 2: for every method x threshold, compute label and flip rate
    results = []
    ambiguous_df = df[df["orig_ambiguous"]]

    for method_name in ROI_DEFS:
        for thresh in THRESHOLDS:
            labels = df[method_name] > thresh
            n_flagged = labels.sum()

            # of the ambiguous cases, how many are now labeled drivable
            # (i.e. flipped) under this method+threshold
            amb_labels = ambiguous_df[method_name] > thresh
            n_flipped = (~amb_labels).sum()  # False = drivable now = flipped
            pct_flipped = 100 * n_flipped / n_ambiguous if n_ambiguous else 0

            results.append({
                "method": method_name,
                "threshold": thresh,
                "n_flagged_non_drivable": int(n_flagged),
                "pct_of_dataset_flagged": round(100 * n_flagged / len(df), 1),
                "n_ambiguous_flipped_to_drivable": int(n_flipped),
                "pct_ambiguous_flipped": round(pct_flipped, 1),
            })

    results_df = pd.DataFrame(results)
    print("=== Results: method x threshold ===")
    print(results_df.to_string(index=False))

    results_summary_path = os.path.join(OUT_DIR, "roi_comparison_summary.csv")
    results_df.to_csv(results_summary_path, index=False)
    print(f"\nSaved summary to: {results_summary_path}")

    per_image_path = os.path.join(OUT_DIR, "roi_comparison_per_image.csv")
    df.to_csv(per_image_path, index=False)
    print(f"Saved per-image fractions to: {per_image_path}")

    # Highlight the number that actually answers the prof's question
    best_row = results_df.loc[results_df["pct_ambiguous_flipped"].idxmax()]
    print(f"\n=== Best result ===")
    print(f"Method: {best_row['method']}, threshold: {best_row['threshold']:.0%}")
    print(f"Flips {best_row['pct_ambiguous_flipped']:.1f}% of the {n_ambiguous} ambiguous cases to drivable.")
    if best_row["pct_ambiguous_flipped"] >= 70:
        print("-> Substantial improvement. Worth reporting as a preprocessing fix.")
    else:
        print("-> Not a substantial improvement. Document this finding and proceed to BDD100K.")

if __name__ == "__main__":
    main()
