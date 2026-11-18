# Mainline DTS work area

## Current candidate

`sm6225-xiaomi-spes.dts` is a minimal compile candidate derived from the
public early spes DTS in:

- Repository: https://github.com/external-mirrors/sm6225-mainline-linux
- Branch: `sm6225/v6.19-rc8`
- Pinned branch commit inspected: `467185042fc7a8e2da4589767dd0d7b8ddc422e8`
- Original board DTS blob: `4a2b84c19250adc18c79b67df38d7d6bb332e6fb`
- SoC DTSI blob: `a8386fc8b06a605d9ff83fcfc1afe17d7dbccc52`
- PM6125 DTSI blob in that source tree: `d0db28336fa9bb976abd831ed92adece4317149f`

The public board DTS is only a small early-boot skeleton. It includes
`sm6225.dtsi`, declares the board identity and XBL IDs, retains the bootloader
framebuffer at 0x5c000000, and reserves 4 MiB for ramoops at 0x5d000000. The
SoC DTSI contains a memory node whose size is expected to be filled by the
bootloader, plus SoC-level reserved-memory entries. Its XBL ID is 518 decimal
(0x206), matching the value written as 0x206 in the related tapas DTS; both
sources also use board ID 0x20022. The framebuffer dimensions/address agree
with the independent same-model Spes hardware report for one firmware build.

Our copy fixes the original spelling error `#adress-cells` to
`#address-cells` and removes the postmarketOS-only `pmos.nosplash` bootarg.
The two clock/power keep-alive flags remain temporary bring-up flags.

## Current candidate state

Implemented in the candidate:
- PM6125 base DTSI, PMIC power key, and a minimal L9 (1.8-2.0 V) regulator
  declaration for the disabled touchscreen candidate; not a full PMIC tree.
- QUPv3 SE2 / Mainline `i2c2` bus enabled with a 19.2 MHz source clock.
- Upstream FocalTech FT5452 node at I2C 0x38, kept `status = "disabled"`
  until the live Spes DTB resolves GPIO80 vs GPIO89 and confirms power
  sequencing. AVDD GPIO98 is represented by a fixed regulator and L9 is the
  I/O supply.
- Simple framebuffer candidate and 4 MiB ramoops reservation.

Not implemented or not verified:
- No active Type-C, charger, UFS, SD-card, USB, Wi-Fi, audio, camera, or
  display-panel driver nodes.
- No verified live RAM size, DTBO overlay selection, board revision, or boot
  hand-off.
- No claim that this candidate is safe to boot or flash.

The independent same-model hardware report supports the framebuffer address,
FocalTech FT5452 identification, GPIO98 AVDD and PM6125 L9 at 1.8 V. The
reset GPIO86 and likely IRQ GPIO80 are supported by downstream Spes/Khaje and
Tapas references, but the conflicting vendor interrupt property remains
unresolved. These sources do not replace the target phone's live FDT/DTBO.
The original upstream skeleton was last updated in the
referenced branch by commit `936aa708e5423d2d2ffba2ad5db7704d803782a0`, whose
message adds temporary `clk_ignore_unused` and `pd_ignore_unused` boot flags.
The next source-driven step is to compile this candidate against the repository's
pinned SM6225 kernel, then add one subsystem at a time with binding checks and
explicit evidence.


## Existing kernel configuration support

The pinned SM6225 base config already enables `CONFIG_DRM_SIMPLEDRM=y`,
`CONFIG_TOUCHSCREEN_EDT_FT5X06=y`, `CONFIG_USB_GADGET=y`,
`CONFIG_USB_DWC3=y`, and `CONFIG_USB_DWC3_DUAL_ROLE=y`. These are driver
availability facts only; device-tree nodes, power rails, and a working USB
gadget path still need to be validated. The base config currently has `CONFIG_PSTORE_RAM=m` and
`CONFIG_POWER_RESET_QCOM_PON=m`; the Spes candidate config will make both
built-in so ramoops and PMIC reset are available during early bring-up.


## Read-only handset evidence collection (Android root shell)

The repository includes `scripts/dump-spes-dtbo-readonly.sh`. Run it from a
root shell on the target phone, passing a writable output directory, for
example:

```sh
su -c 'sh /path/to/ubuntu-spes/scripts/dump-spes-dtbo-readonly.sh /sdcard/Download/spes-dtbo'
```

It selects the DTBO partition matching `ro.boot.slot_suffix`, refuses to
guess when the active slot cannot be identified, and reads the partition into
a file under the output directory. It never writes to a block device. Also run
`su -c 'sh /path/to/ubuntu-spes/scripts/collect-spes-device-info.sh'` to
capture the live FDT and partition metadata. Review both raw DTBO and FDT
files for serial/MAC values before sharing; the
text inventory redacts serial/MAC values from the kernel command line, but
the binary files are copied unchanged. Upload the reviewed DTBO image and FDT
here for overlay
selection, GPIO, regulator, panel and memory-map reconciliation.


## Why the touchscreen candidate is disabled

The Mainline driver source in the external SM6225 source mirror maps
`focaltech,ft5452` to a five-contact device and its binding accepts
`vcc-supply` and `iovcc-supply`. The next CI change will verify that the
pinned kernel archive contains the same compatible and binding.
The Android vendor driver instead uses the non-upstream `focaltech,fts`
compatible and a vendor `focaltech,max-touch-number` property; that node is
not copied. The candidate maps GPIO98 AVDD to a fixed enable regulator and
PM6125 L9 (1.8-2.0 V) to `iovcc-supply`. L9 is not marked always-on, so the
FT5452 consumer will request it when the disabled node is later enabled. The
candidate uses GPIO80 falling-edge
IRQ because it is supported by the Tapas reference and independent Spes test,
but one downstream Spes DT node says GPIO89. It therefore remains disabled
until the handset's live DTB/DTBO confirms the interrupt line and pinmux.

Reference driver/binding inspected in the SM6225 Mainline source mirror at
commit `467185042fc7a8e2da4589767dd0d7b8ddc422e8`:
- https://github.com/external-mirrors/sm6225-mainline-linux/blob/467185042fc7a8e2da4589767dd0d7b8ddc422e8/drivers/input/touchscreen/edt-ft5x06.c
- https://github.com/external-mirrors/sm6225-mainline-linux/blob/467185042fc7a8e2da4589767dd0d7b8ddc422e8/Documentation/devicetree/bindings/input/touchscreen/edt-ft5x06.yaml


## Critical memory-map gate before any boot

The older public SM6225 SoC DTSI reserves SMEM at 0x46000000/0x00200000,
CDSP secure memory at 0x46200000/0x01e00000, splash at 0x5c000000, and DFPS
at 0x5cf00000. An independent same-model Spes live-FDT report additionally
records a modem carveout at 0x4ab00000/0x06900000 and WLAN MSA at
0x51900000/0x00100000. Those two regions are not yet represented in this
candidate because the exact firmware/revision must be checked first. The
candidate is **not safe to boot** until the full memory and reserved-memory
map is reconciled with the handset's live FDT and DTBO.

The same external report records PM6125 USID0 and a power-on node at 0x800;
this candidate enables the standard PM6125 power key only. It does not copy
its volume-key mapping or modem/WLAN reservations.


## Do not mix the NFC variant (spesn)

A separate U-Boot DTS exists for **Redmi Note 11 NFC** (`spesn`):
https://github.com/SCOS100/u-boot/blob/d00de2bac93d0a68c609b19f7fdbfa34f1a16375/dts/upstream/src/arm64/qcom/sm6225-xiaomi-spesn.dts

It uses board ID `0x30022`, while the non-NFC `spes` source used here uses
`0x20022`. The NFC DTS selects framebuffer format `a8b8g8r8`, while the
non-NFC Spes source selects `a8r8g8b8`, and it includes a larger set of
peripheral nodes. Do not copy its board ID, panel,
firmware paths, or full regulator/device configuration into this `spes`
candidate. Shared PM6125/SM6225 nodes may be used only after cross-checking
against the non-NFC Spes source and the target phone's live FDT/DTBO.


## Alternative bootloader research lead

The related SM6225 Linux bring-up project for Redmi Pad SE (xun) lists a
U-Boot 2026.07 port with `xiaomi_spes_defconfig`, EFI loader, fastboot, UFS and
USB support as an alternative boot path:
https://github.com/xushengfeng/redmi_pad_se_xun_linux/blob/main/docs/RESOURCES.md

This is a project-reported lead, not a verified U-Boot build or boot test on
this non-NFC Redmi Note 11. The accessible GitHub U-Boot mirror contains a
`spesn` (NFC) DTS with board ID 0x30022, not the `spes` board ID 0x20022 used
here. Do not flash a U-Boot image or reuse its board configuration until the
exact non-NFC target is confirmed and a recovery path is tested.


Additional same-model hardware references (research leads; not a substitute for
the target phone's live data):
- https://github.com/AdyaGMD/ios-spes/blob/bdc2682efd6398f61185eab398361b066bf93794/docs/SPES-TOUCH-POWER.md
- https://github.com/AdyaGMD/ios-spes/blob/bdc2682efd6398f61185eab398361b066bf93794/docs/SPES-UPSTREAM-20261021.md


## Non-persistent boot-path lead

The independent same-model `SPES-UPSTREAM-20261021` report describes one
successful boot using an Android boot-image-v3 payload via `fastboot boot`.
This makes a non-persistent v3 boot test worth investigating before any
installation. It is not proof that the target phone's current bootloader,
slot, vendor_boot DTB hand-off or unlock state is identical. Do not flash or
write partitions based on that report.
