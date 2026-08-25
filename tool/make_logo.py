"""CoachBoard mark: clipboard (the board) + dumbbell + attendance checks."""

import os
from PIL import Image, ImageDraw, ImageFilter

BG = (10, 14, 12, 255)
LIME = (184, 245, 58, 255)
WHITE = (255, 255, 255, 255)
INK = (10, 14, 12, 255)
OUT = os.path.join(os.path.dirname(__file__), "..", "assets")
SIZE = 1024
SCALE = 4


def checkmark(d, cx, cy, r, fill):
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=fill)
    w = max(3, int(r * 0.22))
    d.line(
        [(cx - r * 0.42, cy + r * 0.02), (cx - r * 0.12, cy + r * 0.38), (cx + r * 0.46, cy - r * 0.36)],
        fill=LIME,
        width=w,
        joint="curve",
    )


def dumbbell(d, cx, cy, scale, fill):
    bar_w, bar_h = scale * 0.38, scale * 0.068
    r = scale * 0.088
    d.rounded_rectangle(
        (cx - bar_w / 2, cy - bar_h / 2, cx + bar_w / 2, cy + bar_h / 2),
        radius=bar_h / 2,
        fill=fill,
    )
    for side in (-1.0, 1.0):
        px = cx + side * (bar_w / 2 + r * 0.12)
        d.ellipse((px - r, cy - r, px + r, cy + r), fill=fill)


def paint(size):
    img = Image.new("RGBA", (size, size), BG)
    d = ImageDraw.Draw(img)
    s = float(size)
    cx = s / 2

    board = (s * 0.18, s * 0.20, s * 0.82, s * 0.88)
    d.rounded_rectangle(board, radius=s * 0.08, fill=LIME)

    clip_w, clip_h = s * 0.26, s * 0.13
    clip = (cx - clip_w / 2, s * 0.105, cx + clip_w / 2, s * 0.105 + clip_h)
    d.rounded_rectangle(clip, radius=s * 0.035, fill=WHITE)
    hole_r = s * 0.028
    hy = s * 0.105 + clip_h * 0.42
    d.ellipse((cx - hole_r, hy - hole_r, cx + hole_r, hy + hole_r), fill=BG)

    dumbbell(d, cx, s * 0.42, s, INK)

    row_x = s * 0.30
    line_r = s * 0.76
    for i, y in enumerate((s * 0.62, s * 0.74)):
        checkmark(d, row_x, y, s * 0.048, INK)
        d.rounded_rectangle(
            (s * 0.38, y - s * 0.018, line_r, y + s * 0.018),
            radius=s * 0.018,
            fill=INK if i == 0 else (22, 40, 18, 255),
        )

    return img


def downsample(mark, out_size):
    return mark.resize((out_size, out_size), Image.Resampling.LANCZOS).filter(
        ImageFilter.UnsharpMask(radius=1.0, percent=60, threshold=2)
    )


def padded(mark, ratio=0.92):
    size = mark.width
    canvas = Image.new("RGBA", (size, size), BG)
    inner = int(size * ratio)
    resized = mark.resize((inner, inner), Image.Resampling.LANCZOS)
    canvas.paste(resized, ((size - inner) // 2, (size - inner) // 2), resized)
    return canvas


def main():
    os.makedirs(OUT, exist_ok=True)
    mark = downsample(paint(SIZE * SCALE), SIZE)
    mark.save(os.path.join(OUT, "logo.png"))
    padded(mark).save(os.path.join(OUT, "logo_padded.png"))
    print("wrote logo")


if __name__ == "__main__":
    main()
