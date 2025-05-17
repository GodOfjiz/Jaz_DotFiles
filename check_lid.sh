#Stored in ~/
#Used to check the lid state and set the monitor configuration accordingly

#!/bin/bash
# Check lid state (ACPI method)
is_lid_open() {
  if [ -f /proc/acpi/button/lid/LID0/state ]; then
    grep -q "open" /proc/acpi/button/lid/LID0/state
    return $?  # 0=open, 1=closed
  else
    echo "Warning: Lid state not detectable. Assuming open." >&2
    return 0  # Fail-safe: treat as open
  fi
}

# Main logic
if hyprctl monitors | grep -q -E "(DP|HDMI)-[0-9]+"; then
  # External display connected
  if is_lid_open; then
    echo "Lid open: Using BOTH internal and external displays" >&2
    hyprctl keyword monitor "eDP-1,3456x2160,0x0,2"  # Enable internal
  else
    echo "Lid closed: Using ONLY external display" >&2
    hyprctl keyword monitor "eDP-1,disable"  # Disable internal
  fi
else
  # No external displays
  hyprctl keyword monitor "eDP-1,3456x2160,0x0,2"  # Enable internal
fi
