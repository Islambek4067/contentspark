from PIL import Image, ImageDraw
import math

size = 1024
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

def draw_star(draw, x, y, r_out, r_in, points=4, fill='white'):
    coords = []
    for i in range(points * 2):
        angle = i * math.pi / points - math.pi / 2
        r = r_out if i % 2 == 0 else r_in
        coords.append((x + r * math.cos(angle), y + r * math.sin(angle)))
    draw.polygon(coords, fill=fill)

# Center main star
draw_star(draw, 460, 560, 280, 80, 4, 'white')
# Top right star
draw_star(draw, 780, 300, 140, 40, 4, 'white')
# Top left smaller star
draw_star(draw, 260, 280, 100, 30, 4, 'white')

img.save('assets/icon/foreground.png')

# Gradient background
def create_gradient(size, c1, c2):
    base = Image.new('RGB', (size, size), c1)
    top = Image.new('RGB', (size, size), c2)
    mask = Image.new('L', (size, size))
    mask_data = []
    for y in range(size):
        for x in range(size):
            val = int(255 * (x + y) / (2 * size))
            mask_data.append(val)
    mask.putdata(mask_data)
    base.paste(top, (0, 0), mask)
    return base

# From AppColors.primary (79, 70, 229) to AppColors.accent (6, 182, 212)
bg = create_gradient(1024, (79, 70, 229), (6, 182, 212))
bg.save('assets/icon/background.png')

# Combined
combined = bg.copy()
combined.paste(img, (0, 0), img)
combined.save('assets/icon/app_icon.png')
