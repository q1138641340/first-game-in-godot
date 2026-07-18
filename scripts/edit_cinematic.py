#!/usr/bin/env python3
"""
羊羊开场动画剪辑脚本
三层叙事：表面游戏跳跃 → AI异化入侵 → 恐怖侧写闪回
"""

import subprocess
import os
import json
import shlex

SHEEP_DIR = "/Users/mie/Movies/羊羊"
V11_DIR = os.path.join(SHEEP_DIR, "videos 11")
V9_DIR = os.path.join(SHEEP_DIR, "videos 9")
IMG_DIR = SHEEP_DIR
PROJ_DIR = "/Users/mie/Documents/Codex/2026-04-24/new-chat/游戏项目/first-game-in-godot"
AUDIO_BED = os.path.join(PROJ_DIR, "assets/video/audio.opus")
SCARE_SFX = os.path.join(PROJ_DIR, "assets/sounds/scare.wav")
OUTPUT = os.path.join(PROJ_DIR, "assets/video/cinematic_intro.mp4")
TMP = "/tmp/cinematic_build"

FPS = 24
W, H = 1280, 720

os.makedirs(TMP, exist_ok=True)


def run(cmd_list, desc=""):
    """Run a command with args as list (no shell injection)."""
    if desc:
        print(f"  [{desc}]", flush=True)
    result = subprocess.run(cmd_list, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  ERROR: {result.stderr[-400:]}")
        return False
    return True


def probe_duration(filepath):
    """Get duration of a media file in seconds."""
    r = subprocess.run(
        ["ffprobe", "-v", "quiet", "-print_format", "json", "-show_format", filepath],
        capture_output=True, text=True
    )
    if r.returncode == 0:
        return float(json.loads(r.stdout)["format"]["duration"])
    return 0


# ============================================================
# Step 1: 准备图片快闪片段
# ============================================================
print("Step 1: 准备图片快闪片段...")
images = sorted([f for f in os.listdir(IMG_DIR) if f.endswith('.png')])

# 每张图的帧数：前几张稍长，中间快速闪，最后一张落幅
flash_frames = [7, 6, 6, 5, 5, 4, 4, 3, 3, 3, 3, 5]

image_clips = []
for i, img in enumerate(images):
    frames = flash_frames[i]
    dur = frames / FPS
    out_clip = os.path.join(TMP, f"img_{i:02d}.mp4")
    if not os.path.exists(out_clip):
        src = os.path.join(IMG_DIR, img)
        vf = f"scale={W}:{H},setsar=1,format=yuv420p,fade=t=in:d=0.02,fade=t=out:d=0.02"
        run([
            "ffmpeg", "-y",
            "-loop", "1", "-i", src,
            "-vf", vf,
            "-t", f"{dur:.4f}",
            "-r", str(FPS),
            "-c:v", "libx264", "-preset", "ultrafast", "-crf", "18",
            "-an",
            out_clip
        ], f"img {i}: {frames}f")
    image_clips.append(out_clip)

# ============================================================
# Step 2: 截取视频片段
# ============================================================
print("\nStep 2: 截取视频片段...")

# v11 主轨道：羊羊在游戏中跳跃
v11_cuts = [
    ("001_video.mp4", 0, 4.5, "open"),
    ("镜头001.mp4", 0, 4.0, "play1"),
    ("镜头002.mp4", 0, 3.5, "play2"),
    ("镜头001.mp4", 4.0, 3.0, "play3"),
    ("镜头003.mp4", 0, 4.0, "play4"),
    ("镜头002.mp4", 4.0, 3.0, "play5"),
    ("镜头004.mp4", 0, 3.5, "play6"),
    ("镜头003.mp4", 4.0, 3.0, "play7"),
    ("镜头001.mp4", 7.0, 3.0, "play8"),
    ("镜头004.mp4", 3.5, 4.0, "play9"),
    ("镜头002.mp4", 7.0, 3.5, "play10"),
    ("镜头003.mp4", 7.0, 3.0, "end1"),
    ("001_video.mp4", 5.0, 3.0, "end2"),
]

# v9 B-roll：AI控制/异化的幕后
v9_cuts = [
    ("镜头001.mp4", 0, 0.8, "ai1"),
    ("镜头002.mp4", 2.0, 1.2, "ai2"),
    ("镜头003.mp4", 0, 1.5, "ai3"),
    ("镜头001.mp4", 3.0, 0.6, "ai4"),
    ("镜头004.mp4", 0, 1.0, "ai5"),
    ("镜头002.mp4", 6.0, 1.5, "ai6"),
    ("镜头003.mp4", 4.0, 2.0, "ai7"),
    ("镜头004.mp4", 2.0, 0.8, "ai8"),
    ("镜头001.mp4", 6.0, 0.5, "ai9"),
    ("镜头003.mp4", 8.0, 1.0, "ai10"),
    ("镜头002.mp4", 9.0, 0.8, "ai11"),
]

clips = {}  # label -> path

for fname, start, dur, label in v11_cuts + v9_cuts:
    out_clip = os.path.join(TMP, f"clip_{label}.mp4")
    if not os.path.exists(out_clip):
        src_label = "v11" if label in [l for _, _, _, l in v11_cuts] else "v9"
        src_dir = V11_DIR if src_label == "v11" else V9_DIR
        src = os.path.join(src_dir, fname)
        af = "afade=t=in:d=0.02:curve=tri,afade=t=out:d=0.02:curve=tri"
        run([
            "ffmpeg", "-y",
            "-accurate_seek", "-ss", f"{start:.3f}",
            "-i", src,
            "-t", f"{dur:.3f}",
            "-c:v", "libx264", "-preset", "ultrafast", "-crf", "16",
            "-c:a", "aac", "-b:a", "128k",
            "-af", af,
            out_clip
        ], f"{src_label}/{label}: {start:.1f}s +{dur:.1f}s")
    clips[label] = out_clip

# ============================================================
# Step 3: 编排时间线
# ============================================================
print("\nStep 3: 编排时间线...")

# 类型: game | ai | img
timeline = [
    # Phase 1 — 表面轻快 (0~14s)
    ("game", "open"),
    ("img", 0),
    ("game", "play1"),
    ("game", "play2"),
    ("img", 1),
    ("game", "play3"),
    ("ai", "ai1"),
    ("game", "play4"),

    # Phase 2 — AI侵入增强 (14~28s)
    ("img", 2),
    ("game", "play5"),
    ("ai", "ai2"),
    ("img", 3),
    ("ai", "ai3"),
    ("game", "play6"),
    ("img", 4),
    ("ai", "ai4"),
    ("img", 5),
    ("game", "play7"),

    # Phase 3 — 三者交织 (28~40s)
    ("ai", "ai5"),
    ("img", 6),
    ("game", "play8"),
    ("img", 7),
    ("ai", "ai6"),
    ("img", 8),
    ("ai", "ai7"),
    ("img", 9),
    ("game", "play9"),
    ("ai", "ai8"),
    ("img", 10),
    ("ai", "ai9"),
    ("game", "play10"),
    ("ai", "ai10"),

    # Phase 4 — 落幅 (40~50s)
    ("ai", "ai11"),
    ("game", "end1"),
    ("img", 11),
    ("game", "end2"),
]

# 写 concat 列表
concat_path = os.path.join(TMP, "concat.txt")
with open(concat_path, "w") as f:
    for typ, key in timeline:
        if typ == "game":
            p = clips[key]
        elif typ == "ai":
            p = clips[key]
        else:
            p = image_clips[key]
        f.write(f"file '{p}'\n")

# ============================================================
# Step 4: 拼接视频
# ============================================================
print("\nStep 4: 拼接视频...")
video_raw = os.path.join(TMP, "video_raw.mp4")
run([
    "ffmpeg", "-y",
    "-f", "concat", "-safe", "0", "-i", concat_path,
    "-c:v", "libx264", "-preset", "fast", "-crf", "18",
    "-pix_fmt", "yuv420p",
    "-an",
    video_raw
], "concatenating video")

video_dur = probe_duration(video_raw)
print(f"  Video duration: {video_dur:.1f}s")

# ============================================================
# Step 5: 准备音频资源
# ============================================================
print("\nStep 5: 准备音频...")

# audio.opus -> wav 作为底音（先不做 fade，等知道视频长度后再处理）
bed_raw = os.path.join(TMP, "bed_raw.wav")
bed_raw_dur = 50.0  # audio.opus is 50s
run([
    "ffmpeg", "-y",
    "-i", AUDIO_BED,
    "-ac", "2", "-ar", "44100",
    bed_raw
], "converting audio bed")

print(f"  Bed duration: {bed_raw_dur:.1f}s")

# scare.wav 处理
scare_wav = os.path.join(TMP, "scare.wav")
run([
    "ffmpeg", "-y",
    "-i", SCARE_SFX,
    "-ac", "2", "-ar", "44100",
    "-af", "aecho=0.8:0.7:40:0.5,afade=t=in:d=0.01,afade=t=out:d=0.08",
    scare_wav
], "processing scare")

# ============================================================
# Step 6: 计算 scare 触发时间点
# ============================================================
print("\nStep 6: 计算音效时间点...")

# 在每个 image flash 和关键 AI 侵入点放置 scare
scare_cues = []
t = 0.0
for typ, key in timeline:
    if typ == "game" or typ == "ai":
        seg_dur = probe_duration(clips[key])
    else:
        seg_dur = probe_duration(image_clips[key])

    # 在特定图片/AI 点触发 scare
    if typ == "img" and key in [3, 6, 9, 11]:
        scare_cues.append(t)
    if typ == "ai" and key in ["ai3", "ai7", "ai10"]:
        scare_cues.append(t + seg_dur * 0.3)

    t += seg_dur

print(f"  Scare cues: {[f'{x:.1f}s' for x in scare_cues]}")

# ============================================================
# Step 7: 混音合成
# ============================================================
print("\nStep 7: 混音合成...")

# 构建 amix：bed + 多个延迟的 scare
num_scares = len(scare_cues)
scare_dur = probe_duration(scare_wav)

# 策略：创建带延迟的 scare 轨道，合并成一个轨道，再与 bed 混合
filter_parts = []
scare_labels = []

BED_IDX = 1  # bed is input #1 (0=video, 1=bed, 2..=scares)
SCARE_START = 2

for i, cue_time in enumerate(scare_cues):
    delay_ms = int(cue_time * 1000)
    label = f"s{i}"
    scare_labels.append(f"[{label}]")
    src_idx = SCARE_START + i
    filter_parts.append(
        f"[{src_idx}:a]adelay={delay_ms}|{delay_ms},"
        f"apad=whole_dur={video_dur}s,"
        f"volume=0.5[{label}]"
    )

# 合并所有 scare
scare_mix_label = "scare_mix"
if num_scares > 0:
    filter_parts.append(
        f"{''.join(scare_labels)}amix=inputs={num_scares}:duration=longest:dropout_transition=0,"
        f"volume=1.5[{scare_mix_label}]"
    )

# bed + scare_mix
# loop bed to fill video duration, then fade in/out
filter_parts.append(
    f"[{BED_IDX}:a]aloop=loop=-1,"
    f"atrim=0:{video_dur}s,"
    f"afade=t=in:d=1.5,afade=t=out:d=3:curve=tri[bed];"
    f"[bed][{scare_mix_label}]amix=inputs=2:duration=longest:dropout_transition=0,"
    f"volume=1.2,alimiter=limit=0.95[outa]"
)

filter_graph = ";".join(filter_parts)

# 构建命令
cmd = [
    "ffmpeg", "-y",
    "-i", video_raw,
    "-i", bed_raw,
]
for _ in scare_cues:
    cmd.extend(["-i", scare_wav])

cmd.extend([
    "-filter_complex", filter_graph,
    "-map", "0:v",
    "-map", "[outa]",
    "-c:v", "copy",
    "-c:a", "aac", "-b:a", "192k", "-ar", "44100",
    "-shortest",
    OUTPUT
])

print(f"  Mixing {num_scares} scare cues with bed...")
run(cmd, "final composite")

# ============================================================
# Done
# ============================================================
if os.path.exists(OUTPUT):
    final_dur = probe_duration(OUTPUT)
    size_mb = os.path.getsize(OUTPUT) / 1024 / 1024
    print(f"\n=== DONE ===")
    print(f"Output: {OUTPUT}")
    print(f"Duration: {final_dur:.1f}s")
    print(f"Size: {size_mb:.1f}MB")

    # 同时输出一个 webm 版本给 Godot
    webm_out = OUTPUT.replace(".mp4", ".webm")
    run([
        "ffmpeg", "-y",
        "-i", OUTPUT,
        "-c:v", "libvpx-vp9", "-crf", "30", "-b:v", "0",
        "-c:a", "libopus",
        webm_out
    ], "converting to webm for Godot")
    if os.path.exists(webm_out):
        print(f"WebM: {webm_out} ({os.path.getsize(webm_out)/1024/1024:.1f}MB)")
else:
    print("FAILED - output not created")
