import numpy as np
from PIL import Image

mask = np.array(Image.open(r"PATH_TO_ONE_REMAPPED_MASK.png"))

print(np.unique(mask))