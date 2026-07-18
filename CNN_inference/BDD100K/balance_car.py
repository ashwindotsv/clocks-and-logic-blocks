import os
import random
import shutil

# =====================================================
# CONFIGURATION
# =====================================================

random.seed(42)

SOURCE_ROOT = r"C:\Users\nayak\Desktop\BDD100K_Classification\train"
DEST_ROOT   = r"C:\Users\nayak\Desktop\BDD100K_Balanced\train"

# Maximum images to keep for each class
MAX_IMAGES = {
    "car": 27000,      # undersample
    "person": None,    # keep all
    "truck": None,
    "bus": None,
    "bike": None,
    "rider": None,
    "motor": None,
}

# =====================================================

os.makedirs(DEST_ROOT, exist_ok=True)

print("Creating balanced dataset...\n")

for class_name, max_count in MAX_IMAGES.items():

    source_dir = os.path.join(SOURCE_ROOT, class_name)
    dest_dir = os.path.join(DEST_ROOT, class_name)

    os.makedirs(dest_dir, exist_ok=True)

    files = [
        f for f in os.listdir(source_dir)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    ]

    total = len(files)

    # Keep all images
    if max_count is None or max_count >= total:
        selected = files

    # Randomly sample
    else:
        selected = random.sample(files, max_count)

    for fname in selected:
        shutil.copy2(
            os.path.join(source_dir, fname),
            os.path.join(dest_dir, fname)
        )

    print(f"{class_name:8s}: {len(selected):6d} / {total:6d}")

print("\nBalanced dataset created successfully!")
print(f"\nLocation:\n{DEST_ROOT}")