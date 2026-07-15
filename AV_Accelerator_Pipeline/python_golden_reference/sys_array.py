import numpy as np
from scipy.signal import correlate2d

# ... (WeightStationarySystolic3x3 class and full_convolution() unchanged) ...

class WeightStationarySystolic3x3:
    def __init__(self):
        self.weights = np.zeros((3, 3), dtype=np.float32)
        self.pe = np.zeros((3, 3), dtype=np.float32)

    def load_weights(self, kernel):
        self.weights = kernel.astype(np.float32)
        self.pe = np.zeros((3, 3), dtype=np.float32)

    def stream_pixels(self, pixels):
        self.pe = np.zeros((3, 3), dtype=np.float32)
        for i in range(3):
            for j in range(3):
                psum_from_above = 0 if i == 0 else self.pe[i-1, j]
                self.pe[i, j] = self.weights[i, j] * pixels[i, j] + psum_from_above
        partial_sums = self.pe[2, :].copy()
        result = np.sum(partial_sums)
        return result, partial_sums


def full_convolution(image, kernel):
    h, w = image.shape
    output = np.zeros((h-2, w-2))
    for i in range(h-2):
        for j in range(w-2):
            patch = image[i:i+3, j:j+3]
            systolic = WeightStationarySystolic3x3()
            systolic.load_weights(kernel)
            result, _ = systolic.stream_pixels(patch)
            output[i, j] = result
    return output


# === FIXED VERIFICATION SECTION ===

np.random.seed(42)
image = np.random.randn(5, 5)
kernel = np.array([[1, 0, -1],
                    [2, 0, -2],
                    [1, 0, -1]], dtype=float)

result = full_convolution(image, kernel)

print("Image (5x5):\n", image)
print("\nKernel:\n", kernel)
print("\nHardware-model Output (3x3):\n", result)

# FIX 1: correlate2d instead of convolve2d -> matches hardware's
# no-kernel-flip behavior (cross-correlation), not textbook convolution.
true_result = correlate2d(image, kernel, mode='valid')
print("\nGolden reference (scipy correlate2d):\n", true_result)

# FIX 2: actually check closeness instead of unconditionally printing a checkmark
max_diff = np.max(np.abs(result - true_result))
if np.allclose(result, true_result, atol=1e-6):
    print(f"\n✅ Match! Max diff: {max_diff:.2e}")
else:
    print(f"\n❌ Mismatch! Max diff: {max_diff:.2e}")