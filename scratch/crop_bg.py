from PIL import Image

img = Image.open(r"c:\Users\ASUS\Desktop\mindhug\assets\images\MindHug Logo.png")
bbox = img.getbbox()
print(f"Original size: {img.size}")
print(f"Bounding box of non-transparent pixels: {bbox}")

# Crop and save it
if bbox:
    cropped = img.crop(bbox)
    cropped.save(r"c:\Users\ASUS\Desktop\mindhug\assets\images\MindHug Logo_cropped.png")
    print("Saved cropped image")
