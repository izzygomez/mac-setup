### Colors
PURPLE="\033[95m"
CYAN="\033[96m"
DARKCYAN="\033[36m"
BLUE="\033[94m"
GREEN="\033[92m"
YELLOW="\033[93m"
RED="\033[91m"

### Formatting
BOLD="\033[1m"
DIM="\033[2m"
UNDERLINE="\033[4m"
END="\033[0m"

### Spacing
TAB="  " # preferred over TAB="\t" for consistency
# both of these are 79 chars long for visual alignment
BOLD_SEPARATOR=$BOLD"═══════════════════════════════════════════════════════════════════════════════"$END
LIGHT_SEPARATOR=$BOLD"· · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·"$END

### Status icons
ICON_CHECK=$GREEN"✓"$END
ICON_ARROW="→"
ICON_WARN=$YELLOW"◆"$END
ICON_ERROR=$RED"✗"$END
