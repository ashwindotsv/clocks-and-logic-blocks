"""
Verify mask encoding across the ENTIRE IDD Lite train set.

Fixes a bug from the earlier one-off check: glob("*_label.png") also
matches "*_inst_label.png" (since that filename ends in "_label.png"
too), so the earlier check silently read an instance mask instead of
the semantic level1Id mask. This version targets "{id}_label.png"
exactly, and scans every image, not just the first one found.

Run this BEFORE trusting any counts from the label-generation script.
If this fails (unexpected values show up), the label-generation
script is reading the wrong file or the mask encoding assumption is
wrong -> that's a root-cause (ii) finding, not a dataset flaw.
"""

import os
import glob
import numpy as np
from PIL import Image
from collections import Counter

# =====================================================
# EDIT THIS if your gtFine root differs
# =====================================================
GT_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\gtFine\train"

EXPECTED_VALUES = {0, 1, 2, 3, 4, 5, 255}  # level1Id 0-5 + ignore

def find_semantic_masks(gt_root):
    """
    Match exactly '<digits>_label.png', never '<digits>_inst_label.png'.
    Using the numeric id directly is unambiguous, unlike a wildcard.
    """
    pattern = os.path.join(gt_root, "**", "*_label.png")
    all_matches = glob.glob(pattern, recursive=True)
    # Explicitly drop anything that is an instance mask
    semantic_only = [p for p in all_matches if "_inst_label.png" not in os.path.basename(p)]
    return sorted(semantic_only)

def main():
    mask_paths = find_semantic_masks(GT_ROOT)
    print(f"Found {len(mask_paths)} semantic label masks under:\n  {GT_ROOT}\n")

    if len(mask_paths) == 0:
        print("No masks found - check GT_ROOT path.")
        return

    global_value_counts = Counter()
    unexpected_files = []

    for i, mask_path in enumerate(mask_paths):
        mask = np.array(Image.open(mask_path))
        unique_vals = set(np.unique(mask).tolist())

        global_value_counts.update(unique_vals)

        leftover = unique_vals - EXPECTED_VALUES
        if leftover:
            unexpected_files.append((mask_path, sorted(leftover)))

        if (i + 1) % 500 == 0:
            print(f"  scanned {i+1}/{len(mask_paths)}...")

    print("\n=== Value distribution across ALL masks (how many images contain each value) ===")
    for val in sorted(global_value_counts.keys()):
        print(f"  value {val:>3}: present in {global_value_counts[val]} images")

    print(f"\n=== Unexpected values check ===")
    if not unexpected_files:
        print("PASS: every mask only contains values from {0,1,2,3,4,5,255}.")
        print("Mask encoding is confirmed as level1Id across the full train set.")
    else:
        print(f"FAIL: {len(unexpected_files)} masks contain values outside level1Id range.")
        print("This means some masks are NOT level1Id-encoded (likely raw AutoNUE 'id' scheme).")
        print("First 10 offending files:")
        for path, leftover in unexpected_files[:10]:
            print(f"  {path}  ->  unexpected values: {leftover}")

if __name__ == "__main__":
    main()
