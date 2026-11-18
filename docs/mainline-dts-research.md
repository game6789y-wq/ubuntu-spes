# Mainline DTS research: Redmi Note 11 (spes)

## Confirmed target identity

- Device: Xiaomi Redmi Note 11, codenames `spes` / `spesn`.
- SoC: Qualcomm SM6225 (Snapdragon 680).
- Qualcomm platform/board family reported by Android device configuration: `bengal`.
- The device tree repository identifies the device as SM6225 and lists Adreno 610 and UFS 2.2.

These identifiers narrow the search, but they do not provide a Linux device tree for the phone.

## Mainline kernel source lead

The `Sype0/pmos-tapas` project documents a Mainline SM6225 kernel based on the `sm6225-mainline` project, kernel version `linux-v.7.2.1`, branch `stable-sm6225`. Its README says the kernel base configuration comes from the postmarketOS kernel package/configuration for Redmi Note 11 (`spes`).

This is a useful lead for the kernel source and baseline Kconfig. It is not proof that the project's `tapas` device tree or boot procedure works on `spes`.

Reference: https://github.com/Sype0/pmos-tapas

## What must not be copied from tapas

The tapas project has a device-specific DTS and a boot shim designed around the Redmi Note 12 4G bootloader behavior. Its README describes an Android boot image v4 path where ABL supplies the DTB from `vendor_boot`, requiring a shim to hand off a different DTB.

That behavior is specific to the tested tapas device. Do not copy its DTS, shim, memory map, RAM size, boot-image assumptions, or fastboot instructions to spes without independent evidence from the exact spes hardware and bootloader.

Reference: https://github.com/Sype0/pmos-tapas

## Android vendor references (not Mainline DTS)

The Evolution-X `device_xiaomi_spes` BoardConfig reports:
- `TARGET_BOARD_PLATFORM := bengal`
- downstream kernel source `kernel/xiaomi/sm6225`
- downstream kernel version `4.19`
- `vendor/spes-perf_defconfig`
- `BOARD_BOOT_HEADER_VERSION := 3`
- `BOARD_INCLUDE_DTB_IN_BOOTIMG := true`
- `BOARD_KERNEL_SEPARATED_DTBO := true`

These are Android build settings for that source tree, not a verified dump of the stock phone's boot images or bootloader behavior. They must not be treated as the final Linux boot-image specification.

Reference: https://github.com/Evolution-X-Devices/device_xiaomi_spes/blob/bka/BoardConfig.mk

## Current conclusion

- A reusable SM6225 Mainline kernel/configuration lead exists.
- The exact `spes` Mainline DTS, its include dependencies, and its board-specific status still need direct inspection in the pinned kernel source.
- No `spes` DTS or boot shim has been authored in this repository yet.
- Generic ARM64 CI success does not validate device support.

## Next verification tasks

1. Inspect the pinned `stable-sm6225` kernel source under `arch/arm64/boot/dts/qcom/` for SM6225 and `spes`-related DTS files.
2. Inspect the postmarketOS `spes` kernel package and its exact config fragments; record immutable source revisions.
3. Compare any candidate DTS with DTBs extracted read-only from the exact phone.
4. Identify RAM variant, PMIC, display panel, touch controller, UFS, Wi-Fi, and regulator topology before enabling device-specific nodes.
5. Read boot/vendor_boot/dtbo metadata from the phone before selecting an image format or boot method.

No flashable image or release is permitted until the release gate in `bringup-status.md` is satisfied.
