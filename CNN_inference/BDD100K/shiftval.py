import os
import shutil
from tqdm import tqdm

SOURCE_ROOT = r"C:\Users\nayak\Desktop\BDD100K_Classification\val"
DEST_ROOT   = r"C:\Users\nayak\Desktop\BDD100K_Balanced\val"

CLASSES = ["car", "person", "truck", "bus", "bike", "rider", "motor"]

os.makedirs(DEST_ROOT, exist_ok=True)
print("Copying val dataset (untouched distribution)...\n")

for class_name in CLASSES:
    source_dir = os.path.join(SOURCE_ROOT, class_name)
    dest_dir = os.path.join(DEST_ROOT, class_name)
    os.makedirs(dest_dir, exist_ok=True)

    files = [
        f for f in os.listdir(source_dir)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    ]

    for fname in tqdm(files, desc=class_name):
        shutil.copy2(os.path.join(source_dir, fname), os.path.join(dest_dir, fname))

    print(f"{class_name:8s}: {len(files):6d}")

print("\nVal dataset copied successfully!")