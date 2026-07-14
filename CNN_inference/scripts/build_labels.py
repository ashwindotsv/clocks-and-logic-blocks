# ============================================================
# STAGE 1 (corrected): coarse labels from real AutoNUE level1Ids
# ============================================================
import os
import glob
import numpy as np
from PIL import Image
import pandas as pd

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Real level1Id groups, from AutoNUE/public-code anue_labels.py
DRIVABLE_IDS    = {0}        # road, parking, drivable fallback
OBSTRUCTION_IDS = {2, 3}     # living-things (person/animal/rider) + vehicles
IGNORE_ID       = 255        # unlabeled/void - exclude from fraction calcs

def get_coarse_label(mask_path):
    mask = np.array(Image.open(mask_path))

    valid_mask = mask[mask != IGNORE_ID]
    if valid_mask.size == 0:
        return None  # entire image is void - skip it

    total_valid = valid_mask.size
    obstruction_frac = np.isin(valid_mask, list(OBSTRUCTION_IDS)).sum() / total_valid

    if obstruction_frac > 0.03:
        return 1   # congested
    else:
        return 0   # clear road
    
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

            label = get_coarse_label(mask_path)
            if label is None:
                continue
            records.append({"img_path": img_path, "label": label})

    return pd.DataFrame(records)

train_df = build_label_table(
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/leftImg8bit/train",
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/gtFine/train"
)
val_df = build_label_table(
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/leftImg8bit/val",
    "C:/Users/nayak/Desktop/MSIS_Files/IDD_CNN_inference/idd20k_lite/gtFine/val"
)

print(f"Train: {len(train_df)}  Val: {len(val_df)}")
print(train_df["label"].value_counts())

# save next to this script's parent folder (CNN_inference/), regardless of
# where this script was launched from
train_df.to_csv(os.path.join(SCRIPT_DIR, "..", "idd_train_labels.csv"), index=False)
val_df.to_csv(os.path.join(SCRIPT_DIR, "..", "idd_val_labels.csv"), index=False)