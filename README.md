# Ubuntu on Xiaomi Redmi Note 11 (spes)

> **Work in progress — mainline Linux bring-up. Not ready to boot or flash.**

This repository tracks an experimental native Linux port for the Xiaomi Redmi Note 11 4G (**spes**, Qualcomm Snapdragon 680 / SM6225).

The goal is to bring up a mainline Linux kernel first, then add device-specific support and an Ubuntu root filesystem. This is **not** Ubuntu running inside Android, Termux, or a proot container.

## Current status

| Area | Status |
|---|---|
| Repository and CI scaffold | Added |
| Generic ARM64 kernel smoke build | Passed (historical run #4) |
| SM6225 baseline-config kernel build | Passed (run #48) |
| `spes` DTS candidate compile | Passed (run #48; compile-only, not hardware-validated) |
| Boot chain / boot image format | Not verified |
| Display, touch, USB, storage, Wi-Fi, audio | Not tested |
| Ubuntu root filesystem | Not started |
| Boot on physical device | Not tested |

Run #48 successfully compiled the pinned SM6225 Mainline kernel, passed the upstream FT5452/config checks, compiled the pinned `tapas` reference DTB, audited reserved-memory source definitions, and compiled the current `spes` DTS candidate. The uploaded artifact is `spes-mainline-kernel-smoke-48` (18,338,041 bytes; expires 2026-11-25). It contains the kernel smoke-build outputs, **not** the `spes` DTB, initramfs, or a boot image. A successful DTS compile proves syntax/phandle integration only; it does **not** validate regulator values, bootability, or hardware operation. [View Run #48](https://github.com/game6789y-wq/ubuntu-spes/actions/runs/44272951114).

## Hardware target

- Device: Xiaomi Redmi Note 11 4G (`spes`)
- SoC: Qualcomm Snapdragon 680 (SM6225)
- CPU architecture: ARM64
- GPU: Qualcomm Adreno 610

Different regional variants and board revisions may require different device-tree data. Do not assume that a device tree for Redmi Note 12 4G (`tapas`) is interchangeable with `spes`.

## Research notes

- [Mainline DTS research for SM6225 / spes](docs/mainline-dts-research.md)
- [spes hardware reference matrix](docs/spes-hardware-reference-matrix.md)
- [Mainline DTS and touchscreen source reconciliation](docs/mainline-dts-research.md)
- [SM6225 Mainline implementation and porting plan](docs/sm6225-mainline-porting-plan.md)
- [spes Android BoardConfig and DTB audit (reference only)](docs/spes-boardconfig-audit.md)
- [Additional SM6225 reference ports](docs/sm6225-reference-ports.md)
- [Bring-up checklist and release gate](docs/bringup-status.md)

## Build

The GitHub Actions workflow compiles the pinned SM6225 Mainline source using the postmarketOS baseline configuration and checks the built-in FocalTech driver. It compiles both the pinned `tapas` reference DTB and the current `spes` DTS candidate. The latter is a compile-only candidate, not a hardware-validated board description. Neither DTB is included in the smoke artifact, and the workflow does not produce a device-bootable image.

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

1. Validate the pinned mainline kernel source and ARM64 build toolchain in CI. **Kernel build passed in run #48.**
2. Validate the pinned SM6225 baseline configuration and identify its exact originating pmaports revision.
3. Obtain and inspect the `spes` Mainline device-tree sources.
4. Compare any candidate Mainline device tree with the stock `spes` DTB and hardware revisions.
5. Continue reducing the `spes` DTS to a hardware-evidenced minimal board description; the current candidate compiles in run #48 but is not yet validated against the live stock FDT.
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


The current build uses the SM6225 baseline kernel configuration snapshot in `config/sm6225-base.config`. Its provenance and limitations are documented in [Mainline DTS research](docs/mainline-dts-research.md). A candidate Mainline `spes` DTS is now compiled by CI, but it remains unverified against the exact phone's live FDT/DTBO and must not be treated as bootable.
