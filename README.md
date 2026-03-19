# Custom RISC-V RV32IMCV Core with Vector Coprocessor

This project was developed as my **bachelor’s thesis** in Communication Systems Engineering at Ain-Shams University. It implements a custom **RISC-V RV32IMCV scalar core** along with a **vector coprocessor** to explore vector processing extensions and hardware design techniques.

## Full System

The system consists of the scalar core connected to the vector coprocessor, memory interfaces, and supporting structures.

**System Diagram:**

![Full System Diagram](Images/RVV-core-architecture.png)

## Scalar Core

The scalar core is a **RV32IMCV processor** designed from scratch, featuring:

- RV32I base instructions with **M (multiply/divide), C (compressed)** extensions
- A 4-stage pipeline (Fetch, Decode, Execute, Memory+Writeback)
- Fully synthesizable RTL implementation in Verilog
- Tested using custom simulation testbenches
- Passed the RISC-V Compliance Framework.

**Block Diagram:**

![Scalar Core Diagram](Images/scalar-core-architecture.png)

This core forms the base processor and manages communication with the vector coprocessor.

## Vector Coprocessor

The vector coprocessor extends the scalar core with support for **vector instructions**.

**Block Diagram:**

![Vector Coprocessor Diagram](Images/vector-coprocessor-architecture.png)

Key features:

- **Instruction Sequencer:**  
  - Receives decoded vector instructions from the **vector decoder** along with source registers from the **vector register file (VRF)**  
  - Detects instruction type and forwards it to the correct execution unit (**ALU, MUL, DIV, RED, PER, MMU**)  
  - Issues instructions in order, while execution occurs out of order depending on latency

- **Reservation Stations:**
  - One reservation station for each type of execution unit
  - Can hold up to 2 instructions per unit (incl. operands and opcode) 
  - Prepares operands and forwards them to execution units  

- **Execution Units:**  
  - Each unit has 4 parallel sub-units (e.g., 4 ALUs, 4 MULs)  
  - Handles different **SEW (standard element widths)** efficiently:  
    - SEW 32 → 1 cycle  
    - SEW 16 → 2 cycles  
    - SEW 8 → 4 cycles  

- **Gatherers:**  
  - Reassemble outputs from execution units into complete vectors  

- **Write Back Queue:**  
  - Ensures **in-order committing**  
  - For memory instructions, results go directly to the **MMU**  

- **Chaining Unit:**  
  - Resolves data hazards by forwarding operands that are still in-flight, avoiding pipeline stalls  
  - Interfaces with the **Sequencer, Gatherers, Reservation Stations, and Write Back Queue**  

  - **Operation:**  
    - Triggered when operands are not yet available in the vector register file  
    - The Sequencer stalls only the dependent instruction while others continue execution  

  - **Forwarding Paths:**  
    - From **Gatherers**: streams partial results as they become available (element-by-element)  
    - From **Write Back Queue**: provides full vector results if already completed  

  - **Completion:**  
    - Signals the Sequencer once operands are ready  
    - Allows dispatch to resume with minimal pipeline disruption  

- **Memory System:**  
  - Vector memory organized into **4 banks**  
  - **MMU** handles loads and stores  
  - For write instructions, the MMU outputs the vector to the write back queue 

  - Improves performance by enabling **fine-grained operand forwarding** and reducing stalls in dependent vector operations

**Chaining Flow Diagram:**

The following diagram illustrates operand forwarding between the Sequencer, Gatherers, Write Back Queue, and Reservation Stations.

![Chaining Flow Diagram](Images/Chaining_Flow.png)


## Supported Vector Instructions

The vector coprocessor currently supports the following instructions, with **SEW = 32, 16, 8**:

- **Arithmetic and Logical Operations:**  
  - `VADD`, `VSUB`, `VRSUB`  
  - `VAND`, `VOR`, `VXOR`  
  - `VMINU`, `VMIN`, `VMAXU`, `VMAX`  
  - `VSLL`, `VSRL`, `VSRA`, `VSSRL`, `VSSRA`  

- **Mask Operations:**  
  - `VMSEQ`, `VMSNE`, `VMSLTU`, `VMSLT`, `VMSLEU`, `VMSLE`, `VMSGTU`, `VMSGT`  
  - `VMAND`, `VMANDN`, `VMOR`, `VMORN`, `VMNOR`, `VMXOR`, `VMXNOR`, `VMNAND`  

- **Multiplication:**  
  - `VMULHU`, `VMUL`, `VMULHSU`, `VMULH`  

- **Division / Remainder:**  
  - `VDIVU`, `VDIV`, `VREMU`, `VREM`  

- **Permutation / Slide:**  
  - `VSLIDEUP`, `VSLIDEDOWN`, `VCOMPRESS`  

 **Supported vector element widths (SEW) of 32, 16, and 8 bits**.

## Implementation

- **RTL Language:** Verilog + System Verilog
- **Verification:** Functional simulation using [Questasim] + Compliance Testing

## Results

- The **scalar core** passed the **RISC-V Compliance Framework** and was synthesized to **2,168 LUTs** on Xilinx Vivado.  
- The **vector coprocessor** demonstrated **~20× speedup** for parallel workloads (from test programs).  
- Together, they provide a solid foundation for exploring RISC-V vector extensions in future work.

## Future Work

- Full RISC-V vector ISA support
- Optimization for higher throughput and reduced latency
- Integration with larger SoC designs

## License

This project is for academic purposes. Please refer to the license file for terms.
