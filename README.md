# Architecture-Driven Voltage Scaling for AES-128 Encryption (N=2)

This repository contains a Verilog implementation of an AES-128 encryption system that reduces dynamic power through architectural duplication and staggered execution.

## Objective

Reduce dynamic power consumption of AES-128 encryption while preserving aggregate system throughput.

## Design Summary

- Baseline design: single iterative AES-128 core operating at 100 MHz.
- Proposed design: two parallel AES lanes (N=2) with shared input broadcast.
- Scheduling method: one global clock plus round-robin phase counter generating per-lane clock-enable pulses.
- Effective lane update rate: f_sample / 2 per lane.
- Output control: completion collection plus sequence-aware reorder buffer (ROB) for in-order ciphertext retirement.

## Architecture Details

### Baseline Path

- Top module: aes_top
- Core module: aes128_core
- Operation: 10 AES rounds after initial add-round-key, one round per clock.

### Duplicated Low-Power Path (N=2)

- Top module: aes_top_parallel
- CE-aware core: aes128_core_ce
- Input dispatch: plaintext/key buffered then dispatched to the next enabled free lane.
- Completion handling: lane outputs are tagged by sequence ID and written to ROB.
- Retirement: ciphertext is emitted strictly in original input order.

## Verified Results

| Metric | Baseline | Proposed (N=2) | Change |
| :--- | :---: | :---: | :---: |
| Dynamic power | 0.700 W | 0.350 W | -50.0% |
| Total on-chip power | 0.832 W | 0.489 W | -41.2% |
| Throughput | 1.28 Gbps | 1.28 Gbps | Preserved |
| Per-block latency | 100 ns | 200 ns | +100% |
| Slice LUTs | 3,978 | 10,618 | +6,640 |
| Slice Registers (FFs) | 262 | 3,790 | +3,528 |

The area increase is expected and comes from duplication overhead, input broadcast routing, completion multiplexing, and ROB sequence tracking.

## Verification Status

- RTL verified against NIST AES-128 ECB known-answer vectors.
- Single-core testbench validates baseline encryption correctness.
- Parallel testbench validates staggered CE dispatch and in-order output retirement.

## Repository Layout

```text
AES128-LowPower-Architecture/
├── src/
│   └── rtl/
│       ├── addroundkey.v
│       ├── aes128_core.v
│       ├── aes128_core_ce.v
│       ├── aes_final_round.v
│       ├── aes_round.v
│       ├── aes_top.v
│       ├── aes_top_parallel.v
│       ├── key_expand.v
│       ├── mixcolumns.v
│       ├── sbox.v
│       ├── shiftrows.v
│       ├── subbytes.v
│       └── subword.v
├── sim/
│   └── tb/
│       ├── tb_aes_top.v
│       └── tb_aes_top_parallel.v
├── .gitattributes
├── .gitignore
└── README.md
```

## How to Run Simulation

Use your preferred Verilog simulator. Compile all files under src/rtl together with one selected testbench from sim/tb.

- Baseline testbench: tb_aes_top.v
- Parallel architecture testbench: tb_aes_top_parallel.v

If using Vivado XSim, add src/rtl as design sources and sim/tb as simulation sources, then set the desired testbench as top.
