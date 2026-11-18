# Additional SM6225 reference ports

This note records additional public projects that can guide source-level
research. None of these projects proves that its board DTS or boot flow is
compatible with Xiaomi Redmi Note 11 (spes).

## Motorola Moto G Play 2024 (fogona)

The public `W-Floyd/linux` project is described as carrying mainline work for
Motorola Moto G Play 2024 (`fogona`, SM6225 / Snapdragon 680), based on
`ivoszbg/linux-next v6.14rc5-khaje`. This makes it a useful *SoC/platform
reference* to inspect for SM6225/K haje support and driver enablement.

It is not a drop-in board reference:
- Motorola and Xiaomi boards can differ in PMIC population, regulators,
  memory reservations, display, touch, storage, and bootloader hand-off.
- Do not copy a fogona board DTS, memory map, boot image recipe, or firmware
  assumptions into spes.
- First compare the SoC-level DTSI and driver bindings against the pinned
  `stable-sm6225` source used by this repository. Record exact source commits
  before using any code.

Reference: https://github.com/W-Floyd/linux

## Independent spes firmware / hardware evidence

The public `AdyaGMD/ios-spes` project reports inspection of a Redmi Note 11
firmware build and documents boot/vendor_boot header v3, a DTB in
vendor_boot, DTBO overlays, and a FocalTech I2C touchscreen. It is valuable
as a source of *test leads* for the exact-device DTS comparison.

These observations are external project reports, not measurements made by
this repository. In particular, the active DTBO selection, RAM size,
reserved-memory map, panel, and bootloader behavior must not be marked
verified for every spes/spesn variant based on that report.

Reference: https://github.com/AdyaGMD/ios-spes

## Next source-inspection sequence

1. Inspect the exact commit/branch of `W-Floyd/linux` that contains fogona
   support and record the SoC DTSI files it uses.
2. Diff those SoC-level files against the pinned `stable-sm6225` kernel
   source; separate generic SM6225 support from Motorola-only board nodes.
3. Inspect the public spes firmware/device-tree sources for matching
   peripherals, then check each candidate against Mainline bindings/drivers.
4. Keep memory, reserved-memory, panel, touch, and boot-chain values
   unverified until tied to the target firmware or the exact handset.

No device-specific DTS, boot shim, flashable image, or release is produced
by this research note.
