import numpy as np

patch = np.array([[10,20,30],[40,50,60],[70,80,90]]) # Define the 3x3 patch of pixel values

identity_kernel = np.array([[0,0,0],[0,1,0],[0,0,0]])
sobel_kernel_x= np.array([[-1,0,1],[-2,0,2],[-1,0,1]])
sobel_kernel_y = np.array([[-1,-2,-1],[0,0,0],[1,2,1]])
blur_kernel = np.array([[1/9,1/9,1/9],[1/9,1/9,1/9],[1/9,1/9,1/9]])
laplacian_kernel = np.array([[0,1,0],[1,-4,1],[0,1,0]])
sharp_kernel = np.array([[0,-1,0],[-1,5,-1],[0,-1,0]])
gaussian_kernel = np.array([[1/16,1/8,1/16],[1/8,1/4,1/8],[1/16,1/8,1/16]]) # Define the convolution kernels

conv_result_I = np.zeros_like(patch) 
conv_result_SX = np.zeros_like(patch) 
conv_result_SY = np.zeros_like(patch) 
conv_result_L = np.zeros_like(patch) 
conv_result_SH = np.zeros_like(patch) 
conv_result_G = np.zeros_like(patch) 
conv_result_B = np.zeros_like(patch) # Create empty arrays to store the convolution result   

conv_result_I = np.sum(patch * identity_kernel) 
conv_result_SX = np.sum(patch * sobel_kernel_x) 
conv_result_SY = np.sum(patch * sobel_kernel_y) 
conv_result_L = np.sum(patch * laplacian_kernel) 
conv_result_SH = np.sum(patch * sharp_kernel) 
conv_result_G = np.sum(patch * gaussian_kernel) 
conv_result_B = np.sum(patch * blur_kernel) # Calculate the convolution results

print("Convolution result for Identity kernel:", conv_result_I)
print("Convolution result for Sobel X kernel:", conv_result_SX) 
print("Convolution result for Sobel Y kernel:", conv_result_SY)
print("Convolution result for Laplacian kernel:", conv_result_L)
print("Convolution result for Sharp kernel:", conv_result_SH)
print("Convolution result for Gaussian kernel:", conv_result_G*16)
print("Convolution result for Blur kernel:", conv_result_B*9) # print the results


"""
sel = int(input("Select the kernel to apply \n 1: Identity\n 2: Sobel X\n 3: Sobel Y\n 4: Laplacian\n 5: Sharp\n 6: Gaussian\n 7: Blur\n "))
if sel == 1:
    kernel = identity_kernel
elif sel == 2:
    kernel = sobel_kernel_x
elif sel == 3:
    kernel = sobel_kernel_y
elif sel == 4:
    kernel = laplacian_kernel
elif sel == 5:
    kernel = sharp_kernel
elif sel == 6:
    kernel = gaussian_kernel
elif sel == 7:
    kernel = blur_kernel
else:    
    print("Invalid selection.")
    kernel = identity_kernel

#perform convolution
conv_result = np.sum(patch * kernel) # Calculate the convolution result by summing the element-wise product of the patch and the selected kernel
print("Convolution result:", conv_result)
"""
