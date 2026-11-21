#!/usr/bin/env python3
"""Generate original PipeLeap geometric art, icons, and simple WAV/MP3 audio."""
from __future__ import annotations

import math
import struct
import wave
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMAGES = ROOT / "assets" / "images"
HERO = IMAGES / "hero_frames"
STORE = ROOT / "assets" / "store"
AUDIO = ROOT / "assets" / "audio"
WEB_ICONS = ROOT / "web" / "icons"

# Palette
RED = (229, 37, 33, 255)
BLUE = (4, 156, 216, 255)
YELLOW = (251, 208, 0, 255)
GREEN = (67, 176, 71, 255)
CREAM = (255, 248, 231, 255)
DARK = (26, 26, 46, 255)
ORANGE = (240, 120, 40, 255)
WHITE = (255, 255, 255, 255)
TRANS = (0, 0, 0, 0)


def _crc(chunk_type: bytes, data: bytes) -> int:
    return zlib.crc32(chunk_type + data) & 0xFFFFFFFF


def write_png(path: Path, width: int, height: int, rgba: list[tuple[int, int, int, int]]) -> None:
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            r, g, b, a = rgba[y * width + x]
            raw.extend((r, g, b, a))
    compressed = zlib.compress(bytes(raw), 9)

    def chunk(tag: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", _crc(tag, data))

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", compressed) + chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


def blank(w: int, h: int, color=TRANS):
    return [color] * (w * h)


def set_px(px, w, h, x, y, color):
    if 0 <= x < w and 0 <= y < h:
        px[y * w + x] = color


def fill_rect(px, w, h, x0, y0, x1, y1, color):
    for y in range(y0, y1):
        for x in range(x0, x1):
            set_px(px, w, h, x, y, color)


def fill_circle(px, w, h, cx, cy, r, color):
    r2 = r * r
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r2:
                set_px(px, w, h, x, y, color)


def fill_ellipse(px, w, h, cx, cy, rx, ry, color):
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if rx and ry and ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0:
                set_px(px, w, h, x, y, color)


def draw_hero(w: int, h: int, frame: int) -> list:
    px = blank(w, h)
    bob = int(math.sin(frame / 12 * math.pi * 2) * 3)
    leg = int(math.sin(frame / 12 * math.pi * 2) * 4)
    # Shadow
    fill_ellipse(px, w, h, w // 2, h - 8, 22, 5, (0, 0, 0, 50))
    # Legs
    fill_rect(px, w, h, w // 2 - 14, h - 28 + bob, w // 2 - 4, h - 10 + bob + leg, DARK)
    fill_rect(px, w, h, w // 2 + 4, h - 28 + bob, w // 2 + 14, h - 10 + bob - leg, DARK)
    # Body capsule
    fill_ellipse(px, w, h, w // 2, h // 2 + 6 + bob, 22, 28, ORANGE)
    fill_rect(px, w, h, w // 2 - 18, h // 2 - 4 + bob, w // 2 + 18, h // 2 + 20 + bob, ORANGE)
    # Belt
    fill_rect(px, w, h, w // 2 - 18, h // 2 + 10 + bob, w // 2 + 18, h // 2 + 16 + bob, DARK)
    # Head
    fill_circle(px, w, h, w // 2, h // 2 - 18 + bob, 16, CREAM)
    # Helmet
    fill_ellipse(px, w, h, w // 2, h // 2 - 24 + bob, 18, 12, BLUE)
    fill_rect(px, w, h, w // 2 - 18, h // 2 - 24 + bob, w // 2 + 18, h // 2 - 16 + bob, BLUE)
    # Visor stripe
    fill_rect(px, w, h, w // 2 - 14, h // 2 - 22 + bob, w // 2 + 14, h // 2 - 18 + bob, YELLOW)
    # Eyes
    fill_circle(px, w, h, w // 2 - 5, h // 2 - 16 + bob, 2, DARK)
    fill_circle(px, w, h, w // 2 + 5, h // 2 - 16 + bob, 2, DARK)
    # Arms
    arm = int(math.cos(frame / 12 * math.pi * 2) * 3)
    fill_rect(px, w, h, w // 2 - 28, h // 2 + arm + bob, w // 2 - 18, h // 2 + 14 + arm + bob, CREAM)
    fill_rect(px, w, h, w // 2 + 18, h // 2 - arm + bob, w // 2 + 28, h // 2 + 14 - arm + bob, CREAM)
    return px


def scale_nearest(px, sw, sh, dw, dh):
    out = blank(dw, dh)
    for y in range(dh):
        for x in range(dw):
            sx = min(sw - 1, x * sw // dw)
            sy = min(sh - 1, y * sh // dh)
            out[y * dw + x] = px[sy * sw + sx]
    return out


def draw_logo(size: int):
    px = blank(size, size, BLUE)
    # Soft gradient sky
    for y in range(size):
        t = y / max(1, size - 1)
        c = (
            int(BLUE[0] + (CREAM[0] - BLUE[0]) * t * 0.35),
            int(BLUE[1] + (CREAM[1] - BLUE[1]) * t * 0.25),
            int(BLUE[2] + (255 - BLUE[2]) * t * 0.15),
            255,
        )
        for x in range(size):
            px[y * size + x] = c
    # Pipe ring
    cx = cy = size // 2
    fill_circle(px, size, size, cx, cy, size // 3, GREEN)
    fill_circle(px, size, size, cx, cy, size // 4, (40, 120, 50, 255))
    fill_circle(px, size, size, cx, cy, size // 6, BLUE)
    # Leap arrow
    for i in range(size // 8):
        fill_rect(px, size, size, cx - 4 + i, cy - size // 10 - i // 2, cx + 4 + i, cy - size // 10 - i // 2 + 6, YELLOW)
    hero = draw_hero(64, 64, 2)
    hero_s = scale_nearest(hero, 64, 64, size // 3, size // 3)
    ox = size // 2 - size // 6
    oy = size // 2 - size // 8
    hw = size // 3
    for y in range(hw):
        for x in range(hw):
            c = hero_s[y * hw + x]
            if c[3] > 20:
                set_px(px, size, size, ox + x, oy + y, c)
    return px


def draw_feature(w=1024, h=500):
    px = blank(w, h)
    for y in range(h):
        t = y / (h - 1)
        c = (
            int(94 + (184 - 94) * t),
            int(200 + (236 - 200) * t),
            int(248 + (255 - 248) * t),
            255,
        )
        for x in range(w):
            px[y * w + x] = c
    # Hills
    for x in range(w):
        hill = int(h * 0.72 + math.sin(x / 90) * 28 + math.sin(x / 40) * 12)
        for y in range(hill, h):
            px[y * w + x] = GREEN if y < hill + 18 else (90, 140, 60, 255)
    # Pipe
    fill_rect(px, w, h, 120, h - 220, 200, h, GREEN)
    fill_rect(px, w, h, 100, h - 240, 220, h - 200, (50, 150, 55, 255))
    # Title block
    fill_rect(px, w, h, 280, 140, 900, 280, (26, 26, 46, 180))
    # Decorative coins
    for i, cx in enumerate((320, 400, 480, 560)):
        fill_circle(px, w, h, cx, 200, 18, YELLOW)
        fill_circle(px, w, h, cx, 200, 8, ORANGE)
    hero = draw_hero(96, 96, 4)
    big = scale_nearest(hero, 96, 96, 220, 220)
    for y in range(220):
        for x in range(220):
            c = big[y * 220 + x]
            if c[3] > 20:
                set_px(px, w, h, 720 + x, 160 + y, c)
    return px


def write_wav(path: Path, samples: list[float], rate=22050):
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(rate)
        frames = b"".join(struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples)
        wf.writeframes(frames)


def tone(freq, dur, rate=22050, vol=0.25, decay=True):
    n = int(rate * dur)
    out = []
    for i in range(n):
        t = i / rate
        env = (1 - i / n) if decay else 1.0
        out.append(math.sin(2 * math.pi * freq * t) * vol * env)
    return out


def make_bgm(path: Path):
    # Simple original arpeggio loop (C major-ish)
    notes = [261.63, 329.63, 392.00, 523.25, 392.00, 329.63, 293.66, 349.23]
    samples: list[float] = []
    for _ in range(4):
        for f in notes:
            samples.extend(tone(f, 0.18, vol=0.18, decay=True))
            samples.extend([0.0] * int(22050 * 0.02))
    write_wav(path.with_suffix(".wav"), samples)
    # Prefer mp3 if ffmpeg available; else copy wav as placeholder named mp3 won't work —
    # audioplayers needs real format. Convert with ffmpeg if present.
    return path.with_suffix(".wav")


def make_clear(path: Path):
    samples = []
    for f in (392, 523.25, 659.25, 784):
        samples.extend(tone(f, 0.22, vol=0.28, decay=True))
    write_wav(path.with_suffix(".wav"), samples)
    return path.with_suffix(".wav")


def try_ffmpeg_mp3(wav: Path, mp3: Path) -> bool:
    import shutil
    import subprocess

    if not shutil.which("ffmpeg"):
        return False
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(wav), "-codec:a", "libmp3lame", "-qscale:a", "4", str(mp3)],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return True


def main():
    HERO.mkdir(parents=True, exist_ok=True)
    STORE.mkdir(parents=True, exist_ok=True)
    AUDIO.mkdir(parents=True, exist_ok=True)

    delays = []
    for i in range(12):
        px = draw_hero(64, 64, i)
        write_png(HERO / f"frame_{i:02d}.png", 64, 64, px)
        delays.append(80)
    (HERO / "delays.txt").write_text(",".join(str(d) for d in delays))

    hero_still = draw_hero(128, 128, 2)
    write_png(IMAGES / "hero.png", 128, 128, hero_still)

    logo = draw_logo(512)
    write_png(IMAGES / "app_logo.png", 512, 512, logo)

    icon = draw_logo(1024)
    write_png(STORE / "icon_1024.png", 1024, 1024, icon)
    icon512 = scale_nearest(icon, 1024, 1024, 512, 512)
    write_png(STORE / "icon_512.png", 512, 512, icon512)

    feat = draw_feature()
    write_png(STORE / "feature_graphic.png", 1024, 500, feat)

    # Web icons
    WEB_ICONS.mkdir(parents=True, exist_ok=True)
    for size, name in ((192, "Icon-192.png"), (512, "Icon-512.png")):
        s = scale_nearest(icon, 1024, 1024, size, size)
        write_png(WEB_ICONS / name, size, size, s)
        write_png(WEB_ICONS / name.replace("Icon", "Icon-maskable"), size, size, s)

    fav = scale_nearest(icon, 1024, 1024, 48, 48)
    write_png(ROOT / "web" / "favicon.png", 48, 48, fav)

    bgm_wav = make_bgm(AUDIO / "bgm")
    clear_wav = make_clear(AUDIO / "level_clear")
    if try_ffmpeg_mp3(bgm_wav, AUDIO / "bgm.mp3"):
        bgm_wav.unlink(missing_ok=True)
    else:
        # Keep wav; update AudioService later if needed — try copy as fallback name
        print("WARN: ffmpeg missing; leaving WAV. Will adapt audio paths.")
    if try_ffmpeg_mp3(clear_wav, AUDIO / "level_clear.mp3"):
        clear_wav.unlink(missing_ok=True)

    print("Assets generated OK")


if __name__ == "__main__":
    main()
