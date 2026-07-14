import os
import glob
import numpy as np
from PIL import Image

ROOT = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference\idd20k_lite\gtFine_6class"

mask_path = glob.glob(os.path.join(ROOT, "**", "*_label.png"), recursive=True)[0]

print("Checking:", mask_path)

mask = np.array(Image.open(mask_path))

print("Unique labels:", np.unique(mask))
