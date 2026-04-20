import cv2
import numpy as np

# Load the image
img = cv2.imread(r"c:\Users\ASUS\Desktop\mindhug\assets\images\MindHug Logo.jpeg")

# Convert to RGBA
rgba = cv2.cvtColor(img, cv2.COLOR_BGR2BGRA)

# Define white color range
lower_white = np.array([200, 200, 200, 255])
upper_white = np.array([255, 255, 255, 255])

# Create a mask for white pixels
mask = cv2.inRange(rgba, lower_white, upper_white)

# Apply transparency to white pixels
rgba[mask > 0] = [0, 0, 0, 0]

# Save as PNG
cv2.imwrite(r"c:\Users\ASUS\Desktop\mindhug\assets\images\MindHug Logo.png", rgba)
print("Saved as MindHug Logo.png")
