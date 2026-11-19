# Read-only device inventory for Redmi Note 11 (spes)

This helper collects basic board identity and, when exposed by the running
kernel, a copy of the live flattened device tree (FDT). Run it locally on the
phone with root access (for example, KernelSU). No PC is required.

## Safety

- The script is read-only with respect to device partitions.
- It does **not** read the contents of `boot`, `vendor_boot`, `dtbo`,
  `vbmeta`, UFS, or any other block device.
- It does not flash, mount, erase, or change boot settings.
- It redacts common serial-number and MAC-address tokens from the kernel
  command line and does not query Android serial/IMEI properties.
- The output may still contain device/build details. Review it before sharing.
- Run only the repository script shown below; do not paste commands from
  untrusted sources into a root shell.

## Run from Termux (phone only)

1. Install **Termux** from its official F-Droid or GitHub distribution. Open
   Termux and install Git:

   ```sh
   pkg update
   pkg install git
   ```

2. Clone this repository:

   ```sh
   cd ~
   git clone https://github.com/game6789y-wq/ubuntu-spes.git
   cd ubuntu-spes
   ```

3. Run the inventory script with root permission. If the phone uses KernelSU,
   approve the root request when prompted:

   ```sh
   su -c "sh $HOME/ubuntu-spes/scripts/collect-spes-device-info.sh /sdcard/Download/spes-device-info"
   ```

4. When it finishes, open the phone's Downloads folder and inspect the
   `spes-device-info` directory.

Expected files:
- `device-info.txt` — selected model, board, boot and slot properties,
  device-tree model/compatible strings, and partition names only.
- `live-device-tree.dtb` — copied only if the running kernel exposes
  `/sys/firmware/fdt` as readable to root.
- `live-device-tree.dtb.sha256` — checksum, only when the FDT copy exists
  and `sha256sum` is available.

If you already cloned the repository, update it before running:

```sh
cd ~/ubuntu-spes
git pull --ff-only
```

## If the live FDT is not produced

The script will state that the binary FDT is unavailable and still save the
text inventory. Do not substitute a generic `khaje.dtb`, a Tapas DTB, or a
DTB downloaded from another phone. We will then need to identify a safe,
read-only way to obtain the active device tree for this exact handset.

## Before sharing

Review `device-info.txt` and the binary FDT for identifiers or private device
details. Do not share IMEI, serial number, account details, or unrelated
personal files. Send only `device-info.txt` and, if present,
`live-device-tree.dtb` for this project.

The collected live FDT is evidence for comparing actual board hardware against
Mainline bindings. It is not a boot image and must never be flashed.
