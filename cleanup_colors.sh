#!/bin/bash
# Removes all unused color assets from the FlowState asset catalog.
# Keeps the full tone range (25–950) for each color family actually used in code:
# blue, error, gray-warm
# Run from Terminal: bash cleanup_colors.sh

COLORS_DIR="/Users/duongdinhdongkhoa/Documents/Coding Projects/SwiftUI Development/Personal Projects/FlowState (macOS)/FlowState/FlowState/Assets.xcassets/Untitled_ColorStyles"

deleted=0
kept=0

for dir in "$COLORS_DIR"/*.colorset; do
    name=$(basename "$dir")
    
    # Keep if it belongs to a used color family
    if [[ "$name" == blue-[0-9]* ]] || \
       [[ "$name" == error-[0-9]* ]] || \
       [[ "$name" == gray-warm-[0-9]* ]]; then
        ((kept++))
    else
        rm -rf "$dir"
        ((deleted++))
    fi
done

echo "Done. Deleted $deleted unused color assets. Kept $kept."
