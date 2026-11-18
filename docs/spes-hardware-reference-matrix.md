# Redmi Note 11 (spes) hardware reference matrix

This document separates public downstream Android declarations from the
Mainline reference implementation. None of these public source files is a
substitute for the live DTB/DTBO and exact hardware revision of the target
phone.

## Evidence inspected

| Source | Revision / blob | What it is |
|---|---|---|
| `Jabiyeff/kernel_xiaomi_sm6225` `arch/arm64/boot/dts/vendor/qcom/spes.dtsi` | blob `cc5dbd5e58468a15631e0da559486b1323e91a65` | Downstream vendor board overrides for spes |
| Same repository `khaje.dtsi` | blob `e57c487190dc50acbfcc56b3af437d9150d3253f` | Downstream Khaje SoC description |
| `Sype0/pmos-tapas` `dts/sm6225-xiaomi-tapas.dts` | blob `581500e63039f8f2970103b2918386cc9d56d6a2` | Mainline-oriented tapas board DTS; reference only |
| `Sype0/pmos-tapas` `dts/sm6225-xiaomi-tapas-audio.dts` | blob `e4d568ddbc3184ba49306f79b2ffef18dce5044f` | Optional tapas audio variant; comments compare parts with spes |

Source URLs:
- https://github.com/Jabiyeff/kernel_xiaomi_sm6225/blob/6c2b3e7528a0778cd80c95eabb490746b5422f8c/arch/arm64/boot/dts/vendor/qcom/spes.dtsi
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
| Touchscreen | Synaptics TCM at I2C address `0x20` and Novatek at `0x62` are explicitly disabled in this file | Does not identify the active panel/touch controller; do not enable either based on this file |
| One-wire accessory | GPIO108 vendor node | Vendor-specific feature; out of initial bring-up scope |
| Charger policy | `qcom,nopmi-chg` node with board thermal/charge policy | Vendor-specific binding and policy; do not copy into Mainline without a matching upstream binding/driver |

Important: `spes.dtsi` includes `khaje-idp.dtsi`. The complete inherited device tree,
including PMIC and regulators, must be resolved before treating this override
file as a complete board description.

## Cross-check against the tapas Mainline reference

The inspected `sm6225-xiaomi-tapas.dts` uses a different charger arrangement:
a `ti,bq25890` at I2C address `0x6a` and an `sm,sm5602` fuel gauge at
`0x71`, plus a `qcom,nopmi-chg` policy node. This does **not** match the
public downstream spes override, which declares Max77729 and SC8551 devices.
Therefore do not copy the tapas charger/fuel-gauge nodes, addresses, current
limits, JEITA values, or GPIO assignments into a spes DTS.

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
| Charging | Max77729 + SC8551 in spes vendor file; different from tapas reference | Keep disabled in first minimal DTS until driver and battery safety are verified |
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

The public sources provide actionable hardware leads, but also expose a
critical mismatch between the charger topology in the spes vendor source and
the tapas Mainline reference. This is exactly why a tapas DTS cannot be
renamed into a spes DTS. No board DTS has been created by this research step,
and no image has been flashed or released.
