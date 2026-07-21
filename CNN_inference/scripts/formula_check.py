"""
Checks how much it actually matters whether we exclude IGNORE_ID (255)
pixels from the denominator or not, using the prof's exact ROI
(x: 30-70%, y: 60-100% -> this is "roi_1" in roi_comparison.py).

Computes both versions per image:
  - valid_only:  matches roi_comparison.py (excludes 255 before dividing)
  - raw_literal: matches the prof's snippet exactly (divides by roi.size,
                 no exclusion)

Then reports how often the resulting non_drivable label (at each
threshold) actually flips between the two versions. If it's 0 or
near-0, the difference is a non-issue and you can say so confidently
in your understanding of the code. If it's meaningful, you'll see
exactly how many images are affected.
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

# prof's exact ROI: y 60-100%, x 30-70%
X0, X1, Y0, Y1 = 0.30, 0.70, 0.60, 1.0

THRESHOLDS = [0.05, 0.10, 0.15, 0.20]

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
    print(f"Checking {len(pairs)} images on prof's exact ROI (x:30-70%, y:60-100%)...\n")

    records = []
    for img_path, mask_path, img_id in pairs:
        mask = np.array(Image.open(mask_path))
        H, W = mask.shape
        roi = mask[int(Y0 * H):int(Y1 * H), int(X0 * W):int(X1 * W)]

        # prof's literal formula: divide by every pixel in the crop
        raw_literal = np.sum(roi == NON_DRIVABLE_ID) / roi.size

        # your (my) version: exclude ignore pixels first
        valid = roi[roi != IGNORE_ID]
        valid_only = (valid == NON_DRIVABLE_ID).sum() / valid.size if valid.size > 0 else 0.0

        # how many void pixels are actually in this crop
        pct_void_in_roi = 100 * (roi == IGNORE_ID).sum() / roi.size

        records.append({
            "img_id": img_id,
            "raw_literal": raw_literal,
            "valid_only": valid_only,
            "pct_void_in_roi": pct_void_in_roi,
        })

    df = pd.DataFrame(records)

    print(f"Average % of ROI pixels that are void/ignore (255): {df['pct_void_in_roi'].mean():.2f}%")
    print(f"Max % void in any single image's ROI: {df['pct_void_in_roi'].max():.2f}%\n")

    print("=== Label flips between the two formulas, per threshold ===")
    for thresh in THRESHOLDS:
        label_raw = df["raw_literal"] > thresh
        label_valid = df["valid_only"] > thresh
        n_flips = (label_raw != label_valid).sum()
        print(f"threshold {thresh:.0%}: {n_flips} / {len(df)} images get a different label "
              f"({100*n_flips/len(df):.2f}%)")

    out_path = os.path.join(OUT_DIR, "formula_comparison.csv")
    df.to_csv(out_path, index=False)
    print(f"\nSaved per-image comparison to: {out_path}")

if __name__ == "__main__":
    main()