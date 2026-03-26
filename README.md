# Custom RISC-V RV32IMCV Core with Vector Coprocessor

This project was developed as my bachelor's thesis in Communication Systems Engineering at Ain-Shams University. It implements a custom RISC-V RV32IMCV scalar core with a vector coprocessor to explore RISC-V ISA extensions, vector processing, and hardware design techniques.

## System Overview

The system consists of the scalar core, vector coprocessor, memory interfaces, and supporting structures.

**System Diagram:**  
![Full System Diagram](Images/RVV-core-architecture.png)

The scalar core manages control and communication, while the vector coprocessor executes vector instructions in parallel to accelerate workloads.

## Scalar Core

The scalar core is a RV32IMCV processor designed from scratch. Key features:

- Supports RV32I base instructions with M (multiply/divide) and C (compressed) extensions
- 4-stage pipeline: Fetch, Decode, Execute, Memory/Writeback
- Fully synthesizable RTL in Verilog
- Verified with custom simulation testbenches and passed the RISC-V Compliance Framework

**Block Diagram:**  
![Scalar Core Diagram](Images/scalar-core-architecture.png)

## Vector Coprocessor

The vector coprocessor extends the scalar core with vector instruction support.

**Block Diagram:**  
![Vector Coprocessor Diagram](Images/vector-coprocessor-architecture.png)

### Key Components

**Instruction Sequencer**

- Receives decoded vector instructions and source registers from the vector register file (VRF)
- Detects instruction type and forwards it to the appropriate execution unit (ALU, MUL, DIV, RED, PER, MMU)
- Issues instructions in order; execution can occur out of order depending on latency

**Reservation Stations**

- One station per execution unit, holding up to 2 instructions per unit
- Prepares operands and forwards them to execution units

**Execution Units**

- Each unit has 4 parallel sub-units (e.g., ALUs, multipliers)
- Handles different SEW (standard element widths) efficiently:
  - SEW 32 → 1 cycle
  - SEW 16 → 2 cycles
  - SEW 8 → 4 cycles

**Gatherers**

- Reassemble outputs from execution units into complete vectors

**Write Back Queue**

- Ensures in-order committing
- For memory instructions, results go directly to the MMU

**Chaining Unit**

- Resolves data hazards by forwarding operands that are still in-flight
- Interfaces with the Sequencer, Gatherers, Reservation Stations, and Write Back Queue
- Only stalls dependent instructions, minimizing pipeline disruption
- Forwarding paths:
  - From Gatherers: streams partial results element-by-element
  - From Write Back Queue: provides full vector results if already completed
- Signals Sequencer when operands are ready to resume dispatch

**Memory System**

- Vector memory organized into 4 banks
- MMU handles loads and stores; write instructions go through Write Back Queue
- Enables fine-grained operand forwarding and reduces stalls in dependent operations

**Chaining Flow Diagram:**  
![Chaining Flow Diagram](Images/Chaining_Flow.png)

## Supported Vector Instructions

The vector coprocessor supports SEW = 32, 16, 8.

**Arithmetic and Logical:**  
VADD, VSUB, VRSUB, VAND, VOR, VXOR, VMINU, VMIN, VMAXU, VMAX, VSLL, VSRL, VSRA, VSSRL, VSSRA

**Mask Operations:**  
VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT, VMAND, VMANDN, VMOR, VMORN, VMNOR, VMXOR, VMXNOR, VMNAND

**Multiplication:**  
VMULHU, VMUL, VMULHSU, VMULH

**Division / Remainder:**  
VDIVU, VDIV, VREMU, VREM

**Permutation / Slide:**  
VSLIDEUP, VSLIDEDOWN, VCOMPRESS

## Implementation

- RTL: Verilog + SystemVerilog
- Verification: Functional simulation using Questasim + RISC-V Compliance Testing

## Results

- Scalar core passed the RISC-V Compliance Framework
- Synthesized to 2,168 LUTs on Xilinx Vivado
- Vector coprocessor achieved ~20× speedup for parallel workloads
- Provides a foundation for exploring RISC-V vector extensions in future designs

## Future Work

- Full RISC-V vector ISA support
- Integration with larger SoC designs
- FPGA implementation
