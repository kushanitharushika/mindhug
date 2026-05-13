from PIL import Image

def remove_white_bg(image_path, output_path, tolerance=200):
    img = Image.open(image_path)
    img = img.convert("RGBA")
    
    datas = img.getdata()
    
    newData = []
    for item in datas:
        # Check if the pixel is close to white
        if item[0] > tolerance and item[1] > tolerance and item[2] > tolerance:
            # Change to transparent
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)
            
    img.putdata(newData)
    img.save(output_path, "PNG")

remove_white_bg(
    r"c:\Users\ASUS\Desktop\mindhug\assets\images\MindHug Logo.jpeg",
    r"c:\Users\ASUS\Desktop\mindhug\assets\images\MindHug Logo.png",
    tolerance=230
)
print("Saved as MindHug Logo.png")
