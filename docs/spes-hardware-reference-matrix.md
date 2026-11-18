# Redmi Note 11 (spes) hardware reference matrix

This document separates public downstream Android declarations from the
Mainline reference implementation. None of these public source files is a
substitute for the live DTB/DTBO and exact hardware revision of the target
phone.

## Evidence inspected

| Source | Revision / blob | What it is |
|---|---|---|
| `Jabiyeff/kernel_xiaomi_sm6225` `arch/arm64/boot/dts/vendor/qcom/spes.dtsi` | blob `cc5dbd5e58468a15631e0da559486b1323e91a65` | Downstream vendor board overrides for spes |
| Same repository `khaje-idp.dtsi` | blob `f7bb7786d7306f26e414ebb593c90c40c81a2e8f` | Included downstream base containing the FocalTech touchscreen node |
| Same repository `khaje.dtsi` | blob `e57c487190dc50acbfcc56b3af437d9150d3253f` | Downstream Khaje SoC description |
| `Sype0/pmos-tapas` `dts/sm6225-xiaomi-tapas.dts` | blob `581500e63039f8f2970103b2918386cc9d56d6a2` | Mainline-oriented tapas board DTS; reference only |
| `Sype0/pmos-tapas` `dts/sm6225-xiaomi-tapas-audio.dts` | blob `e4d568ddbc3184ba49306f79b2ffef18dce5044f` | Optional tapas audio variant; comments compare parts with spes |

Source URLs:
- https://github.com/Jabiyeff/kernel_xiaomi_sm6225/blob/6c2b3e7528a0778cd80c95eabb490746b5422f8c/arch/arm64/boot/dts/vendor/qcom/spes.dtsi
- https://github.com/Jabiyeff/kernel_xiaomi_sm6225/blob/6c2b3e7528a0778cd80c95eabb490746b5422f8c/arch/arm64/boot/dts/vendor/qcom/khaje-idp.dtsi
- https://github.com/Jabiyeff/kernel_xiaomi_sm6225/blob/6c2b3e7528a0778cd80c95eabb490746b5422f8c/arch/arm64/boot/dts/vendor/qcom/khaje.dtsi
- https://github.com/Sype0/pmos-tapas/blob/main/dts/sm6225-xiaomi-tapas.dts
- https://github.com/Sype0/pmos-tapas/blob/main/dts/sm6225-xiaomi-tapas-audio.dts

## Board-specific clues from the downstream spes file

| Block | Public downstream declaration | Assessment for Mainline port |
|---|---|---|
| USB-C / MUIC | `max77729@66`, compatible `maxim,max77729`, on `qupv3_se1_i2c` | Strong board clue; confirm live bus/address/IRQ and check Mainline binding/driver |
| Max77729 interrupt | TLMM GPIO105; vendor interrupt encoding `<0x69 0x08>` | Candidate GPIO only; translate trigger flags using binding and verify from live FDT |
| Secondary charger | `sc8551-charger@65`, compatible `sc,sc8551-standalone` | Vendor-only compatible in this file; check for a supported Mainline driver/binding before enabling |
| SC8551 interrupt | TLMM GPIO84 | Candidate GPIO only; confirm polarity and pinctrl on the target |
| SD card detect | `cd-gpios = <&tlmm 88 0>` under `sdhc_2` | Useful candidate for SD-card support; verify polarity and whether the handset variant has the slot |
| Touchscreen | Vendor base declares FocalTech at I2C `0x38`; downstream values include AVDD GPIO98, reset GPIO86, IRQ GPIO80/89 conflict, and 1080x2400. Independent same-model test reads chip ID `54:52` | Strong candidate for Mainline `focaltech,ft5452`; Mainline driver supports max 5 points. Resolve IRQ and power mapping from live FDT before writing node |
| One-wire accessory | GPIO108 vendor node | Vendor-specific feature; out of initial bring-up scope |
| Charger policy | `qcom,nopmi-chg` node with board thermal/charge policy | Vendor-specific binding and policy; do not copy into Mainline without a matching upstream binding/driver |

Important: `spes.dtsi` includes `khaje-idp.dtsi`. The complete inherited device tree,
including PMIC and regulators, must be resolved before treating this override
file as a complete board description.

## Cross-check against the tapas Mainline reference

The pinned `Sype0/pmos-tapas` README explicitly says the tapas board DTS is
laid out like the Redmi Note 11 (`spes`) board and shares most of its PMIC,
charger, Type-C controller and I2C buses. Its DTS describes BQ25890 at I2C
0x6a and SM5602 at 0x71, while its config calls this the "spes charger stack"
(SM5602 fuel gauge plus No-PMI policy). This is strong evidence that these
parts are relevant to the spes bring-up.

However, the separate downstream `Jabiyeff/kernel_xiaomi_sm6225` `spes.dtsi`
also declares Max77729 (with nested charger/fuel-gauge functions) and SC8551
at I2C 0x65. The public sources therefore do not yet establish whether these
are additional fast-charge/Type-C components, a different firmware/board
revision, or an alternate vendor implementation. Do not treat this as a
simple mutually-exclusive topology. Do not copy any charger thresholds,
interrupts, or regulator settings until the exact live DTB/DTBO and hardware
revision are reconciled.

The tapas DTS also contains a hard-coded memory map, framebuffer address,
ramoops reservation, panel details, and board IDs. Those values are specific
to that reference phone and must not be reused for spes.

The tapas audio variant says that some codec/LPASS hardware is shared with
the SM6225 Mainline spes board. Treat this as a lead for later audio research,
not proof that the full audio graph, firmware names, amplifier, or pin routing
matches this Redmi Note 11.

## Mainline implementation checklist

| Subsystem | Current state | Next action |
|---|---|---|
| SoC / CPU | SM6225 / Khaje downstream source inspected | Match nodes to the exact pinned Mainline `sm6225.dtsi` and supported bindings |
| PMIC / regulators | Inherited from `khaje-idp.dtsi`; not fully reconciled here | Resolve includes and compare to stock FDT/DTBO |
| USB-C / Type-C | Max77729 public vendor declaration | Check upstream driver/binding and IRQ/pinctrl mapping |
| Charging | Tapas reference (explicitly described as sharing most of spes charger hardware) uses BQ25890 + SM5602 + No-PMI policy; another downstream spes.dtsi declares Max77729 + SC8551 | Source topology is unresolved across trees/revisions; omit charger nodes from first boot DTS |
| UFS | Android device uses UFS 2.2 per device tree documentation | Confirm exact Mainline UFS controller/PHY nodes and live firmware resources |
| SD card | Vendor SDHC2 detect GPIO88 | Verify actual slot population and pin polarity |
| Display | No exact active panel identified from this board override | Identify panel from live DTB/DTBO and panel compatible before enabling DSI |
| Touch | Two candidate controllers are disabled in this source | Identify active controller from stock DTB and hardware |
| Audio | Tapas reference hints at shared LPASS/codec components | Compare exact spes audio nodes, firmware and pin routing separately |
| Wi-Fi / Bluetooth | Not established by these two DTS files | Map WLAN chip, firmware, regulators, GPIOs and bus from stock FDT/vendor data |

## Safe implementation order

1. Keep the current SM6225 kernel build as a compile-only baseline.
2. Resolve the exact Mainline SoC DTSI and binding availability from the pinned
   kernel source.
3. Obtain the target handset's live DTB/DTBO read-only.
4. Build a minimal board DTS from confirmed nodes only: root compatible,
   aliases/console, memory/reserved-memory, PMIC/regulators, and storage.
5. Add USB-C/charging only after driver and binding checks; charging is not a
   first-boot requirement.
6. Add display and touch only after the exact panel/controller is identified.
7. Run DT compilation and schema checks before considering any boot test.

## Current conclusion

The public sources provide actionable hardware leads, but the charger/Type-C
topology differs between available downstream trees and the tapas Mainline
reference; the sources may describe different revisions or complementary
components. The independent touch test strongly points to FT5452, but the
vendor interrupt declarations conflict. This is why a tapas DTS cannot be
renamed into a spes DTS. No board DTS has been created by this research step,
and no image has been flashed or released.


## Touchscreen source cross-check

The included downstream `khaje-idp.dtsi` was inspected directly. It declares a FocalTech touchscreen (`compatible = "focaltech,fts"`) on `qupv3_se2_i2c` at I2C address `0x38`, with AVDD GPIO98, reset GPIO86, IRQ GPIO80, up to 10 contacts, and display coordinates 1080x2400. The `spes.dtsi` override disables the alternative Synaptics TCM (0x20) and Novatek (0x62) nodes. This matches the independent `ios-spes` report of FocalTech at 0x38 and AVDD GPIO98, but remains downstream evidence; verify the exact handset's live DTB/DTBO and check the Mainline driver/binding before creating a node.

The independent report also describes one firmware build with boot/vendor_boot header v3, vendor_boot DTB index 8, and DTBO entries 6 and 15. Those are inspection leads only, not confirmed values for every spes variant.


### Mainline FocalTech compatibility warning

The downstream tree uses `compatible = "focaltech,fts"` and a vendor `ft3418_i2c` driver. The upstream FocalTech FTS binding proposal/current family documentation lists specific compatibles such as `focaltech,fts5452` and `focaltech,fts8719`, not the generic vendor string. This means the node cannot simply be copied unchanged into a schema-valid Mainline DTS. The independent `ios-spes` report mentions a FocalTech controller ID `54:52`; do not infer that this proves the exact silicon model or upstream driver match. Identify the controller variant from its firmware/register ID and confirm the exact driver supported by the pinned kernel before adding the node.

References:
- https://lists.openwall.net/linux-kernel/2023/03/12/96
- https://lkml.iu.edu/2303.1/05772.html
- https://github.com/AdyaGMD/ios-spes


## Touchscreen: reconciled Mainline candidate

The independent `AdyaGMD/ios-spes` hardware report for Redmi Note 11 records
FocalTech ID `54:52`, a successful probe, and working down/up touch events.
The upstream `edt-ft5x06` driver maps this device to compatible
`focaltech,ft5452` and configures a maximum of five touch points. The current
upstream binding lists `focaltech,ft5452` (not the older proposed
`focaltech,fts5452`) and the driver source confirms the compatible match.

The pinned SM6225 baseline config already has
`CONFIG_TOUCHSCREEN_EDT_FT5X06=y`, so no extra driver config patch is needed.
The downstream vendor source is internally inconsistent about the interrupt:
the touchscreen node uses GPIO89 in `interrupts`, but the vendor
`focaltech,irq-gpio` property and independent hardware report point to
GPIO80. The I/O rail is PM6125 L9 at 1.8 V; AVDD is GPIO98 and reset is GPIO86.
Do not author the Mainline touchscreen node until the live DTB resolves the
IRQ mapping and the Mainline supply/pinctrl representation is checked.

Pinned independent reference:
https://github.com/AdyaGMD/ios-spes/tree/bdc2682efd6398f61185eab398361b066bf93794

## UFS / PM6125 rail cross-check (2026-11-18)

The downstream Spes source `Jabiyeff/kernel_xiaomi_sm6225` at commit
`6c2b3e7528a0778cd80c95eabb490746b5422f8c`, file
`arch/arm64/boot/dts/vendor/qcom/khaje-idp.dtsi`, assigns:

- `ufsphy_mem.vdda-phy-supply = <&L4A>` with a source comment of 0.9 V.
- `ufsphy_mem.vdda-pll-supply = <&L18A>` with a source comment of 1.8 V.
- `ufshc_mem.qcom,vddp-ref-clk-supply = <&L18A>` with min/max 1.232 V.

The Mainline-oriented Tapas reference DTS instead defines PM6125 L4 at
0.88 V and L18 at 1.232 V, and uses L4 for UFS PHY and L18 for UFS PLL.
This is a material source discrepancy, not a value to resolve by choosing
one tree arbitrarily. The downstream Spes source may describe a different
regulator mode, firmware generation, or board configuration; its 1.8 V
comment also coexists with a 1.232 V reference-clock constraint on L18A.

Consequences for this port:

- Keep the current Mainline L4/L18 values explicitly provisional.
- Do not enable UFS, CAMSS, or other consumers on the strength of these
  guessed ranges.
- Resolve PM6125 regulator IDs, voltage programming, and consumers from the
  exact target handset's live stock DTB/DTBO plus PMIC/board revision.
- A successful DTS compile only checks phandle and syntax integrity; it does
  not validate regulator electrical safety.

Source:
https://github.com/Jabiyeff/kernel_xiaomi_sm6225/blob/6c2b3e7528a0778cd80c95eabb490746b5422f8c/arch/arm64/boot/dts/vendor/qcom/khaje-idp.dtsi
Reference:
https://github.com/Sype0/pmos-tapas/blob/main/dts/sm6225-xiaomi-tapas.dts
