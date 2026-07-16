"""
Convert BDD100K YOLO detection dataset into an image
classification dataset.

Output:

BDD100K_Classification/
    train/
        person/
        rider/
        car/
        bus/
        truck/
        bike/
        motor/
    val/
        ...
"""

import os
import cv2
from tqdm import tqdm

# =====================================================
# PATHS
# =====================================================

YOLO_ROOT = r"C:\Users\nayak\Downloads\bdd100k-yolo"

OUTPUT_ROOT = r"C:\Users\nayak\Desktop\BDD100K_Classification"

# =====================================================
# CLASSES TO KEEP
# =====================================================

CLASS_NAMES = {
    0: "person",
    1: "rider",
    2: "car",
    3: "bus",
    4: "truck",
    5: "bike",
    6: "motor"
}

# =====================================================
# SETTINGS
# =====================================================

IMAGE_SIZE = 64

MIN_WIDTH = 30
MIN_HEIGHT = 30

# =====================================================

for split in ["train", "val"]:

    print(f"\nProcessing {split}...")

    image_dir = os.path.join(YOLO_ROOT, split, "images")
    label_dir = os.path.join(YOLO_ROOT, split, "labels")

    # create output folders
    for cls in CLASS_NAMES.values():
        os.makedirs(
            os.path.join(OUTPUT_ROOT, split, cls),
            exist_ok=True
        )

    saved = {cls: 0 for cls in CLASS_NAMES.values()}

    image_files = sorted(os.listdir(image_dir))

    for image_name in tqdm(image_files):

        image_path = os.path.join(image_dir, image_name)

        label_name = os.path.splitext(image_name)[0] + ".txt"
        label_path = os.path.join(label_dir, label_name)

        if not os.path.exists(label_path):
            continue

        image = cv2.imread(image_path)

        if image is None:
            continue

        H, W = image.shape[:2]

        with open(label_path) as f:
            lines = f.readlines()

        for line in lines:

            data = line.strip().split()

            if len(data) != 5:
                continue

            class_id = int(data[0])

            if class_id not in CLASS_NAMES:
                continue

            x = float(data[1])
            y = float(data[2])
            w = float(data[3])
            h = float(data[4])

            # Convert YOLO → pixels
            box_w = int(w * W)
            box_h = int(h * H)

            if box_w < MIN_WIDTH or box_h < MIN_HEIGHT:
                continue

            cx = x * W
            cy = y * H

            xmin = int(cx - box_w / 2)
            ymin = int(cy - box_h / 2)
            xmax = int(cx + box_w / 2)
            ymax = int(cy + box_h / 2)

            xmin = max(0, xmin)
            ymin = max(0, ymin)
            xmax = min(W, xmax)
            ymax = min(H, ymax)

            crop = image[ymin:ymax, xmin:xmax]

            if crop.size == 0:
                continue

            crop = cv2.resize(crop, (IMAGE_SIZE, IMAGE_SIZE))

            cls_name = CLASS_NAMES[class_id]

            save_name = f"{saved[cls_name]:07d}.jpg"

            save_path = os.path.join(
                OUTPUT_ROOT,
                split,
                cls_name,
                save_name
            )

            cv2.imwrite(save_path, crop)

            saved[cls_name] += 1

    print("\nSaved images:")

    for cls in CLASS_NAMES.values():
        print(f"{cls:10s}: {saved[cls]}")

print("\nDone!")