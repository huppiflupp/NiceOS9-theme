#!/usr/bin/env python3
"""
NiceOS 9 GRUB Theme — Asset Generator
Generates all PNG assets needed by the GRUB boot screen.

Run from the theme directory (or via install.sh).
Requires: Pillow  →  pip install Pillow  or  sudo dnf install python3-pillow
"""

import os
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("ERROR: Pillow not found.")
    print("  Install with: pip install Pillow")
    print("  Or:           sudo dnf install python3-pillow")
    sys.exit(1)

THEME_DIR = os.path.dirname(os.path.abspath(__file__))
FONT_PATH  = os.path.join(THEME_DIR, "../../fonts/ChicagoFLF.ttf")

# ── Palette ───────────────────────────────────────────────────────────────────
C_DARK   = ( 42,  42,  42)   # outer border
C_HL     = (220, 216, 208)   # bevel highlight (inner top/left)
C_W_HL   = (248, 244, 236)   # bevel highlight inner (nearest content)
C_SH     = (148, 144, 136)   # bevel shadow (inner bottom/right)
C_W_SH   = (188, 184, 176)   # bevel shadow inner
C_WHITE  = (255, 255, 255)   # menu content background
C_BLUE   = (  0,  85, 170)   # Mac OS classic selection blue (#0055AA)
C_PLAT   = (196, 192, 184)   # platinum mid
C_MENUBAR= (212, 210, 204)   # menu bar gray
C_BLACK  = ( 18,  18,  18)   # near-black text
C_TEXT_D = ( 88,  84,  76)   # dimmed text


def get_font(size):
    for path in [FONT_PATH,
                 "/usr/share/fonts/truetype/chicagoflf/ChicagoFLF.ttf",
                 "/usr/local/share/fonts/ChicagoFLF.ttf"]:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                pass
    try:
        return ImageFont.truetype(
            "/usr/share/fonts/dejavu-sans-fonts/DejaVuSans-Bold.ttf", size)
    except Exception:
        return ImageFont.load_default()


def save(img, name):
    path = os.path.join(THEME_DIR, name)
    img.save(path)
    print(f"  ✓  {name}")


def text_bbox(draw, text, font):
    bb = draw.textbbox((0, 0), text, font=font)
    return bb[2] - bb[0], bb[3] - bb[1]


# ── Happy Mac (parameterised) ─────────────────────────────────────────────────
def make_happy_mac(W=180, H=240):
    """Draw classic compact Mac face scaled to W×H."""
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)

    def s(x): return int(x * W / 180)
    def t(y): return int(y * H / 240)

    BODY  = (210, 206, 198)
    LIGHT = (236, 232, 224)
    SHADE = (165, 161, 153)
    EDGE  = ( 80,  80,  80)
    EDGE2 = ( 50,  50,  50)
    BLK   = ( 18,  18,  18)
    WHT   = (255, 255, 255)
    SCRN  = (196, 193, 186)
    DGRAY = (110, 108, 102)

    bx, by = s(10), t(6)
    bw, bh = s(160), t(218)
    r = s(12)

    d.rectangle([bx,       by+r,   bx+bw, by+bh], fill=BODY)
    d.rectangle([bx+r,     by,     bx+bw-r, by+r], fill=BODY)
    d.ellipse(  [bx,       by,     bx+r*2,  by+r*2], fill=BODY)
    d.ellipse(  [bx+bw-r*2, by,   bx+bw,   by+r*2], fill=BODY)

    d.line([bx+1, by+r, bx+1, by+bh],           fill=LIGHT)
    d.line([bx+r, by+1, bx+bw-r, by+1],         fill=LIGHT)
    d.line([bx+bw-1, by+r,  bx+bw-1,  by+bh],   fill=SHADE)
    d.line([bx+1,    by+bh-1, bx+bw-1, by+bh-1],fill=SHADE)

    d.rectangle([bx, by+r,   bx+bw, by+bh],     outline=EDGE)
    d.rectangle([bx+r, by,   bx+bw-r, by+r],    outline=EDGE)
    d.arc([bx,       by, bx+r*2,  by+r*2], 180, 270, fill=EDGE)
    d.arc([bx+bw-r*2, by, bx+bw, by+r*2], 270, 360, fill=EDGE)

    # Screen bezel
    sx, sy = bx+s(14), by+t(18)
    sw, sh = bw-s(28), t(108)
    d.rectangle([sx-2, sy-2, sx+sw+2, sy+sh+2], fill=(40,40,40), outline=EDGE2)
    px, py = sx+3, sy+3
    pw, ph = sw-6, sh-6
    d.rectangle([px, py, px+pw, py+ph], fill=SCRN)
    d.line([px, py, px+pw, py],  fill=(210, 208, 202))
    d.line([px, py, px,    py+ph], fill=(210, 208, 202))

    # Face
    fcx = px + pw // 2
    fcy = py + ph // 2
    ew, eh = s(8), t(11)
    eg = s(13)
    ey = fcy - t(8)
    for ex0 in [fcx - eg - ew, fcx + eg]:
        d.rectangle([ex0, ey-eh//2, ex0+ew, ey+eh//2], fill=BLK)
        d.rectangle([ex0+1, ey-eh//2+1, ex0+3, ey-eh//2+3], fill=WHT)

    smw, smh = s(40), t(20)
    smy = fcy + t(6)
    d.arc([fcx-smw//2, smy-smh//2, fcx+smw//2, smy+smh//2],
          10, 170, fill=BLK, width=max(2, s(3)))

    cheek = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cheek)
    cr = s(6)
    for chx in [fcx-eg-ew-cr-3, fcx+eg+ew-cr+3]:
        cd.ellipse([chx, smy-4-cr, chx+cr*2, smy-4+cr], fill=(220, 100, 100, 72))
    img = Image.alpha_composite(img, cheek)
    d = ImageDraw.Draw(img)

    # Chin: apple badge + floppy slot + LED
    chin_y = sy + sh + t(6)
    br = s(5)
    bcx = bx + bw // 2
    bcy = chin_y + t(10)
    d.ellipse([bcx-br, bcy-br, bcx+br, bcy+br], outline=DGRAY)

    fl_w, fl_h = s(52), t(5)
    fl_x = bx + (bw - fl_w) // 2
    fl_y = by + bh - t(40)
    d.rectangle([fl_x, fl_y, fl_x+fl_w, fl_y+fl_h],
                fill=(50,50,50), outline=(30,30,30))
    d.line([fl_x+1, fl_y+1, fl_x+fl_w-1, fl_y+1], fill=(80,80,80))

    lx, ly = bx+bw-s(22), fl_y+1
    d.ellipse([lx, ly, lx+s(4), ly+s(4)], fill=(0,180,0))

    # Base
    base_y = by + bh
    d.rectangle([bx+s(4), base_y, bx+bw-s(4), base_y+t(10)],
                fill=(195,191,183), outline=(120,116,108))
    d.line([bx+s(6), base_y+1, bx+bw-s(6), base_y+1], fill=LIGHT)

    return img


# ── 1. Background (1920×1080) ─────────────────────────────────────────────────
def make_background():
    W, H = 1920, 1080
    img = Image.new("RGB", (W, H))
    d   = ImageDraw.Draw(img)

    # Platinum gradient
    for y in range(H):
        f = y / H
        r = int(196 * (1 - f) + 172 * f)
        g = int(192 * (1 - f) + 168 * f)
        b = int(184 * (1 - f) + 158 * f)
        d.line([(0, y), (W-1, y)], fill=(r, g, b))

    # ── Mac OS 9 menu bar ─────────────────────────────────────────────────
    MB = 28
    d.rectangle([0, 0, W, MB], fill=C_MENUBAR)
    d.line([0, MB, W, MB],     fill=(112, 110, 104))
    d.line([0, MB-1, W, MB-1], fill=(248, 246, 240))
    d.line([0, 0, W, 0],       fill=(255, 255, 255))

    font_mb = get_font(15)
    items = [" \u2318 ", " File ", " Edit ", " View ", " Special ", " Help "]
    x = 6
    tmp_d = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    for item in items:
        tw, _ = text_bbox(tmp_d, item, font_mb)
        d.text((x, 6), item, font=font_mb, fill=C_BLACK)
        x += tw

    clock = "12:00 AM"
    cw, _ = text_bbox(tmp_d, clock, font_mb)
    d.text((W - cw - 14, 6), clock, font=font_mb, fill=C_BLACK)

    # ── Happy Mac (centred, above mid) ────────────────────────────────────
    MAC_W, MAC_H = 288, 384
    mac = make_happy_mac(MAC_W, MAC_H)
    mac_x = (W - MAC_W) // 2
    mac_y = H // 2 - MAC_H // 2 - 100
    img.paste(mac, (mac_x, mac_y), mac)

    # ── Title ─────────────────────────────────────────────────────────────
    font_title = get_font(52)
    title = "NiceOS 9"
    tw, th = text_bbox(d, title, font_title)
    ty = mac_y + MAC_H + 22
    # Drop shadow
    d.text((W//2 - tw//2 + 2, ty + 2), title, font=font_title, fill=(156, 152, 144))
    d.text((W//2 - tw//2,     ty),     title, font=font_title, fill=C_BLACK)

    # ── Subtitle ──────────────────────────────────────────────────────────
    font_sub = get_font(22)
    sub = "Select a startup volume:"
    sw2, _ = text_bbox(d, sub, font_sub)
    sy2 = ty + th + 14
    d.text((W//2 - sw2//2, sy2), sub, font=font_sub, fill=C_TEXT_D)

    save(img, "background.png")


# ── 2. Menu box — 9-slice (3px Mac OS 9 raised bevel) ────────────────────────
#
#  From outside → inside along each edge:
#    top/left:    DARK · HL · W_HL
#    bottom/right: W_SH · SH · DARK
#  Content: WHITE
#
def make_menu_slices():
    D   = C_DARK
    H2  = C_HL
    WH  = C_W_HL
    S   = C_SH
    WS  = C_W_SH
    W   = C_WHITE

    # Corners (3×3)
    corners = {
        "menu_nw": [
            [D,  D,  D ],
            [D,  H2, H2],
            [D,  H2, WH],
        ],
        "menu_ne": [
            [D,  D,  D ],
            [H2, H2, D ],
            [WH, H2, D ],
        ],
        "menu_sw": [
            [D,  H2, WH],
            [D,  S,  WS],
            [D,  D,  D ],
        ],
        "menu_se": [
            [WH, S,  D ],
            [WS, S,  D ],
            [D,  D,  D ],
        ],
    }
    for name, rows in corners.items():
        img = Image.new("RGB", (3, 3))
        for y, row in enumerate(rows):
            for x, c in enumerate(row):
                img.putpixel((x, y), c)
        save(img, name + ".png")

    # Top edge: 1 wide × 3 tall  (D / HL / W_HL  top→bottom)
    n = Image.new("RGB", (1, 3))
    for y, c in enumerate([D, H2, WH]):
        n.putpixel((0, y), c)
    save(n, "menu_n.png")

    # Bottom edge: 1 wide × 3 tall  (W_SH / SH / D  top→bottom)
    s = Image.new("RGB", (1, 3))
    for y, c in enumerate([WS, S, D]):
        s.putpixel((0, y), c)
    save(s, "menu_s.png")

    # Left edge: 3 wide × 1 tall  (D / HL / W_HL  left→right)
    ww = Image.new("RGB", (3, 1))
    for x, c in enumerate([D, H2, WH]):
        ww.putpixel((x, 0), c)
    save(ww, "menu_w.png")

    # Right edge: 3 wide × 1 tall  (W_SH / SH / D  left→right)
    e = Image.new("RGB", (3, 1))
    for x, c in enumerate([WS, S, D]):
        e.putpixel((x, 0), c)
    save(e, "menu_e.png")

    # Centre: 1×1 white
    c = Image.new("RGB", (1, 1), W)
    save(c, "menu_c.png")


# ── 3. Selected-item — 9-slice (Mac classic blue, 1px bevel) ─────────────────
def make_select_slices():
    BL  = C_BLUE
    BLH = ( 30, 120, 210)   # top highlight
    BLD = (  0,  55, 120)   # bottom shadow

    # Corners (1×1 — no border, just fill)
    for name in ["select_nw", "select_ne", "select_sw", "select_se"]:
        img = Image.new("RGB", (1, 1), BL)
        save(img, name + ".png")

    # Top edge: 1×1 highlight
    n = Image.new("RGB", (1, 1), BLH)
    save(n, "select_n.png")

    # Bottom edge: 1×1 shadow
    s = Image.new("RGB", (1, 1), BLD)
    save(s, "select_s.png")

    # Left/right/centre: solid blue
    for name in ["select_w", "select_e", "select_c"]:
        img = Image.new("RGB", (1, 1), BL)
        save(img, name + ".png")


# ─────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("Generating NiceOS 9 GRUB assets …")
    make_background()
    make_menu_slices()
    make_select_slices()
    print("Done — all assets generated.")
