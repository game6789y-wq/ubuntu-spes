# Ubuntu on Xiaomi Redmi Note 11 (spes)

> **Work in progress — mainline Linux bring-up. Not ready to boot or flash.**

This repository tracks an experimental native Linux port for the Xiaomi Redmi Note 11 4G (**spes**, Qualcomm Snapdragon 680 / SM6225). The goal is to bring up a mainline Linux kernel, validate device-specific hardware support, and then add an Ubuntu ARM64 root filesystem.

This is **not** Ubuntu running inside Android, Termux, or a proot container.

## Current status

| Area | Status |
|---|---|
| Repository and GitHub Actions CI | Working |
| SM6225 baseline kernel build | Passed (run #52) |
| Spes DTS candidate compilation | Passed (run #52; compile-only) |
| Spes DTB candidate in CI artifact | Included (run #52; not hardware-validated) |
| Boot chain / boot image format | Not verified on the target handset |
| Live stock DTB / DTBO comparison | Pending |
| PM6125 regulator values and board revision | Pending verification |
| UFS, display, touchscreen, USB, Wi-Fi, audio | Not tested on device |
| Ubuntu ARM64 root filesystem | Not started |
| Physical-device boot | Not tested |

### Latest CI result

[Run #52 — Mainline kernel CI](https://github.com/game6789y-wq/ubuntu-spes/actions/runs/44513655587) completed successfully on 2026-11-19.

The job passed all 12 steps, including:
- Pinned SM6225 Mainline kernel source fetch and ARM64 kernel Image compilation.
- Upstream FT5452 touchscreen driver and kernel-config checks.
- Pinned Tapas reference DTB compilation (reference only; not a Spes DTB).
- Reserved-memory source audit.
- Compile-only Spes DTS candidate compilation.
- Smoke artifact collection and upload.

Artifact: `spes-mainline-kernel-smoke-52` (18,353,579 bytes; expires 2026-11-26). The workflow is configured to include:
- `Image` — kernel build output.
- `sm6225-xiaomi-spes-candidate.dtb` — compile-only, unvalidated Spes DTB candidate.
- `sm6225-xiaomi-spes.dts` — source DTS used for the candidate.
- `kernel.config`, `kernel.release`, and `source-commit.txt`.
- `README.txt` and `SHA256SUMS`.

A successful compile proves build-time syntax and dependency integration only. It does **not** establish correct regulator voltages, memory layout, bootloader DTB hand-off, device compatibility, or physical boot. The artifact contains no initramfs, verified boot image, firmware bundle, or tested recovery procedure. **Do not flash any artifact from this repository.**

## Hardware target

- Device: Xiaomi Redmi Note 11 4G (`spes`)
- SoC: Qualcomm Snapdragon 680 (SM6225)
- CPU architecture: ARM64
- GPU: Qualcomm Adreno 610

Keep `spes` distinct from Redmi Note 12 4G (`tapas`). Do not assume that a Tapas device tree, boot shim, memory map, or board-specific regulator configuration is interchangeable with Spes. Different regional variants and board revisions may also require different data.

## Research and bring-up documents

- [Mainline DTS research for SM6225 / spes](docs/mainline-dts-research.md)
- [Spes hardware reference matrix](docs/spes-hardware-reference-matrix.md)
- [SM6225 Mainline implementation and porting plan](docs/sm6225-mainline-porting-plan.md)
- [Spes Android BoardConfig and DTB audit (reference only)](docs/spes-boardconfig-audit.md)
- [Additional SM6225 reference ports](docs/sm6225-reference-ports.md)
- [Bring-up checklist and release gate](docs/bringup-status.md)
- [Device inventory and read-only evidence collection](docs/device-inventory.md)

## Build

The GitHub Actions workflow builds the pinned SM6225 Mainline kernel with the repository's baseline configuration, checks the upstream FT5452 driver/configuration, compiles the pinned Tapas reference DTB, audits reserved-memory source definitions, and compiles the current Spes DTS candidate.

To run it:
1. Open **Actions** in this repository.
2. Select **Mainline kernel CI**.
3. Choose **Run workflow**.
4. After a successful run, open its summary and download the `spes-mainline-kernel-smoke-<run number>` artifact.

The workflow is a smoke-build and DTS compile check, not a device image/release pipeline.

## Next blockers

1. Collect the exact target handset's model, board revision, RAM, slot and boot properties.
2. Obtain the live stock FDT and DTBO read-only; compare their nodes and overlays with the candidate.
3. Resolve the PM6125 L4/L18 rail mapping and voltages against the exact firmware and board revision. Public downstream Spes and Tapas reference sources disagree, so current candidate declarations remain provisional.
4. Verify memory/reserved-memory, framebuffer and ramoops addresses from the live device tree.
5. Verify boot/vendor_boot header, DTB hand-off, partition layout and a safe non-persistent test-boot method.
6. Only then proceed to storage, display, touch, networking and Ubuntu userspace bring-up.

For phone-only evidence collection, see [docs/device-inventory.md](docs/device-inventory.md) and the read-only script [scripts/collect-spes-device-info.sh](scripts/collect-spes-device-info.sh). Review generated reports for personal identifiers before sharing them.

## Safety

- Do not flash artifacts from this repository.
- Do not overwrite `boot`, `vendor_boot`, `dtbo`, `vbmeta`, UFS, or other partitions.
- Do not use a `tapas` DTB on `spes`.
- Do not treat the current PMIC rail values, memory map, framebuffer, or ramoops addresses as verified.
- No flashable image or GitHub Release should be published until the boot chain, exact-device tree, partition layout, and recovery procedure have been verified on the target handset.

## References

- [SM6225 Mainline kernel project](https://gitlab.postmarketos.org/sm6225-mainline)
- [postmarketOS SM6225 kernel package](https://pkgs.postmarketos.org/package/edge/postmarketos/aarch64/linux-postmarketos-qcom-sm6225)
- [Android device tree for Xiaomi Redmi Note 11](https://github.com/Jabiyeff/android_device_xiaomi_spes)
- [Related SM6225 bring-up for Redmi Note 12 4G (`tapas`)](https://github.com/Sype0/pmos-tapas) — reference only, not a drop-in Spes port.

## License

No license has been selected yet. Until one is added, all rights are reserved by default.
