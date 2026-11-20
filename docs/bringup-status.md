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


## Latest verified CI result (2026-11-19)

- Workflow run #52: [Mainline kernel CI](https://github.com/game6789y-wq/ubuntu-spes/actions/runs/44513655587)
- Commit: `19995f4a4ae39f2fa7cfbd4a96f3e080ca7084e2`
- Overall result: **success**.
- Job: `Build SM6225 kernel and Spes DTS candidate` — success; all 12 build and artifact steps passed.
- Successful steps include kernel Image compilation, upstream FT5452/config checks, pinned Tapas reference DTB compilation, reserved-memory source audit, and compile-only `sm6225-xiaomi-spes.dtb` candidate compilation.
- Artifact: `spes-mainline-kernel-smoke-52` (18,353,579 bytes; expires 2026-11-26). The workflow collects the kernel Image, Spes DTB candidate, source DTS, kernel config/release metadata, source commit, README warning, and SHA256SUMS.
- The Spes DTB is included for offline inspection only. This compile result does not validate regulator voltages, live DTB/DTBO matching, memory map, bootloader hand-off, or physical boot. No initramfs, verified boot image, firmware bundle, or tested recovery procedure is included. Do not flash the artifact.

## Next blocking evidence

1. Obtain the exact handset's stock live FDT and DTBO read-only, then decode and inventory the DTB/overlays.
2. Confirm PM6125 rail IDs/voltages from that exact firmware and board revision. Public Spes downstream and Tapas reference sources disagree on L4/L18 use/voltage; keep the current declarations provisional.
3. Confirm memory/reserved-memory and framebuffer/ramoops addresses from the live FDT before enabling those nodes.
4. Only after the above, enable UFS and display/touch consumers and add `dtbs_check`/binding validation.
5. Verify boot/vendor_boot header, partition layout, DTB hand-off, and a safe non-persistent test-boot method before creating any boot image.
6. Once device evidence is collected, reconcile the candidate DTS against the live handset tree and add tests for any corrected hardware-specific values.


## CI workflow update (2026-11-20)

- Workflow run #56: [Mainline kernel CI](https://github.com/game6789y-wq/ubuntu-spes/actions/runs/44523414143) completed successfully for commit `3a8e07ce2ebb32c37e53d4dc05326361255231bb`. This verifies the revised path filters and existing compile-only checks.
- Commit `9853c7265fe61856eaa0f17b7c311bfa5dabf3d8` adds an advisory `dt-validate` pass against the pinned kernel's Devicetree bindings. The check is deliberately non-blocking while the candidate DTS is still being reconciled with the target handset; its log and exit status are collected in the CI artifact when available.
- Run #57 is queued: [Mainline kernel CI](https://github.com/game6789y-wq/ubuntu-spes/actions/runs/44726549638). Do not mark schema validation complete until this run finishes and its log has been reviewed.
- This is a schema-validation experiment, not a replacement for the kernel's full `dt_binding_check` / `dtbs_check` workflow and not evidence of electrical safety or device bootability.
