# Custom RISC-V RV32IMCV Core with Vector Coprocessor

This project was developed as part of my Bachelor’s thesis in Communication Systems Engineering at Ain Shams University.  
It implements a custom RISC-V RV32IMCV processor extended with a vector coprocessor to explore vector processing, hardware design, and architectural trade-offs.



## System Overview

![Full System Diagram](Images/RVV-core-architecture.png)



## Scalar Core

The scalar core is a 4-stage pipelined RV32IMC processor designed from scratch.

**Architecture:**
- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execute (EX)
- Memory + Writeback (WB)

**Features:**
- RV32I base instruction set
- M extension (multiplication and division)
- C extension (compressed instructions)
- Hazard handling (data and control)
- Forwarding and stalling mechanisms
- CSR unit for exception and interrupt handling
- Fully synthesizable Verilog RTL
- Verified using simulation and RISC-V compliance tests

![Scalar Core Diagram](Images/scalar-core-architecture.png)

The scalar core serves as the control unit of the system and interfaces with the vector coprocessor.



## Vector Coprocessor

The vector coprocessor accelerates data-parallel workloads by executing vector instructions alongside the scalar core.

![Vector Coprocessor Diagram](Images/vector-coprocessor-architecture.png)

### Architecture Overview

The design is built around a modular execution model with the following components:

- Instruction Sequencer  
  Receives decoded vector instructions and dispatches them to execution units.  
  Instructions are issued in order, while execution can proceed out of order depending on unit latency.

- Reservation Stations  
  One per execution unit type (ALU,MUL,DIV,RED,PER,MEM), each holding up to two instructions.  
  Responsible for operand preparation and scheduling.

- Execution Units (ALU,MUL,DIV,RED,PER,MEM)  
  Each unit contains four parallel lanes.  
  Supports different element widths:
  - SEW 32 → 1 cycle
  - SEW 16 → 2 cycles
  - SEW 8 → 4 cycles

- Gatherers  
  Reassemble partial outputs from execution units into full vectors.

- Writeback Queue  
  Ensures in-order commit of results.

- Chaining Unit  
  Enables forwarding of in-flight results to dependent instructions.  
  Reduces stalls and improves pipeline efficiency by allowing partial or completed results to be reused.

- Memory System  
  Organized into four banks with an MMU handling vector loads and stores.

![Chaining Flow Diagram](Images/Chaining_Flow.png)


## Supported Vector Instructions

The implementation supports a subset of vector instructions with element widths of 32, 16, and 8 bits.

Arithmetic and logical:
- VADD, VSUB, VRSUB
- VAND, VOR, VXOR
- VMINU, VMIN, VMAXU, VMAX
- VSLL, VSRL, VSRA, VSSRL, VSSRA

Mask operations:
- VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT
- VMAND, VMANDN, VMOR, VMORN, VMNOR, VMXOR, VMXNOR, VMNAND

Multiplication:
- VMUL, VMULH, VMULHU, VMULHSU

Division and remainder:
- VDIV, VDIVU, VREM, VREMU

Permutation:
- VSLIDEUP, VSLIDEDOWN, VCOMPRESS


## Implementation

- RTL: Verilog / SystemVerilog  
- Verification: Functional simulation using QuestaSim  
- Compliance: RISC-V Compliance Framework  


## Results

- Scalar core passed RISC-V compliance tests  
- Synthesized to ~2,168 LUTs (Xilinx Vivado)  
- Vector coprocessor achieved ~20× speedup on data-parallel workloads  


## Future Work

- Extended support for RISC-V vector ISA  
- Improved memory subsystem for vector workloads  
- FPGA implementation and system-level integration  


## Notes

This project is a proof-of-concept implementation focused on architectural exploration.  
Some components can be further optimized or extended in terms of performance and completeness.


## Contribution

This work was developed as part of a group project.  
I was primarily responsible for the processor architecture, pipeline implementation, vector coprocessor design, and system integration.
