# Mainline DTS work area

## Current candidate

`sm6225-xiaomi-spes.dts` is a minimal compile candidate derived from the
public early spes DTS in:

- Repository: https://github.com/external-mirrors/sm6225-mainline-linux
- Branch: `sm6225/v6.19-rc8`
- Pinned branch commit inspected: `467185042fc7a8e2da4589767dd0d7b8ddc422e8`
- Original board DTS blob: `4a2b84c19250adc18c79b67df38d7d6bb332e6fb`
- SoC DTSI blob: `a8386fc8b06a605d9ff83fcfc1afe17d7dbccc52`
- PM6125 DTSI blob in that source tree: `d0db28336fa9bb976abd831ed92adece4317149f`

The public board DTS is only a small early-boot skeleton. It includes
`sm6225.dtsi`, declares the board identity and XBL IDs, retains the bootloader
framebuffer at 0x5c000000, and reserves 4 MiB for ramoops at 0x5d000000. The
SoC DTSI contains a memory node whose size is expected to be filled by the
bootloader, plus SoC-level reserved-memory entries.

Our copy fixes the original spelling error `#adress-cells` to
`#address-cells` and removes the postmarketOS-only `pmos.nosplash` bootarg.
The two clock/power keep-alive flags remain temporary bring-up flags.

## Explicitly not implemented yet

- No PM6125 regulator tree or board-specific regulator votes.
- No I2C, FocalTech, Type-C, charger, UFS, SD-card, USB, Wi-Fi, audio, camera,
  or display-panel driver nodes.
- No verified live RAM size, DTBO overlay selection, board revision, or boot
  hand-off.
- No claim that this candidate is safe to boot or flash.

The independent same-model hardware report supports the framebuffer address
and FocalTech FT5452 identification, but does not replace the target phone's
own live FDT/DTBO. The next source-driven step is to compile this candidate
against the repository's pinned SM6225 kernel, then add one subsystem at a
time with binding checks and explicit evidence.
