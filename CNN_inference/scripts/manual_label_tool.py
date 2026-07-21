"""
Manual ground-truth labeling tool.

None of the methods (whole-image, bottom-half, ROI-1/2/3) have an
independent ground truth to be "accurate" against - they're all just
different ways of deriving a label from the same mask. So to compute
"classification accuracy" as your prof asked, you need a small sample
that YOU judge by eye, which then becomes the ground truth every
method gets scored against.

This opens each image in your default image viewer, asks you a simple
question in the terminal, and saves your answer. It's resumable - if
you close it partway through, re-running continues where you left off.

Usage: run it, look at each image as it opens, type d (drivable),
n (non-drivable), s (skip/unsure), or q (quit and save).

Recommended sample size: 100 images, mixing some of the 482 ambiguous
cases with some random ones, so the comparison isn't biased toward
only the hard cases.
"""

import os
import glob
import random
import subprocess
import sys
import pandas as pd

IMG_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\leftImg8bit\train"
OUT_DIR = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference"
OUTPUT_CSV = os.path.join(OUT_DIR, "manual_ground_truth_labels.csv")

# Point this at roi_comparison_per_image.csv (from roi_comparison.py) to
# sample from the ambiguous cases specifically. Leave as None to sample
# randomly from all images instead.
AMBIGUOUS_CSV = os.path.join(OUT_DIR, "roi_comparison_per_image.csv")

SAMPLE_SIZE = 100
N_FROM_AMBIGUOUS = 60   # rest (40) sampled randomly for balance

def find_all_image_ids(img_root):
    pattern = os.path.join(img_root, "**", "*_image.jpg")
    ids = []
    for img_path in glob.glob(pattern, recursive=True):
        img_id = os.path.basename(img_path).replace("_image.jpg", "")
        ids.append((img_id, img_path))
    return ids

def build_sample():
    all_pairs = find_all_image_ids(IMG_ROOT)
    all_ids = {img_id for img_id, _ in all_pairs}

    chosen_ids = set()

    if os.path.exists(AMBIGUOUS_CSV):
        amb_df = pd.read_csv(AMBIGUOUS_CSV)
        if "orig_ambiguous" in amb_df.columns:
            amb_ids = amb_df[amb_df["orig_ambiguous"]]["img_id"].astype(str).tolist()
            random.shuffle(amb_ids)
            chosen_ids.update(amb_ids[:N_FROM_AMBIGUOUS])
            print(f"Sampled {len(chosen_ids)} from ambiguous cases.")

    remaining_needed = SAMPLE_SIZE - len(chosen_ids)
    if remaining_needed > 0:
        pool = list(all_ids - chosen_ids)
        random.shuffle(pool)
        chosen_ids.update(pool[:remaining_needed])

    id_to_path = dict(all_pairs)
    sample = [(img_id, id_to_path[img_id]) for img_id in chosen_ids if img_id in id_to_path]
    random.shuffle(sample)  # don't show all ambiguous ones first, avoid bias
    return sample

def open_image(path):
    if sys.platform.startswith("win"):
        os.startfile(path)
    elif sys.platform == "darwin":
        subprocess.run(["open", path])
    else:
        subprocess.run(["xdg-open", path])

def main():
    if os.path.exists(OUTPUT_CSV):
        done_df = pd.read_csv(OUTPUT_CSV)
        done_ids = set(done_df["img_id"].astype(str).tolist())
        print(f"Resuming: {len(done_ids)} already labeled.")
    else:
        done_df = pd.DataFrame(columns=["img_id", "manual_label"])
        done_ids = set()

    sample = build_sample()
    remaining = [(img_id, path) for img_id, path in sample if img_id not in done_ids]
    print(f"{len(remaining)} images left to label out of {len(sample)} total sample.\n")
    print("For each image: d = drivable, n = non_drivable, s = skip, q = quit and save\n")

    new_rows = []
    for img_id, path in remaining:
        open_image(path)
        while True:
            ans = input(f"[{img_id}]  d/n/s/q > ").strip().lower()
            if ans in ("d", "n", "s", "q"):
                break
            print("  type d, n, s, or q")

        if ans == "q":
            break
        if ans == "s":
            continue

        label = "drivable" if ans == "d" else "non_drivable"
        new_rows.append({"img_id": img_id, "manual_label": label})

    if new_rows:
        combined = pd.concat([done_df, pd.DataFrame(new_rows)], ignore_index=True)
        combined.to_csv(OUTPUT_CSV, index=False)
        print(f"\nSaved {len(new_rows)} new labels. Total so far: {len(combined)}")
        print(f"File: {OUTPUT_CSV}")
    else:
        print("\nNo new labels added.")

if __name__ == "__main__":
    main()
