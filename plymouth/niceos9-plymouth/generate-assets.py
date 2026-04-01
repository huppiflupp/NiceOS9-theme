#!/usr/bin/env python3
"""
NiceOS 9 Plymouth Theme — Asset Generator
Generates all PNG assets needed by the Plymouth boot screen.

Run from the theme directory (or via install.sh).
Requires: Pillow  →  pip install Pillow  or  sudo dnf install python3-pillow
"""

import os
import sys
import math

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("ERROR: Pillow not found.")
    print("  Install with: pip install Pillow")
    print("  Or:           sudo dnf install python3-pillow")
    sys.exit(1)

THEME_DIR = os.path.dirname(os.path.abspath(__file__))
FONT_PATH = os.path.join(THEME_DIR, "../../fonts/ChicagoFLF.ttf")


def get_font(size):
    for path in [FONT_PATH,
                 "/usr/share/fonts/truetype/chicagoflf/ChicagoFLF.ttf",
                 "/usr/local/share/fonts/ChicagoFLF.ttf"]:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                pass
    # Fallback
    try:
        return ImageFont.truetype("/usr/share/fonts/dejavu-sans-fonts/DejaVuSans-Bold.ttf", size)
    except Exception:
        return ImageFont.load_default()


def save(img, name):
    path = os.path.join(THEME_DIR, name)
    img.save(path)
    print(f"  ✓  {name}")


# ─── 1. Happy Mac ────────────────────────────────────────────────────────────
# Authentic compact Mac shape (128k / Plus / SE style):
#   • Tall narrow body, nearly square CRT set high
#   • Wide chin below screen with floppy slot
#   • Gentle slope on top corners
#   • No separate stand — sits on its own flat base
def make_happy_mac():
    W, H = 180, 240
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)

    BODY      = (210, 206, 198)
    LIGHT     = (236, 232, 224)
    SHADE     = (165, 161, 153)
    EDGE      = (80, 80, 80)
    EDGE2     = (50, 50, 50)
    BLACK     = (18, 18, 18)
    WHITE     = (255, 255, 255)
    SCREEN_BG = (196, 193, 186)
    DARK_GRAY = (110, 108, 102)

    # ── Compact Mac body ──────────────────────────────────────────────────
    # Overall body: narrow (W=160) and tall (H=220), rounded top corners only
    bx, by, bw, bh = 10, 6, 160, 218
    r = 12   # radius for top corners only

    # Fill: main rect + top rounded corners
    d.rectangle([bx,     by + r, bx + bw, by + bh], fill=BODY)   # lower body
    d.rectangle([bx + r, by,     bx + bw - r, by + r], fill=BODY) # top strip
    d.ellipse(  [bx,             by, bx + r*2,     by + r*2],     fill=BODY)  # TL
    d.ellipse(  [bx + bw - r*2, by, bx + bw,       by + r*2],     fill=BODY)  # TR

    # Bevel: left + top highlight
    d.line([bx + 1, by + r, bx + 1, by + bh],      fill=LIGHT)
    d.line([bx + r, by + 1, bx + bw - r, by + 1],  fill=LIGHT)
    # Bevel: right + bottom shadow
    d.line([bx + bw - 1, by + r, bx + bw - 1, by + bh], fill=SHADE)
    d.line([bx + 1, by + bh - 1, bx + bw - 1, by + bh - 1], fill=SHADE)

    # Outer border
    d.rectangle([bx, by + r, bx + bw, by + bh], outline=EDGE)
    d.rectangle([bx + r, by, bx + bw - r, by + r], outline=EDGE)
    d.arc([bx, by, bx + r*2, by + r*2], 180, 270, fill=EDGE)
    d.arc([bx + bw - r*2, by, bx + bw, by + r*2], 270, 360, fill=EDGE)

    # ── Screen area (upper 55% of body) ──────────────────────────────────
    # Recessed bezel
    sx, sy = bx + 14, by + 18
    sw, sh = bw - 28, 108   # nearly square CRT
    d.rectangle([sx - 2, sy - 2, sx + sw + 2, sy + sh + 2],
                fill=(40, 40, 40), outline=EDGE2)
    # Screen glass (inset 3px)
    px, py = sx + 3, sy + 3
    pw, ph = sw - 6, sh - 6
    d.rectangle([px, py, px + pw, py + ph], fill=SCREEN_BG)
    # Screen top-left glare
    d.line([px, py, px + pw, py], fill=(210, 208, 202))
    d.line([px, py, px, py + ph], fill=(210, 208, 202))

    # ── Happy Mac face ────────────────────────────────────────────────────
    fcx = px + pw // 2
    fcy = py + ph // 2

    # Eyes: small filled rectangles with shine dot
    ew, eh = 8, 11
    eg = 13
    ey = fcy - 8
    for ex0 in [fcx - eg - ew, fcx + eg]:
        d.rectangle([ex0, ey - eh//2, ex0 + ew, ey + eh//2], fill=BLACK)
        d.rectangle([ex0 + 1, ey - eh//2 + 1, ex0 + 3, ey - eh//2 + 3], fill=WHITE)

    # Smile
    smw, smh = 40, 20
    smy = fcy + 6
    d.arc([fcx - smw//2, smy - smh//2, fcx + smw//2, smy + smh//2],
          10, 170, fill=BLACK, width=3)

    # Cheeks
    cheek = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cheek)
    cr = 6
    for chx in [fcx - eg - ew - cr - 3, fcx + eg + ew - cr + 3]:
        cd.ellipse([chx, smy - 4 - cr, chx + cr*2, smy - 4 + cr],
                   fill=(220, 100, 100, 72))
    img = Image.alpha_composite(img, cheek)
    d = ImageDraw.Draw(img)

    # ── Chin area (below screen) ──────────────────────────────────────────
    chin_y = sy + sh + 6   # just below bezel
    # Apple badge outline (small circle, decorative)
    badge_r = 5
    badge_x = bx + bw // 2
    badge_y = chin_y + 10
    d.ellipse([badge_x - badge_r, badge_y - badge_r,
               badge_x + badge_r, badge_y + badge_r],
              outline=DARK_GRAY)

    # Floppy drive slot
    fl_w, fl_h = 52, 5
    fl_x = bx + (bw - fl_w) // 2
    fl_y = by + bh - 40
    d.rectangle([fl_x, fl_y, fl_x + fl_w, fl_y + fl_h],
                fill=(50, 50, 50), outline=(30, 30, 30))
    # Slot highlight
    d.line([fl_x + 1, fl_y + 1, fl_x + fl_w - 1, fl_y + 1],
           fill=(80, 80, 80))

    # Power LED (tiny dot)
    led_x = bx + bw - 22
    led_y = fl_y + 1
    d.ellipse([led_x, led_y, led_x + 4, led_y + 4], fill=(0, 180, 0))

    # ── Flat base (integrated — no separate stand) ────────────────────────
    base_y = by + bh
    d.rectangle([bx + 4, base_y, bx + bw - 4, base_y + 10],
                fill=(195, 191, 183), outline=(120, 116, 108))
    d.line([bx + 6, base_y + 1, bx + bw - 6, base_y + 1], fill=LIGHT)

    save(img, "happy-mac.png")


# ─── 2. Progress bar track (322 × 20) ────────────────────────────────────────
def make_bar_track():
    W, H = 322, 20
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)
    d.rectangle([0, 0, W - 1, H - 1], outline=(75, 75, 75))
    d.rectangle([1, 1, W - 2, H - 2], outline=(148, 148, 148))
    d.rectangle([2, 2, W - 3, H - 3], fill=(255, 255, 255))
    d.line([2, 2, W - 3, 2], fill=(228, 226, 220))
    save(img, "bar-track.png")


# ─── 3. Candy-stripe fill (320 × 16) ─────────────────────────────────────────
def make_bar_stripe():
    W, H = 320, 16
    img = Image.new("RGB", (W, H), (0, 0, 170))
    d   = ImageDraw.Draw(img)
    stripe_color = (76, 76, 218)
    period = 14
    for x0 in range(-H, W + H, period):
        pts = [(x0, 0), (x0 + 7, 0), (x0 + 7 + H, H), (x0 + H, H)]
        d.polygon(pts, fill=stripe_color)
    d.line([0, 0, W - 1, 0], fill=(104, 104, 238))   # top highlight
    save(img, "bar-stripe.png")


# ─── 4. Platinum cover (1 × 16, scaled at runtime) ───────────────────────────
def make_bar_cover():
    img = Image.new("RGB", (1, 16), (196, 192, 184))
    save(img, "bar-cover.png")


# ─── 5. Welcome text ──────────────────────────────────────────────────────────
def make_welcome():
    text = "Welcome to NiceOS 9"
    font = get_font(26)
    tmp  = Image.new("RGBA", (1, 1))
    bb   = ImageDraw.Draw(tmp).textbbox((0, 0), text, font=font)
    tw, th = bb[2] - bb[0], bb[3] - bb[1]
    pad  = 6
    img  = Image.new("RGBA", (tw + pad * 2, th + pad * 2), (0, 0, 0, 0))
    d    = ImageDraw.Draw(img)
    # Subtle emboss shadow
    d.text((pad + 1, pad + 1), text, font=font, fill=(202, 198, 190))
    d.text((pad,     pad),     text, font=font, fill=(18, 18, 18))
    save(img, "welcome.png")


# ─── 6. Version label ─────────────────────────────────────────────────────────
def make_version():
    text = "NiceOS 9  ·  KDE Plasma 6"
    font = get_font(15)
    tmp  = Image.new("RGBA", (1, 1))
    bb   = ImageDraw.Draw(tmp).textbbox((0, 0), text, font=font)
    tw, th = bb[2] - bb[0], bb[3] - bb[1]
    pad  = 4
    img  = Image.new("RGBA", (tw + pad * 2, th + pad * 2), (0, 0, 0, 0))
    d    = ImageDraw.Draw(img)
    d.text((pad, pad), text, font=font, fill=(100, 96, 88))
    save(img, "version.png")


if __name__ == "__main__":
    print("Generating NiceOS 9 Plymouth assets …")
    make_happy_mac()
    make_bar_track()
    make_bar_stripe()
    make_bar_cover()
    make_welcome()
    make_version()
    print("Done — all assets generated.")
