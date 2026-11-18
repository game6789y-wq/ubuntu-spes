# SM6225 Mainline porting plan for Redmi Note 11 (spes)

## Why this reference matters

The public `Sype0/pmos-tapas` project is a practical Mainline bring-up reference for the same Qualcomm SM6225 / Khaje SoC family. Its README identifies the kernel base as the postmarketOS `sm6225-mainline` tree (`linux-v.7.2.1`, branch `stable-sm6225`, reported release 7.2.9) and says its base Kconfig is the SM6225 postmarketOS package configuration for Redmi Note 11 (`spes`).

Source: https://github.com/Sype0/pmos-tapas

## Source facts verified from the reference implementation

- Its `scripts/build.sh` pins kernel archive commit
  `b8463e4b9111517f89da970d1e1145b851ce8d48`.
- It builds with LLVM (`ARCH=arm64 LLVM=1`) and applies a base config plus a small device-specific config fragment.
- Its `config/base.config` is the same Git blob already used by this repository's
  `config/sm6225-base.config`: `d234c5df781cf688b2da9b83f6b63404c9d1600e`.
  This confirms the provenance of our baseline configuration.
- Its device-tree directory contains four **tapas** variants:
  `sm6225-xiaomi-tapas.dts`,
  `sm6225-xiaomi-tapas-audio.dts`,
  `sm6225-xiaomi-tapas-display.dts`, and
  `sm6225-xiaomi-tapas-safe.dts`.
- The reference project uses a bring-up initramfs, early framebuffer console,
  USB CDC ACM serial shell, and ramoops/pstore for crash logs.
- The reference README says its boot shim is needed for the **tapas**
  bootloader hand-off: ABL supplies a DTB from `vendor_boot`, so the shim
  switches to the project's own DTB before entering Mainline Linux.

Source files:
- https://github.com/Sype0/pmos-tapas/blob/main/scripts/build.sh
- https://github.com/Sype0/pmos-tapas/blob/main/config/base.config
- https://github.com/Sype0/pmos-tapas/blob/main/config/tapas.config
- https://github.com/Sype0/pmos-tapas/tree/main/dts

## What we apply to this spes project

1. Keep `config/sm6225-base.config` as the reproducible SM6225 kernel baseline.
   Its blob identity matches the reference project's base config.
2. Keep the existing GitHub Actions kernel compile as a kernel/config smoke
   test. It proves compilation only; it does not prove board support.
3. Use the reference project's build structure as a design guide for a later
   initramfs-based bring-up: early logs, USB serial access, and persistent
   crash logs are useful diagnostics once their resources and drivers are
   confirmed for this phone.
4. Maintain a separate `spes` device config fragment rather than modifying
   the shared SoC baseline for board-only settings.
5. Use the pinned tapas DTS only as an SM6225/PM6125 SoC/PMIC reference: its
   header says it follows the spes board layout and shares most PMIC, charger,
   Type-C and I2C hardware. Do not copy its memory map, panel, boot shim or
   board-specific values.
6. Reconcile the separate downstream spes tree's Max77729/SC8551 declarations
   against the BQ25890/SM5602/No-PMI stack in the tapas reference; the sources
   may reflect different revisions or complementary components.
7. Use the independently tested FocalTech ID 54:52 as a candidate for the
   upstream `focaltech,ft5452` driver (already enabled in the baseline config),
   but resolve GPIO80 vs GPIO89 IRQ mapping from the live FDT before adding it.

## What we explicitly do not copy

- Do not use any `sm6225-xiaomi-tapas*.dts` file as a `spes` DTS.
- Do not copy the tapas shim, load address `0x80000000`, memory map,
  6 GB RAM assumptions, ABL hand-off assumptions, or boot-image v4 layout.
- Do not assume that the tapas `fastboot boot` behavior applies to spes.
- Do not copy its `tapas.config` wholesale; options such as command line,
  framebuffer, ramoops address, USB serial, and peripheral selection require
  independent validation for spes.
- Do not publish or flash any image based only on a successful kernel build.

The Redmi Note 11 Android `BoardConfig.mk` evidence currently available
reports boot header v3 and a separate DTBO build input. This differs from the
tapas project's documented v4 path, but Android build metadata is not enough
to establish the live bootloader hand-off. Read the target phone's boot,
vendor_boot, DTBO, and firmware metadata before choosing an image format.

## Ordered implementation plan

### Phase A — reproducible kernel baseline
- [x] Use the SM6225 postmarketOS base config snapshot.
- [x] Compile the pinned Mainline source in GitHub Actions (historical run #13).
- [ ] Record the exact kernel source archive commit used by this repository's CI
      alongside the config blob hash.
- [ ] Add a config-diff report between the SoC base config and a future
      spes-specific fragment.

### Phase B — board evidence
- [x] Inspect public downstream `spes.dtsi` and `khaje.dtsi` as reference only.
- [x] Inspect public Android BoardConfig and prebuilt Khaje DTB metadata.
- [ ] Decode the real DTBO binary and inventory overlays.
- [ ] Obtain the live FDT/DTBO from the target handset read-only.
- [ ] Confirm exact RAM size, PMIC IDs, regulators, GPIOs, storage, display,
      touch, USB-C, WLAN, and board revision.

### Phase C — minimal Mainline board description
- [x] Locate the exact SM6225 Mainline SoC DTSI include through the pinned
      tapas reference DTS (`sm6225.dtsi`) and identify PM6125 include.
- [ ] Inspect the full pinned `sm6225.dtsi` and `pm6125.dtsi` contents and
      compare inherited nodes against the exact spes stock DTB/DTBO.
- [ ] Create a minimal `spes` DTS only after the live board data is known; do not rename the tapas DTS.
- [ ] Compile the DTB and run `dtbs_check` where applicable.
- [ ] Review reserved-memory and memory nodes against the real firmware.

### Phase D — diagnostic boot path
- [ ] Verify the actual boot/vendor_boot header and ABL DTB hand-off.
- [ ] Prefer a non-persistent boot method only if the exact device supports it.
- [ ] Add serial/framebuffer diagnostics only after the relevant hardware
      resources are confirmed.
- [ ] Test recovery back to the original OS before any installation path.

### Phase E — Ubuntu userspace
- [ ] Build an ARM64 Ubuntu root filesystem after kernel boot and storage work.
- [ ] Mount rootfs from a safe external medium first.
- [ ] Add networking and display after basic console and storage are stable.

## Current gate

The project remains at Phase A plus public-source research in Phase B.
No board-specific Mainline DTS, boot image, Ubuntu root filesystem, or
flashable release is ready. Do not treat the reference project's bootable
artifacts or boot instructions as compatible with Redmi Note 11.


## Additional source reconciliation (2026-11-18)

- The pinned `Sype0/pmos-tapas` DTS includes `sm6225.dtsi` and
  `pm6125.dtsi`; its header says its layout follows the Redmi Note 11
  `spes` board and shares most PMIC, charger, Type-C and I2C buses.
- The tapas DTS and config use BQ25890 + SM5602 + No-PMI charging policy.
  A separate downstream spes DTS declares Max77729 and SC8551. Do not
  assume these are mutually exclusive; resolve the firmware revision and
  complete live DTB/DTBO before writing charging nodes.
- Independent same-model hardware testing reports FocalTech ID `54:52`.
  Mainline maps it to `focaltech,ft5452` (five touch points), and the
  baseline config already builds `CONFIG_TOUCHSCREEN_EDT_FT5X06=y`.
  The IRQ line is unresolved because the downstream DT node says GPIO89
  while its separate irq-gpio property and the independent test say GPIO80.
- The CI will compile the pinned tapas reference DTB as a syntax/source
  integration check only. It will not publish that DTB as a spes image.
