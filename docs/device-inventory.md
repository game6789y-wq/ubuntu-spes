# Read-only device inventory for Redmi Note 11 (spes)

This helper collects basic board identity and, when exposed by the running
kernel, a copy of the live flattened device tree (FDT). It is intended for
running locally on the phone with root access.

## Safety

- The script is read-only with respect to device partitions.
- It does **not** read the contents of `boot`, `vendor_boot`, `dtbo`,
  `vbmeta`, UFS, or any other block device.
- It does not flash, mount, erase, or change boot settings.
- It redacts common serial-number and MAC-address tokens from the kernel
  command line and does not query Android serial/IMEI properties.
- The output may still contain device/build details. Review it before sharing.

## Run from Termux

After downloading/cloning this repository on the phone:

```sh
cd ubuntu-spes
su -c sh scripts/collect-spes-device-info.sh
```

The default output directory is `spes-device-info/` in the current directory.
You can provide another writable path:

```sh
su -c 'sh scripts/collect-spes-device-info.sh /sdcard/Download/spes-device-info'
```

If `live-device-tree.dtb` is produced, share that file together with
`device-info.txt` for review. If the kernel does not expose
`/sys/firmware/fdt`, the script records the available model/compatible
strings only; do not substitute a DTB from another device.

The collected live FDT is the next key input for comparing actual board
hardware against Mainline bindings. It is not itself a boot image and must
not be flashed.
