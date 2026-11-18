import importlib.util
import struct
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "inspect_android_dt_table.py"
SPEC = importlib.util.spec_from_file_location("inspect_android_dt_table", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class AndroidDtTableTests(unittest.TestCase):
    def make_image(self):
        fdt = struct.pack(">10I", 0xD00DFEED, 40, 40, 40, 40, 17, 16, 0, 0, 0)
        header_size, entry_size, entries_offset = 32, 32, 32
        dt_offset = 64
        total_size = dt_offset + len(fdt)
        header = struct.pack(
            ">8I", 0xD7B7AB1E, total_size, header_size, entry_size,
            1, entries_offset, 4096, 0
        )
        entry = struct.pack(">8I", len(fdt), dt_offset, 123, 2, 0, 0, 0, 0)
        return header + entry + fdt

    def test_parses_one_valid_entry(self):
        with tempfile.TemporaryDirectory() as directory:
            image = Path(directory) / "dtbo.img"
            image.write_bytes(self.make_image())
            result = MODULE.inspect(image)
        self.assertEqual(result["dt_table"]["entry_count"], 1)
        self.assertEqual(result["entries"][0]["id"], 123)
        self.assertEqual(result["entries"][0]["rev"], 2)
        self.assertEqual(result["entries"][0]["fdt"]["version"], 17)

    def test_rejects_invalid_magic(self):
        with tempfile.TemporaryDirectory() as directory:
            image = Path(directory) / "bad.img"
            image.write_bytes(b"\x00" * 64)
            with self.assertRaises(ValueError):
                MODULE.inspect(image)


if __name__ == "__main__":
    unittest.main()
