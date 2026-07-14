"""
remap_masks.py

Converts IDD Lite semantic masks into a 6-class label set.

Original IDD Lite labels:
0   -> Drivable
1   -> Non-drivable
2   -> Living Things
3   -> Vehicles
4   -> Roadside Objects
5   -> Far Objects
6   -> Sky
255 -> Ignore/Void

Remapped labels:
0   -> Drivable
1   -> Non-drivable
2   -> Living Things
3   -> Vehicles
4   -> Roadside Objects
5   -> Far Objects
255 -> Ignore (Sky + Void)
"""

import os
import numpy as np
from PIL import Image

# ==========================================================
# Paths
# ==========================================================

INPUT_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\gtFine"

OUTPUT_ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\gtFine_6class"

# ==========================================================
# Label Mapping
# ==========================================================

LABEL_MAP = {
    0: 0,      # Drivable
    1: 1,      # Non-drivable
    2: 2,      # Living Things
    3: 3,      # Vehicles
    4: 4,      # Roadside Objects
    5: 5,      # Far Objects
    6: 255,    # Sky -> Ignore
    255: 255   # Ignore/Void
}

# ==========================================================
# Remap semantic masks
# ==========================================================

num_masks = 0

for root, _, files in os.walk(INPUT_ROOT):

    relative_path = os.path.relpath(root, INPUT_ROOT)
    output_dir = os.path.join(OUTPUT_ROOT, relative_path)
    os.makedirs(output_dir, exist_ok=True)

    for filename in files:

        # --------------------------------------------------
        # Only semantic masks
        # Skip instance masks
        # --------------------------------------------------

        if not filename.endswith("_label.png"):
            continue

        input_path = os.path.join(root, filename)
        output_path = os.path.join(output_dir, filename)

        mask = np.array(Image.open(input_path))

        remapped = np.full(mask.shape, 255, dtype=np.uint8)

        for old_label, new_label in LABEL_MAP.items():
            remapped[mask == old_label] = new_label

        Image.fromarray(remapped).save(output_path)

        num_masks += 1

print("=" * 60)
print("IDD Lite Mask Remapping Complete")
print("=" * 60)
print(f"Semantic masks processed : {num_masks}")
print(f"Output directory         : {OUTPUT_ROOT}")
print("Ignored labels           : Sky (6), Void (255)")
print("=" * 60)