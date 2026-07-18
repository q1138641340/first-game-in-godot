#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -n "$GODOT_BIN" ] && [ -x "$GODOT_BIN" ]; then
	GODOT="$GODOT_BIN"
elif command -v godot >/dev/null 2>&1; then
	GODOT="$(command -v godot)"
elif [ -x "/Users/$USER/Library/Application Support/Steam/steamapps/common/Godot Engine/Godot.app/Contents/MacOS/Godot" ]; then
	GODOT="/Users/$USER/Library/Application Support/Steam/steamapps/common/Godot Engine/Godot.app/Contents/MacOS/Godot"
elif [ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
	GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
else
	echo "Godot 4 executable was not found."
	exit 1
fi

exec "$GODOT" --path "$DIR"
