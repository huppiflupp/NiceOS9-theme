#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCREENSHOT_DIR="$ROOT_DIR/screenshots"
WALLPAPER_DIR="$ROOT_DIR/wallpapers/NiceOS9"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

WIDTH=1536
HEIGHT=1024
PANEL_H=30
UI_FONT="DejaVu-Sans"
MONO_FONT="Noto-Sans-Mono"

mkdir -p "$SCREENSHOT_DIR"

make_panel() {
    local mode="$1"
    local out="$2"
    local fill top_line menu_text apple_fill

    if [[ "$mode" == "bright" ]]; then
        fill="#c8c4bc"
        top_line="#f4f1ea"
        menu_text="#000000"
        apple_fill="#111111"
    else
        fill="#2c2a28"
        top_line="#7a756d"
        menu_text="#ece4d7"
        apple_fill="#ece4d7"
    fi

    magick -size "${WIDTH}x${PANEL_H}" xc:none \
        -fill "$fill" -draw "rectangle 0,0 $((WIDTH-1)),$((PANEL_H-1))" \
        -fill "$top_line" -draw "rectangle 0,0 $((WIDTH-1)),0" \
        -fill black -draw "rectangle 0,$((PANEL_H-1)) $((WIDTH-1)),$((PANEL_H-1))" \
        -font ChicagoFLF -pointsize 18 -fill "$apple_fill" -annotate +16+21 "K" \
        -fill "$menu_text" -annotate +44+21 "File   Edit   View   Go   Window   Help" \
        -gravity East -annotate +20+21 "Tue 9:41 PM" \
        "$out"
}

make_window() {
    local mode="$1"
    local app="$2"
    local title="$3"
    local width="$4"
    local height="$5"
    local out="$6"
    local frame titlebar content sidebar text muted border highlight

    if [[ "$mode" == "bright" ]]; then
        frame="#d6d2cb"
        titlebar="#c8c4bc"
        content="#f7f4ee"
        sidebar="#ece7df"
        text="#1b1b1b"
        muted="#7d766c"
        border="#111111"
        highlight="#f7f3eb"
    else
        frame="#3a3734"
        titlebar="#2c2a28"
        content="#1d1b19"
        sidebar="#272422"
        text="#ede5d8"
        muted="#9a9186"
        border="#000000"
        highlight="#6f685f"
    fi

    local inner_w=$((width - 2))
    local inner_h=$((height - 2))
    local title_h=30
    local body_y=$title_h
    local body_h=$((height - title_h - 1))

    magick -size "${width}x${height}" xc:none \
        -fill "$frame" -draw "rectangle 0,0 $((width-1)),$((height-1))" \
        -fill "$border" -draw "rectangle 0,0 $((width-1)),$((height-1))" \
        -fill "$titlebar" -draw "rectangle 1,1 $((width-2)),$((title_h-1))" \
        -fill "$highlight" -draw "rectangle 1,1 $((width-2)),1" \
        -fill "$content" -draw "rectangle 1,${body_y} $((width-2)),$((height-2))" \
        -fill "$border" -draw "rectangle 1,$((title_h-1)) $((width-2)),$((title_h-1))" \
        -font ChicagoFLF -pointsize 16 -fill "$text" -gravity North \
        -annotate +0+22 "$title" \
        -fill "#c94a44" -draw "circle 18,15 21,15" \
        -fill "#d0a23d" -draw "circle 36,15 39,15" \
        -fill "#4eae56" -draw "circle 54,15 57,15" \
        "$out"

    if [[ "$app" == "kate" ]]; then
        magick "$out" \
            -fill "$sidebar" -draw "rectangle 12,44 210,$((height-18))" \
            -fill "$border" -draw "rectangle 210,44 210,$((height-18))" \
        -font "$UI_FONT" -pointsize 16 -fill "$muted" \
            -annotate +28+64 "Project" \
            -annotate +28+96 "Documents" \
            -annotate +28+128 "Welcome" \
            -fill "$text" -draw "rectangle 246,76 990,77" \
            -fill "$muted" -annotate +258+70 "Untitled" \
            "$out"
    else
        magick "$out" \
            -fill "$sidebar" -draw "rectangle 12,44 164,$((height-18))" \
            -fill "$border" -draw "rectangle 164,44 164,$((height-18))" \
        -font "$MONO_FONT" -pointsize 18 -fill "$text" \
            -annotate +188+84 'seeas@niceos9:~ %% ' \
            -fill "$muted" -annotate +188+118 "# empty session" \
            "$out"
    fi
}

composite_scene() {
    local wallpaper="$1"
    local mode="$2"
    local out="$3"
    local panel="$TMP_DIR/panel-${mode}.png"
    local kate="$TMP_DIR/kate-${mode}.png"
    local konsole="$TMP_DIR/konsole-${mode}.png"
    local kate_shadow="$TMP_DIR/kate-shadow-${mode}.png"
    local konsole_shadow="$TMP_DIR/konsole-shadow-${mode}.png"

    make_panel "$mode" "$panel"
    make_window "$mode" kate "Kate" 940 620 "$kate"
    make_window "$mode" konsole "Konsole" 720 360 "$konsole"

    magick "$kate" \( +clone -background black -shadow 55x12+16+18 \) +swap -background none -layers merge "$kate_shadow"
    magick "$konsole" \( +clone -background black -shadow 55x10+14+16 \) +swap -background none -layers merge "$konsole_shadow"

    magick "$wallpaper" \
        "$panel" -geometry +0+0 -composite \
        "$kate_shadow" -geometry +110+170 -composite \
        "$konsole_shadow" -geometry +690+580 -composite \
        "$out"
}

composite_dual_scene() {
    local wallpaper="$1"
    local mode="$2"
    local out="$3"
    local panel="$TMP_DIR/panel-${mode}.png"
    local kate="$TMP_DIR/kate2-${mode}.png"
    local konsole="$TMP_DIR/konsole2-${mode}.png"
    local kate_shadow="$TMP_DIR/kate2-shadow-${mode}.png"
    local konsole_shadow="$TMP_DIR/konsole2-shadow-${mode}.png"

    make_panel "$mode" "$panel"
    make_window "$mode" kate "Kate" 700 560 "$kate"
    make_window "$mode" konsole "Konsole" 700 420 "$konsole"

    magick "$kate" \( +clone -background black -shadow 55x12+14+16 \) +swap -background none -layers merge "$kate_shadow"
    magick "$konsole" \( +clone -background black -shadow 55x10+14+16 \) +swap -background none -layers merge "$konsole_shadow"

    magick "$wallpaper" \
        "$panel" -geometry +0+0 -composite \
        "$kate_shadow" -geometry +110+186 -composite \
        "$konsole_shadow" -geometry +728+264 -composite \
        "$out"
}

composite_focus_scene() {
    local wallpaper="$1"
    local mode="$2"
    local out="$3"
    local panel="$TMP_DIR/panel-${mode}.png"
    local konsole="$TMP_DIR/konsole3-${mode}.png"
    local kate="$TMP_DIR/kate3-${mode}.png"
    local konsole_shadow="$TMP_DIR/konsole3-shadow-${mode}.png"
    local kate_shadow="$TMP_DIR/kate3-shadow-${mode}.png"

    make_panel "$mode" "$panel"
    make_window "$mode" konsole "Konsole" 980 540 "$konsole"
    make_window "$mode" kate "Kate" 540 340 "$kate"

    magick "$konsole" \( +clone -background black -shadow 55x12+18+20 \) +swap -background none -layers merge "$konsole_shadow"
    magick "$kate" \( +clone -background black -shadow 55x10+12+14 \) +swap -background none -layers merge "$kate_shadow"

    magick "$wallpaper" \
        "$panel" -geometry +0+0 -composite \
        "$konsole_shadow" -geometry +180+220 -composite \
        "$kate_shadow" -geometry +860+120 -composite \
        "$out"
}

composite_scene "$WALLPAPER_DIR/dark/Flowing_Indigo_Wave.png" dark "$SCREENSHOT_DIR/niceos9_dark_01.png"
composite_dual_scene "$WALLPAPER_DIR/dark/NiceOS9 darker1.png" dark "$SCREENSHOT_DIR/niceos9_dark_02.png"
composite_focus_scene "$WALLPAPER_DIR/dark/Flowing_Deepblue_Waves.png" dark "$SCREENSHOT_DIR/niceos9_dark_03.png"

composite_scene "$WALLPAPER_DIR/bright/Flowing_Platinum_Wave.png" bright "$SCREENSHOT_DIR/niceos9_bright_01.png"
composite_dual_scene "$WALLPAPER_DIR/bright/NiceOS 9 bright1.png" bright "$SCREENSHOT_DIR/niceos9_bright_02.png"
composite_focus_scene "$WALLPAPER_DIR/bright/Flowing_Grey_Wave.png" bright "$SCREENSHOT_DIR/niceos9_bright_03.png"

echo "Generated promo screenshots in $SCREENSHOT_DIR"
