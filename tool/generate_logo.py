#!/usr/bin/env python3
"""Punch navy out of assets/logo.png for Android adaptive foreground."""
from PIL import Image

src = Image.open('assets/logo.png').convert('RGBA')
px = src.load()
w, h = src.size
for y in range(h):
    for x in range(w):
        r, g, b, a = px[x, y]
        if b > r + 20 and b > g and r < 70 and g < 90 and b < 140:
            px[x, y] = (r, g, b, 0)
src.save('assets/icon_foreground.png')
print('wrote assets/icon_foreground.png', src.size)
