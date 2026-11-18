# Redmi Note 11 (spes) bring-up checklist

This checklist is intentionally conservative. Mark an item complete only after a reproducible source inspection, CI result, or physical-device test.

## Source and build

- [x] Confirm the pinned kernel archive is reachable and matches the recorded commit (run #13 fetched the pinned archive and compiled it).
- [x] Complete the generic ARM64 smoke build in GitHub Actions (run #4 succeeded; generic smoke build only).
- [x] Pin the SM6225 baseline config snapshot used by the pmos-tapas project (source commit `c5b6ab106f8277908a56b77a6a595d4ad0531dba`; config blob SHA matches the reference implementation).
- [ ] Identify the exact originating postmarketOS pmaports commit for that config.
- [x] Inspect the pinned SM6225 Mainline DTS files and include dependencies sufficiently to compile the current candidate.
- [x] Inspect the downstream `spes.dtsi` / `khaje.dtsi` vendor reference; documented as non-portable source material in `mainline-dts-research.md`.
- [x] Reconcile charger/USB-C clues across the downstream spes tree and tapas reference; record source disagreement and avoid selecting a topology before live DTB/DTBO inspection.
- [x] Trace the inherited FocalTech touchscreen node; independent same-model hardware notes report ID 54:52, matching Mainline `focaltech,ft5452`; IRQ mapping remains unresolved (GPIO80 vs GPIO89).
- [x] Confirm `CONFIG_TOUCHSCREEN_EDT_FT5X06=y` is already built into the pinned SM6225 baseline config.
- [x] Inspect the pinned tapas reference DTS: it includes the SM6225 and PM6125 SoC/PMIC DTSI files and states it follows the spes board layout; do not copy its board-specific values.
- [x] Add a CI-only compile test for the pinned tapas reference DTB; run #48 passed (reference-only, not a spes DTB).
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


## Latest verified CI result (2026-11-18)

- Workflow run #48: [Mainline kernel CI](https://github.com/game6789y-wq/ubuntu-spes/actions/runs/44272951114)
- Commit: `7f5953a8cd65bef707b4e20be21add9caf476936`
- Overall result: **success**.
- Job: `Build SM6225 kernel and Spes DTS candidate` — success.
- Successful steps include kernel Image compilation, upstream FT5452/config checks, pinned Tapas reference DTB compilation, reserved-memory source audit, and compile-only `sm6225-xiaomi-spes.dtb` candidate compilation.
- Artifact: `spes-mainline-kernel-smoke-48` (18,338,041 bytes; expires 2026-11-25). The artifact does not include the Spes DTB, initramfs, or a boot image.
- This is the first verified CI pass for the current Spes DTS candidate after the missing `pm6125_l4` / `pm6125_l18` phandle error. It confirms compile-time integration only, not correct regulator voltages, correct live DTB hand-off, or physical boot.

## Next blocking evidence

1. Obtain the exact handset's stock `vendor_boot`, `dtbo`, and live FDT read-only, then decode and inventory the DTB/overlays.
2. Confirm PM6125 rail IDs/voltages from that exact firmware and board revision. Public Spes downstream and Tapas reference sources disagree on L4/L18 use/voltage; keep the current declarations provisional.
3. Confirm memory/reserved-memory and framebuffer/ramoops addresses from the live FDT before enabling those nodes.
4. Only after the above, enable UFS and display/touch consumers and add `dtbs_check`/binding validation.
5. Verify the boot header and DTB hand-off before creating any non-persistent test image.
