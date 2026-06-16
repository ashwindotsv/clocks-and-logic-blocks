import cv2 #import the OpenCV library

#TASK-1
img = cv2.imread('jerry.jpg')# Read an image
cv2.imshow('Jerry', img) # Display the image in a window named 'Jerry'
cv2.waitKey(3000) # Wait for 30 seconds
cv2.destroyAllWindows() # Close all windows

#TASK-2
gray=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)#convert the image to grayscale
cv2.imshow('gray image of jerry',gray) # Display the grayscale image in a window called 'gray image of jerry'
cv2.waitKey(3000) # Wait for 30 seconds


#TASK-3
edges = cv2.Canny(gray, 100, 200)#perform edge detection using Canny algorithm
cv2.imshow('Edges of Jerry', edges) # Display the edges in window called 'Edges of Jerry'
cv2.waitKey(3000) # Wait for 30 seconds
cv2.destroyAllWindows() # Close all windows

cv2.imshow('edges', gray) 
cv2.waitKey(0)