# QEM-01 Physical Design and RTL-to-GDS Results

## 1. Overview

QEM-01 was taken through an RTL-to-GDS implementation flow using OpenROAD Flow Scripts and the SKY130HD platform.

The flow covered synthesis, floorplanning, power distribution, placement, clock-tree synthesis, routing, parasitic extraction, timing analysis, physical verification, and GDS generation.

This document records the implementation configuration and the measured results from the completed run.

## 2. Implementation Configuration

| Parameter | Value |
|---|---|
| Design top | `tt_um_qem01` |
| Platform | `sky130hd` |
| Standard-cell library | SKY130HD |
| Supply voltage | 1.8 V |
| Timing corner | TT, 0.25 °C |
| Clock frequency | 50 MHz |
| Clock period | 20 ns |
| Core utilization target | 40% |
| Placement density | 0.60 |

The timing constraints used a 20 ns clock, 2 ns input delays, 2 ns output delays, and a false path from the active-low reset port.

The reported timing results are specific to these constraints and the selected library corner.

## 3. Physical Design Flow

### 3.1 Synthesis

The RTL hierarchy was checked using Yosys before technology mapping.

The SKY130HD technology-mapped synthesis report recorded:

- 603 mapped cells, excluding 8 scope-information cells
- Mapped cell area: 6,650.128 µm²
- 143 `sky130_fd_sc_hd__dfrtp_1` flip-flops
- Sequential cell area: 3,578.432 µm²

The OpenROAD flow's synthesis stage reported an area of approximately 8,119 µm². This differs from the standalone Yosys mapping result because the reports come from different stages and flow configurations.

### 3.2 Floorplanning and Power Distribution

| Metric | Result |
|---|---:|
| Die dimensions | 144.47 × 144.47 µm |
| Core area | 19,653.85 µm² |
| Tap cells inserted | 265 |
| PDN generation | Completed |

The final floorplan used the SKY130HD platform's floorplanning and power-distribution setup.

### 3.3 Placement

Placement completed successfully.

- 842 cells were placed.
- All cells were legalized.
- No placement violations were reported.
- Placement utilization was approximately 43%.
- HPWL reduced from 13,273.7 µm to 12,263.1 µm after placement and mirroring.

### 3.4 Clock-Tree Synthesis

Clock-tree synthesis completed with:

| Metric | Result |
|---|---:|
| Clock sinks | 143 |
| Clock buffers | 17 |
| Clock nets | 17 |
| Maximum clock-tree levels | 4 |
| Reported clock path depth | 2 |
| Average sink wire length | 175.45 µm |

No setup or hold violations were reported at the CTS stage.

### 3.5 Routing

Global routing completed with zero routing overflow.

| Metric | Result |
|---|---:|
| Detailed-route nets | 874 |
| Global-route wirelength | 28,752 µm |
| Detailed-route wirelength | 17,564 µm |
| Vias | 5,968 |
| Final detailed-route DRC violations | 0 |

Detailed routing initially reported 246 violations. The routing optimization iterations reduced the reported count to zero.

## 4. Parasitic Extraction and Timing Analysis

Parasitics were extracted from the routed design and written to SPEF.

The extracted design was then analyzed using the SKY130HD TT 0.25 °C, 1.8 V Liberty model.

### Post-route timing results

| Metric | Result |
|---|---:|
| Clock period | 20 ns |
| Worst setup slack | +13.79 ns |
| Worst hold slack | +0.35 ns |
| Setup total negative slack | 0 ns |

The worst reported setup path had positive slack of 13.79 ns. The worst reported hold path had positive slack of 0.35 ns.

These results indicate that the reported paths meet the configured timing constraints. They should not be interpreted as foundry signoff: the analysis is limited to the supplied SDC, library corner, and modeled constraints.

## 5. Power Integrity Analysis

The available static IR analysis reported:

| Supply | Worst reported voltage/drop |
|---|---:|
| VDD, nominal 1.8 V | 1.80 V worst voltage; 53 µV worst drop |
| VSS, nominal 0 V | 73.5 µV worst voltage above ground |

The reported average drops were approximately 10.7 µV on VDD and 10.8 µV on VSS.

These are results from the configured static analysis and should be interpreted in the context of its assumptions and activity model.

## 6. Physical Verification

### OpenROAD detailed-route checks

The completed detailed-route report recorded:

- 0 DRC violations
- 0 antenna violations
- 0 net violations
- 0 pin violations

### KLayout DRC

The SKY130HD KLayout DRC deck completed and generated `6_drc.lyrdb`.

The extracted report count was:

```text
0
```

Therefore, the KLayout DRC run reported zero violations.

### GDS consistency

The GDS merge/check stage reported:

- All LEF cells had matching GDS/OAS cells.
- No orphan cells were found in the final layout.

This is a LEF–GDS cell consistency check; it is not an LVS connectivity comparison.

## 7. Final Layout Artifacts

The final OpenROAD run generated the following principal artifacts:

| Artifact | Purpose |
|---|---|
| `6_final.gds` | Final layout stream |
| `6_final.def` | Final design exchange format |
| `6_final.odb` | Final OpenDB database |
| `6_final.sdc` | Final timing constraints |
| `6_final.spef` | Extracted parasitics |
| `6_drc.lyrdb` | KLayout DRC report database |

The final GDS file was approximately 1.4 MB.

The artifacts were generated under the OpenROAD flow results directory for the `sky130hd/qem01` design.

## 8. Toolchain Compatibility Notes

The installed OpenROAD build differed from the version expected by the checked-out OpenROAD Flow Scripts. A small number of flow-script compatibility changes were made to allow the run to complete.

These included changes to unsupported placement-check and helper-command options, an update to the parasitic-extraction commands, and clearing the OSS CAD Suite Python environment variables before launching the system KLayout executable.

The fixed-instance placement validation step was skipped because the installed OpenROAD version did not support the expected command option. Other placement and routing checks completed, but this skipped validation should be disclosed when describing the flow.

The final report GUI stage also encountered a GUI/property compatibility error after parasitic extraction. Post-route timing analysis was therefore run separately using the final ODB, SDC, and SPEF files.

## 9. Verification Scope and Limitations

The completed work establishes that the RTL was simulated, synthesized, placed, clock-tree synthesized, routed, and converted into a GDS layout. The recorded OpenROAD and KLayout DRC checks reported zero violations.

The following checks or activities were not completed:

- Layout-versus-schematic (LVS) connectivity verification
- Fabrication or silicon validation
- Foundry signoff across process, voltage, and temperature corners
- Timing signoff with a complete production constraint set

The timing analysis used the project's configured SDC. In particular, the encoder input timing assumptions and clock uncertainty were not developed as a full signoff constraint set.

The result should therefore be described as a completed RTL-to-GDS portfolio implementation, not as a tapeout-ready or fabrication-verified design.
