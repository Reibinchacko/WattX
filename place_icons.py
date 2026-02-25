from PIL import Image
import os

def resize_and_place_icons():
    logo_path = "assets/wattx_logo.png"
    if not os.path.exists(logo_path):
        print(f"Error: {logo_path} not found.")
        return

    with Image.open(logo_path) as img:
        # Sizes for Android densities
        sizes = {
            "mipmap-mdpi": 48,
            "mipmap-hdpi": 72,
            "mipmap-xhdpi": 96,
            "mipmap-xxhdpi": 144,
            "mipmap-xxxhdpi": 192,
        }

        base_res_path = "android/app/src/main/res"
        
        for folder, size in sizes.items():
            target_path = os.path.join(base_res_path, folder, "ic_launcher.png")
            # Create directory if it doesn't exist
            os.makedirs(os.path.dirname(target_path), exist_ok=True)
            
            # Resize and save
            resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
            resized_img.save(target_path)
            print(f"Saved {size}x{size} to {target_path}")

if __name__ == "__main__":
    resize_and_place_icons()
