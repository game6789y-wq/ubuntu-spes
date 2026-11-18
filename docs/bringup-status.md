# Redmi Note 11 (spes) bring-up checklist

This checklist is intentionally conservative. Mark an item complete only after a reproducible source inspection, CI result, or physical-device test.

## Source and build

- [ ] Confirm the pinned kernel archive is reachable and matches the recorded commit.
- [ ] Complete the generic ARM64 smoke build in GitHub Actions.
- [ ] Locate the exact `spes` SM6225 kernel config used by postmarketOS.
- [ ] Inspect the current SM6225 mainline DTS files and their include dependencies.
- [ ] Compare the mainline DTS with stock `spes` DTBs from the same hardware variant.
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
