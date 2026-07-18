#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
VIDEO="$DIR/assets/video/intro.mp4"

echo "Playing intro..."
ffplay -fs -autoexit -loglevel quiet "$VIDEO" 2>/dev/null

echo "Starting game..."
godot --path "$DIR"
