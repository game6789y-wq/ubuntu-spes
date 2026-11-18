# Ubuntu on Xiaomi Redmi Note 11 (spes)

> **Work in progress — mainline Linux bring-up. Not ready to boot or flash.**

This repository tracks an experimental native Linux port for the Xiaomi Redmi Note 11 4G (**spes**, Qualcomm Snapdragon 680 / SM6225).

The goal is to bring up a mainline Linux kernel first, then add device-specific support and an Ubuntu root filesystem. This is **not** Ubuntu running inside Android, Termux, or a proot container.

## Current status

| Area | Status |
|---|---|
| Repository and CI scaffold | Added |
| Generic ARM64 kernel smoke build | Passed (historical run #4) |
| SM6225 baseline-config kernel build | Passed (run #13) |
| `spes` Mainline device tree validation | Pending; no verified device-specific Mainline DTS yet |
| Boot chain / boot image format | Not verified |
| Display, touch, USB, storage, Wi-Fi, audio | Not tested |
| Ubuntu root filesystem | Not started |
| Boot on physical device | Not tested |

Run #13 successfully compiled the pinned SM6225 Mainline source with the SM6225 baseline config and uploaded artifact `spes-mainline-kernel-smoke-13` (18,342,586 bytes; retained for 7 days from 2026-11-18). This confirms the selected source/configuration can produce a kernel image; it does **not** prove that the image boots on the Redmi Note 11. [View Run #13](https://github.com/game6789y-wq/ubuntu-spes/actions/runs/44244665280).

## Hardware target

- Device: Xiaomi Redmi Note 11 4G (`spes`)
- SoC: Qualcomm Snapdragon 680 (SM6225)
- CPU architecture: ARM64
- GPU: Qualcomm Adreno 610

Different regional variants and board revisions may require different device-tree data. Do not assume that a device tree for Redmi Note 12 4G (`tapas`) is interchangeable with `spes`.

## Research notes

- [Mainline DTS research for SM6225 / spes](docs/mainline-dts-research.md)
- [Bring-up checklist and release gate](docs/bringup-status.md)

## Build

The GitHub Actions workflow compiles the pinned SM6225 Mainline source using a pinned SM6225 postmarketOS baseline configuration. It does not yet compile a verified `spes` Mainline DTB or produce a device-bootable image.

1. Open **Actions** in this repository.
2. Select **Mainline kernel CI**.
3. Choose **Run workflow**.
4. Download the build artifact after a successful run.

## Safety

- Do not flash artifacts from this repository.
- Do not overwrite `boot`, `vendor_boot`, `dtbo`, `vbmeta`, or other partitions.
- Do not use a `tapas` DTB on `spes`.
- Device boot-image header version, ABL behavior, memory map, DTB handoff, and partition layout must be verified from this exact device before any boot image is assembled.
- Initial device testing should use a verified non-persistent boot method where supported. No such image is provided yet.

## Roadmap

1. Validate the pinned mainline kernel source and ARM64 build toolchain in CI. **Current pinned source/config build passed in run #13.**
2. Validate the pinned SM6225 baseline configuration and identify its exact originating pmaports revision.
3. Obtain and inspect the `spes` Mainline device-tree sources.
4. Compare any candidate Mainline device tree with the stock `spes` DTB and hardware revisions.
5. Add a minimal, reviewable `spes` DTS and build DTBs.
6. Inspect the real boot chain and image format before creating any boot image.
7. Bring up serial/USB and storage, then display and touch.
8. Build an Ubuntu ARM64 root filesystem only after the kernel can boot reliably.

## References

- [SM6225 mainline kernel project](https://gitlab.postmarketos.org/sm6225-mainline)
- [postmarketOS SM6225 kernel package](https://pkgs.postmarketos.org/package/edge/postmarketos/aarch64/linux-postmarketos-qcom-sm6225)
- [Android device tree for Xiaomi Redmi Note 11](https://github.com/Jabiyeff/android_device_xiaomi_spes)
- [Related SM6225 bring-up for Redmi Note 12 4G (`tapas`)](https://github.com/Sype0/pmos-tapas) — reference only; not a drop-in port for `spes`.

## License

No license has been selected yet. Until one is added, all rights are reserved by default.


The current build uses the SM6225 baseline kernel configuration snapshot in `config/sm6225-base.config`. Its provenance and limitations are documented in [Mainline DTS research](docs/mainline-dts-research.md). A downstream `spes.dtsi` has been inspected for hardware clues, but no verified Mainline `spes` DTS has been added.
