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

## Explicitly not implemented yet

- Includes the PM6125 base DTSI and a minimal L9 (1.8-2.0 V) regulator
  declaration used by the touchscreen candidate; this is not the full PMIC
  regulator tree.
- Enables the QUPv3 SE2 / Mainline `i2c2` bus with a 19.2 MHz source clock.
- Contains an upstream FocalTech FT5452 node at I2C 0x38, but leaves it
  `status = "disabled"` until the live Spes DTB resolves GPIO80 vs GPIO89 and
  confirms the power sequence. Its AVDD GPIO98 is represented by a fixed
  regulator and L9 is the I/O supply.
- No active Type-C, charger, UFS, SD-card, USB, Wi-Fi, audio, camera, or
  display-panel driver nodes.
- No verified live RAM size, DTBO overlay selection, board revision, or boot
  hand-off.
- No claim that this candidate is safe to boot or flash.

The independent same-model hardware report supports the framebuffer address,
FocalTech FT5452 identification, GPIO98 AVDD, GPIO86 reset, GPIO80 IRQ and
PM6125 L9 at 1.8 V, but does not replace the target phone's own live FDT/DTBO.
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
gadget path still need to be validated. The base config currently has
`CONFIG_PSTORE_RAM=m`; the Spes candidate config will make it built-in so the
ramoops region can be used during early bring-up.


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
`scripts/collect-spes-device-info.sh` to capture the live FDT and partition
metadata. Upload the resulting DTBO image and FDT here for overlay selection,
GPIO, regulator, panel and memory-map reconciliation.
