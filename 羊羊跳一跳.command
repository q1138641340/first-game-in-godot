#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

# Make sure Homebrew paths are available
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Kill any existing game instance
pkill -f "godot.*first-game-in-godot" 2>/dev/null

# Launch the game (uses intro.tscn which plays video then enters game)
/opt/homebrew/bin/godot --path "$DIR"
