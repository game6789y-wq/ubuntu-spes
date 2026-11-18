#!/usr/bin/env python3
"""Read-only inspector for Android DT table / DTBO images.

This utility parses the standard big-endian Android DT table header and its
entries, then validates any embedded flattened device-tree (FDT) headers.
It does not modify, unpack, flash, or repack the input image.
"""
from __future__ import annotations

import argparse
import json
import struct
import sys
from pathlib import Path

DT_TABLE_MAGIC = 0xD7B7AB1E
FDT_MAGIC = 0xD00DFEED
DT_TABLE_HEADER = struct.Struct(">8I")
DT_TABLE_ENTRY_MIN = struct.Struct(">8I")
FDT_HEADER = struct.Struct(">10I")


def fail(message: str) -> None:
    raise ValueError(message)


def inspect(path: Path) -> dict:
    data = path.read_bytes()
    if len(data) < DT_TABLE_HEADER.size:
        fail(f"file is too small for DT table header: {len(data)} bytes")

    (magic, total_size, header_size, entry_size, entry_count,
     entries_offset, page_size, version) = DT_TABLE_HEADER.unpack_from(data)

    if magic != DT_TABLE_MAGIC:
        fail(f"bad DT table magic: 0x{magic:08x}")
    if total_size > len(data) or total_size < header_size:
        fail(f"invalid total_size={total_size} for file size={len(data)}")
    if header_size < DT_TABLE_HEADER.size:
        fail(f"header_size too small: {header_size}")
    if entry_size < DT_TABLE_ENTRY_MIN.size:
        fail(f"entry_size too small: {entry_size}")
    if entries_offset < header_size:
        fail(f"entries_offset {entries_offset} overlaps header_size {header_size}")
    entries_end = entries_offset + entry_count * entry_size
    if entries_end > total_size:
        fail("DT table entries extend beyond total_size")
    if page_size == 0:
        fail("page_size is zero")

    entries = []
    for index in range(entry_count):
        pos = entries_offset + index * entry_size
        dt_size, dt_offset, board_id, board_rev, c0, c1, c2, c3 = (
            DT_TABLE_ENTRY_MIN.unpack_from(data, pos)
        )
        end = dt_offset + dt_size
        item = {
            "index": index,
            "dt_size": dt_size,
            "dt_offset": dt_offset,
            "id": board_id,
            "rev": board_rev,
            "custom": [c0, c1, c2, c3],
        }
        if dt_size == 0 or end > total_size:
            item["fdt_error"] = "entry payload outside DT table"
        elif dt_size < FDT_HEADER.size:
            item["fdt_error"] = "entry too small for FDT header"
        else:
            fields = FDT_HEADER.unpack_from(data, dt_offset)
            (fdt_magic, fdt_total, off_struct, off_strings, off_rsvmap,
             fdt_version, last_comp, boot_cpuid, size_strings,
             size_struct) = fields
            if fdt_magic != FDT_MAGIC:
                item["fdt_error"] = f"bad FDT magic: 0x{fdt_magic:08x}"
            elif fdt_total > dt_size or fdt_total < FDT_HEADER.size:
                item["fdt_error"] = f"invalid FDT totalsize: {fdt_total}"
            else:
                item["fdt"] = {
                    "totalsize": fdt_total,
                    "version": fdt_version,
                    "last_comp_version": last_comp,
                    "boot_cpuid_phys": boot_cpuid,
                    "off_dt_struct": off_struct,
                    "size_dt_struct": size_struct,
                    "off_dt_strings": off_strings,
                    "size_dt_strings": size_strings,
                    "off_mem_rsvmap": off_rsvmap,
                }
        entries.append(item)

    return {
        "file": str(path),
        "file_size": len(data),
        "dt_table": {
            "magic": f"0x{magic:08x}",
            "total_size": total_size,
            "header_size": header_size,
            "entry_size": entry_size,
            "entry_count": entry_count,
            "entries_offset": entries_offset,
            "page_size": page_size,
            "version": version,
        },
        "entries": entries,
        "trailing_bytes": len(data) - total_size,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("image", type=Path, help="local dtbo.img or dt_table image")
    args = parser.parse_args()
    try:
        result = inspect(args.image)
    except (OSError, ValueError, struct.error) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
