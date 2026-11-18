#!/system/bin/sh
# Read-only DTBO export for Redmi Note 11 bring-up.
# Reads the active DTBO partition and writes a copy only to OUT.
# Never writes to /dev/block or changes the active slot.
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root (for example: su -c sh $0)" >&2
  exit 1
fi

SLOT="$(getprop ro.boot.slot_suffix 2>/dev/null || true)"
case "$SLOT" in
  ""|_a|_b) ;;
  *)
    echo "Unexpected ro.boot.slot_suffix='$SLOT'; refusing to guess." >&2
    exit 2
    ;;
esac

PART_LINK=""
for dir in /dev/block/by-name /dev/block/bootdevice/by-name /dev/block/platform/*/by-name; do
  [ -d "$dir" ] || continue
  if [ -n "$SLOT" ] && [ -e "$dir/dtbo$SLOT" ]; then
    PART_LINK="$dir/dtbo$SLOT"
    break
  fi
  if [ -z "$SLOT" ] && [ -e "$dir/dtbo" ]; then
    PART_LINK="$dir/dtbo"
    break
  fi
done

if [ -z "$PART_LINK" ]; then
  echo "Could not identify one active DTBO partition safely." >&2
  echo "slot_suffix='$SLOT'; candidates found:" >&2
  for dir in /dev/block/by-name /dev/block/bootdevice/by-name /dev/block/platform/*/by-name; do
    [ -d "$dir" ] || continue
    for p in "$dir"/dtbo*; do
      [ -e "$p" ] || continue
      ls -l "$p" >&2
    done
  done
  echo "No partition was read. Check the partition names and slot suffix." >&2
  exit 3
fi

PART="$(readlink -f "$PART_LINK" 2>/dev/null || echo "$PART_LINK")"
case "$PART" in
  /dev/block/*) ;;
  *)
    echo "Resolved source is not under /dev/block; refusing: $PART" >&2
    exit 4
    ;;
esac
[ -r "$PART" ] || { echo "DTBO source is not readable: $PART" >&2; exit 5; }

OUT="${1:-/sdcard/Download/spes-dtbo}"
mkdir -p "$OUT"
DEST="$OUT/${PART_LINK##*/}.img"
[ ! -e "$DEST" ] || { echo "Output already exists; choose another output directory: $DEST" >&2; exit 6; }

echo "Source partition: $PART_LINK -> $PART"
echo "Active slot suffix: ${SLOT:-not reported}"
echo "Output file: $DEST"
echo "Reading partition only; no block-device writes will be performed."

dd if="$PART" of="$DEST" bs=1M
[ -s "$DEST" ] || { echo "DTBO copy is empty; refusing to report success." >&2; exit 7; }
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$DEST" > "$DEST.sha256"
fi
{
  echo "partition_link=$PART_LINK"
  echo "partition_device=$PART"
  echo "slot_suffix=$SLOT"
  echo "output_file=$DEST"
} > "$DEST.source.txt"

echo "DTBO copied successfully."
echo "No partition was modified."
