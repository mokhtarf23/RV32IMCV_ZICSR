# Custom RISC-V RV32IMCV Core with Vector Coprocessor

This project was developed as my **bachelor’s thesis** in Information and Communication Engineering. It implements a custom **RISC-V RV32IMCV scalar core** along with a **vector coprocessor** to explore vector processing extensions and hardware design techniques.

---

## Scalar Core

The scalar core is a **RV32IMCV-compliant processor** designed from scratch, featuring:

- RV32I base instructions with **M (multiply/divide), C (compressed)** extensions
- A simple 5-stage pipeline (Fetch, Decode, Execute, Memory, Writeback)
- Fully synthesizable RTL implementation in Verilog
- Tested using custom simulation testbenches

**Block Diagram:**

![Scalar Core Diagram](Images/scalar-core-architecture.png)

This core forms the base processor and manages communication with the vector coprocessor.

---

## Vector Coprocessor

The vector coprocessor extends the scalar core with support for **vector instructions**:

- Implements a small **vector register file**
- Supports arithmetic, logical, and memory vector operations
- Connected to the scalar core through a custom interface

**Block Diagram:**

![Vector Coprocessor Diagram](Images/vector-coprocessor-architecture.png)

The coprocessor allows executing parallel operations efficiently, demonstrating the benefits of vector extensions in RISC-V.

---

## Implementation

- **RTL Language:** Verilog
- **Verification:** Functional simulation using [Simulator/Tool Name]
- **FPGA Flow:** Synthesized and tested on [FPGA Board Name, if applicable]

---

## Results

- Successfully executed a set of benchmark programs on the scalar core
- Vector coprocessor demonstrated speedup in vectorized operations
- Provides a solid foundation for exploring RISC-V vector extensions in future work

---

## Future Work

- Full RISC-V vector ISA support
- Optimization for higher throughput and reduced latency
- Integration with larger SoC designs

---

## License

This project is for academic purposes. Please refer to the license file for terms.
