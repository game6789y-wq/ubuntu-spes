#!/system/bin/sh
# Read-only Redmi Note 11 bring-up inventory.
# This script never reads partition contents or writes to block devices.
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root (for example: su -c sh $0)" >&2
  exit 1
fi

OUT=${1:-"$PWD/spes-device-info"}
mkdir -p "$OUT"

prop() {
  key="$1"
  value="$(getprop "$key" 2>/dev/null || true)"
  printf '%s=%s\n' "$key" "$value"
}

{
  echo "=== Selected Android properties (no serial/IMEI) ==="
  prop ro.product.device
  prop ro.product.vendor.device
  prop ro.product.model
  prop ro.board.platform
  prop ro.hardware
  prop ro.boot.hardware
  prop ro.bootloader
  prop ro.build.version.release
  prop ro.boot.slot_suffix
  prop ro.boot.verifiedbootstate
  prop ro.boot.flash.locked
  prop ro.boot.vbmeta.device_state

  echo
  echo "=== Device tree: model ==="
  if [ -r /proc/device-tree/model ]; then
    tr '\000' '\n' < /proc/device-tree/model
  elif [ -r /sys/firmware/devicetree/base/model ]; then
    tr '\000' '\n' < /sys/firmware/devicetree/base/model
  else
    echo "model property unavailable"
  fi

  echo
  echo "=== Device tree: compatible ==="
  if [ -r /proc/device-tree/compatible ]; then
    tr '\000' '\n' < /proc/device-tree/compatible
  elif [ -r /sys/firmware/devicetree/base/compatible ]; then
    tr '\000' '\n' < /sys/firmware/devicetree/base/compatible
  else
    echo "compatible property unavailable"
  fi

  echo
  echo "=== Kernel command line (serial/MAC values redacted) ==="
  if [ -r /proc/cmdline ]; then
    sed -E 's/(androidboot\.(serialno|wifimacaddr|btmacaddr))=[^ ]*/\1=<redacted>/g' /proc/cmdline
  fi

  echo
  echo "=== Partition names and symlink targets only (no partition reads) ==="
  for p in /dev/block/by-name/*; do
    [ -e "$p" ] || continue
    name="${p##*/}"
    target="$(readlink "$p" 2>/dev/null || echo unavailable)"
    printf '%s -> %s\n' "$name" "$target"
  done
} > "$OUT/device-info.txt"

if [ -r /sys/firmware/fdt ]; then
  cp /sys/firmware/fdt "$OUT/live-device-tree.dtb"
  echo "Copied live FDT from /sys/firmware/fdt" >> "$OUT/device-info.txt"
  echo "Review live-device-tree.dtb for serial/MAC identifiers before sharing." >> "$OUT/device-info.txt"
elif [ -r /proc/device-tree/model ]; then
  echo "Live FDT binary unavailable; model/compatible text was recorded only." >> "$OUT/device-info.txt"
fi

if command -v sha256sum >/dev/null 2>&1 && [ -f "$OUT/live-device-tree.dtb" ]; then
  sha256sum "$OUT/live-device-tree.dtb" > "$OUT/live-device-tree.dtb.sha256"
fi

echo "Inventory saved to: $OUT"
echo "No block-device contents were read or modified."
