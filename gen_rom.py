from PIL import Image


def image_to_bitmap(image_path, output_path):
    img = Image.open(image_path)
    img = img.convert('L')
    width, height = img.size
    with open(output_path, 'w') as f:
        for y in range(height):
            for x in range(width):
                pixel = img.getpixel((x, y))
                binary_pixel = '1' if pixel < 128 else '0'
                f.write(binary_pixel)
                if (x + 1) % 8 == 0:
                    f.write('\n')


if __name__ == "__main__":
    input_image = "image.png"
    output_file = "image.bin"
    image_to_bitmap(input_image, output_file)
