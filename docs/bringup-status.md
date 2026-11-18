# Redmi Note 11 (spes) bring-up checklist

This checklist is intentionally conservative. Mark an item complete only after a reproducible source inspection, CI result, or physical-device test.

## Source and build

- [x] Confirm the pinned kernel archive is reachable and matches the recorded commit (run #13 fetched the pinned archive and compiled it).
- [x] Complete the generic ARM64 smoke build in GitHub Actions (run #4 succeeded; generic smoke build only).
- [x] Pin the SM6225 baseline config snapshot used by the pmos-tapas project (source commit `c5b6ab106f8277908a56b77a6a595d4ad0531dba`; config blob SHA matches the reference implementation).
- [ ] Identify the exact originating postmarketOS pmaports commit for that config.
- [ ] Inspect the current SM6225 Mainline DTS files and their include dependencies (still open; no confirmed `spes` Mainline DTS found).
- [x] Inspect the downstream `spes.dtsi` / `khaje.dtsi` vendor reference; documented as non-portable source material in `mainline-dts-research.md`.
- [x] Compare board-level charger/USB-C/SD-card declarations in downstream `spes.dtsi` against the tapas Mainline reference; record mismatches and candidate GPIOs in `spes-hardware-reference-matrix.md`.
- [x] Audit a public `spes/spesn` Android `BoardConfig.mk` (branch `sixteen-qpr2`); boot header v3, separate DTBO, and `khaje.dtb` build input recorded as Android build evidence only in `spes-boardconfig-audit.md`.
- [x] Fetch and inspect the prebuilt `dtb/khaje.dtb` FDT header and trace its generic downstream `khaje.dts` / `khaje.dtsi` source; not a board-specific Mainline DTS.
- [ ] Decode and inventory the prebuilt `dtbo.img` and identify each overlay (GitHub text endpoint exposed only the blob SHA, not binary bytes). A read-only parser is now available at `scripts/inspect_android_dt_table.py` for use once the binary is obtained.
- [ ] Obtain the exact live stock DTB/DTBO from the target handset using read-only methods.
- [ ] Compare the mainline DTS with stock `spes` DTBs from the same hardware variant.
- [x] Build the pinned Mainline source with the SM6225 baseline config (run #13 succeeded; artifact `spes-mainline-kernel-smoke-13`).
- [x] Inspect the pmos-tapas build implementation and confirm the identical SM6225 base-config blob; record transferable diagnostics ideas and non-transferable tapas DTS/boot-shim assumptions in `sm6225-mainline-porting-plan.md`.
- [ ] Record all local patches with source links and rationale.

## Device-specific validation

- [ ] Identify exact model / board revision and RAM size.
- [ ] Inspect bootloader version and current slot.
- [ ] Inspect `boot`, `vendor_boot`, `dtbo`, and `vbmeta` metadata without writing to them.
- [ ] Confirm boot image header version and DTB hand-off behavior.
- [ ] Confirm memory map and reserved-memory regions.
- [ ] Confirm a safe, non-persistent boot method is supported.

## Hardware bring-up

- [ ] Early console / serial
- [ ] USB gadget or USB serial
- [ ] UFS storage
- [ ] Display / framebuffer / DRM
- [ ] Touchscreen
- [ ] Battery and charging
- [ ] Wi-Fi / Bluetooth
- [ ] Audio
- [ ] Suspend / resume

## Ubuntu userspace

- [ ] Kernel boots repeatedly without Android userspace.
- [ ] Root filesystem mounts reliably.
- [ ] Basic networking works.
- [ ] A supported display stack is available.
- [ ] Recovery path back to the original OS is documented and tested.

## Release gate

No flashable image or GitHub Release should be published until the boot chain, device tree, partition layout, and recovery procedure have been verified on the exact target device.

## Boot-chain research note

An Android device-tree build configuration for `spes` references boot image header version 3. This is useful evidence, but it is not a substitute for reading the actual boot/vendor_boot images and bootloader behavior from the target phone. Do not copy the `tapas` v4 shim approach without that verification.

Reference: [Evolution-X device_xiaomi_spes BoardConfig.mk](https://github.com/Evolution-X-Devices/device_xiaomi_spes/blob/bka/BoardConfig.mk).


## External hardware evidence (not locally verified)

A third-party `spes` bring-up report describes boot/vendor_boot header v3 and a vendor_boot DTB plus DTBO overlays for one firmware build. Use this only to guide read-only inspection on the target handset. The local boot chain, DTB selection, memory map, and RAM variant remain unverified.
