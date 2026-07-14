# ============================================================
# STAGE 1 (multi-label): 3 road-element categories from
# AutoNUE level1Id masks in IDD Lite
# ============================================================
import os
import glob
import numpy as np
from PIL import Image
import pandas as pd

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Final 3 categories, chosen after checking real frequency in the dataset
LEVEL1_CATEGORIES = {
    "vehicle_present":      3,   # car, bus, truck, motorcycle, bicycle, autorickshaw, etc.
    "non_drivable_present": 1,   # sidewalk, rail track, non-drivable fallback
    "living_thing_present": 2,   # person, animal, rider
}

IGNORE_ID = 255          # unlabeled/void pixels - excluded from fraction calcs
MIN_PIXEL_FRAC = 0.02    # a category counts as "present" if it covers >2% of the image

def get_multi_labels(mask_path):
    mask = np.array(Image.open(mask_path))

    valid_mask = mask[mask != IGNORE_ID]
    if valid_mask.size == 0:
        return None

    total_valid = valid_mask.size

    vehicle_frac      = (valid_mask == LEVEL1_CATEGORIES["vehicle_present"]).sum() / total_valid
    non_drivable_frac = (valid_mask == LEVEL1_CATEGORIES["non_drivable_present"]).sum() / total_valid
    living_thing_frac = (valid_mask == LEVEL1_CATEGORIES["living_thing_present"]).sum() / total_valid

    return {
        "vehicle_present":      int(vehicle_frac > 0.02),       # unchanged
        "non_drivable_present": int(non_drivable_frac > 0.01),  # lowered from 0.02
        "living_thing_present": int(living_thing_frac > 0.02),  # unchanged
    }

def build_label_table(img_root, mask_root):
    records = []
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

            labels = get_multi_labels(mask_path)
            if labels is None:
                continue

            record = {"img_path": img_path}
            record.update(labels)   # adds vehicle_present, non_drivable_present, living_thing_present as columns
            records.append(record)

    return pd.DataFrame(records)

train_df = build_label_table(
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/leftImg8bit/train",
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/gtFine/train"
)
val_df = build_label_table(
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/leftImg8bit/val",
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/gtFine/val"
)

print(f"Train: {len(train_df)}  Val: {len(val_df)}\n")

# Print how often each category is present, individually
for col in ["vehicle_present", "non_drivable_present", "living_thing_present"]:
    pct = 100 * train_df[col].mean()
    print(f"{col}: {train_df[col].sum()} / {len(train_df)}  ({pct:.1f}%)")

train_df.to_csv(os.path.join(SCRIPT_DIR, "..", "idd_train_labels.csv"), index=False)
val_df.to_csv(os.path.join(SCRIPT_DIR, "..", "idd_val_labels.csv"), index=False)