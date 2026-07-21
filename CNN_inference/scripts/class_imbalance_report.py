"""
Consolidated class imbalance report for the prof's diagnostic.

Produces ONE table showing, per category:
  - raw pixel-level presence (from the ground truth mask directly)
  - your derived whole-image flag (from the threshold logic)

Putting these side by side is the point: if your flag's percentage is
way higher than the raw pixel presence percentage, that's evidence
the threshold is over-firing (root cause ii), not that the dataset
itself is imbalanced (root cause i).

Also prints the exact drivable / non_drivable / vehicle / pedestrian
counts your prof asked for by name. ("pedestrian" here = your
living_thing_present, which is person+rider+animal combined - noted
explicitly in the output so this doesn't need explaining twice.)
"""

import os
import glob
import numpy as np
import pandas as pd
from PIL import Image

GT_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\gtFine\train"
IMG_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\leftImg8bit\train"

LEVEL1_CATEGORIES = {
    "drivable":      0,
    "non_drivable":  1,
    "living_thing":  2,   # prof's "pedestrian" = this (person + rider + animal)
    "vehicle":       3,
    "roadside_obj":  4,
    "far_objects":   5,
}

# thresholds matched to your existing Stage 1 script
FLAG_THRESHOLDS = {
    "vehicle_present":      ("vehicle", 0.02),
    "non_drivable_present": ("non_drivable", 0.01),
    "living_thing_present": ("living_thing", 0.02),
}

IGNORE_ID = 255

def find_semantic_masks(gt_root):
    pattern = os.path.join(gt_root, "**", "*_label.png")
    all_matches = glob.glob(pattern, recursive=True)
    return sorted(p for p in all_matches if "_inst_label.png" not in os.path.basename(p))

def main():
    mask_paths = find_semantic_masks(GT_ROOT)
    print(f"Scanning {len(mask_paths)} masks...\n")

    # raw pixel-level presence counts (image "contains this category at all", any nonzero pixel)
    raw_presence_any = {name: 0 for name in LEVEL1_CATEGORIES}
    # raw pixel-level presence at >2% threshold (matches your Script 3 logic)
    raw_presence_2pct = {name: 0 for name in LEVEL1_CATEGORIES}
    # your derived flags
    derived_flags = {flag: 0 for flag in FLAG_THRESHOLDS}

    total = 0
    for mask_path in mask_paths:
        mask = np.array(Image.open(mask_path))
        valid = mask[mask != IGNORE_ID]
        if valid.size == 0:
            continue
        total += 1

        for name, level1_id in LEVEL1_CATEGORIES.items():
            frac = (valid == level1_id).sum() / valid.size
            if frac > 0:
                raw_presence_any[name] += 1
            if frac > 0.02:
                raw_presence_2pct[name] += 1

        for flag_name, (cat_name, thresh) in FLAG_THRESHOLDS.items():
            frac = (valid == LEVEL1_CATEGORIES[cat_name]).sum() / valid.size
            if frac > thresh:
                derived_flags[flag_name] += 1

    print(f"Total valid images: {total}\n")

    print("=== Raw ground-truth pixel presence (from mask directly, no threshold logic) ===")
    print(f"{'category':15s} {'any pixel':>12s} {'>2% of frame':>14s}")
    for name in LEVEL1_CATEGORIES:
        any_pct = 100 * raw_presence_any[name] / total
        pct2 = 100 * raw_presence_2pct[name] / total
        print(f"{name:15s} {raw_presence_any[name]:>6d} ({any_pct:5.1f}%) {raw_presence_2pct[name]:>8d} ({pct2:5.1f}%)")

    print("\n=== Your derived whole-image flags (label-generation script thresholds) ===")
    for flag_name, (cat_name, thresh) in FLAG_THRESHOLDS.items():
        count = derived_flags[flag_name]
        pct = 100 * count / total
        print(f"{flag_name:22s} (threshold {thresh:.2%} of {cat_name}): {count} / {total} ({pct:.1f}%)")

    print("\n=== Interpretation ===")
    nd_any = 100 * raw_presence_any["non_drivable"] / total
    nd_flag = 100 * derived_flags["non_drivable_present"] / total
    print(f"non_drivable: present in {nd_any:.1f}% of images at ANY pixel level,")
    print(f"              but flagged non_drivable_present in {nd_flag:.1f}% of images.")
    print("If these two numbers are close, a small non-drivable sliver anywhere in")
    print("frame is enough to flag the whole image -> this is a thresholding/design")
    print("issue in the label-generation script, not a ground-truth annotation error.")

    # Save table for the report
    rows = []
    for name in LEVEL1_CATEGORIES:
        rows.append({
            "category": name,
            "raw_any_pixel_count": raw_presence_any[name],
            "raw_any_pixel_pct": round(100 * raw_presence_any[name] / total, 1),
            "raw_2pct_count": raw_presence_2pct[name],
            "raw_2pct_pct": round(100 * raw_presence_2pct[name] / total, 1),
        })
    df = pd.DataFrame(rows)
    out_path = os.path.join(os.path.dirname(GT_ROOT), "..", "class_imbalance_report.csv")
    out_path = os.path.abspath(out_path)
    df.to_csv(out_path, index=False)
    print(f"\nSaved table to: {out_path}")

if __name__ == "__main__":
    main()
