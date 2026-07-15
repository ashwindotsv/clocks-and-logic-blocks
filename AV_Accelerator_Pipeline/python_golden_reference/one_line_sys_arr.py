import numpy as np

# The entire systolic array + Conv_Adder in one line
kernel, pixels = np.array([[1,2,3],[4,5,6],[7,8,9]]), np.array([[9,8,7],[6,5,4],[3,2,1]])
result = np.sum(np.sum(kernel * pixels, axis=0))  # Vertical sum + Conv_Adder

print(f"Convolution result: {result}")
print(f"Partial sums: {np.sum(kernel * pixels, axis=0)}")
print(f"True result: {np.sum(kernel * pixels)}")