module ZICSR (
    input wire clk,                  // Clock signal
    input wire reset,                // Reset signal
    input wire csr_enable,           // Enable signal for CSR operations
    input wire [2:0] funct3,         // Function code from instruction
    input wire [11:0] csr_addr,      // CSR address from instruction
    input wire [31:0] rs1_data,      // Data from RS1 register
    input wire [4:0] imm,       // RS1 address (used for CSRRWI, etc.)
    input wire [31:0] pc,            // Program Counter
    
    // Exception signals
    input wire exception,            // Exception signal
    input wire [4:0] exception_code, // Exception cause
    
    // Interrupt signals
    input wire m_software_interrupt, // Machine software interrupt
    input wire m_timer_interrupt,    // Machine timer interrupt
    input wire m_external_interrupt, // Machine external interrupt
    input wire mret,                 // Return from machine-mode trap
    
    // Outputs
    output reg [31:0] csr_read_data, // Data read from CSR
    output reg [31:0] csr_jmp,       // Exception Program Counter for returns
    output reg csr_pc_src     // Signal indicating an interrupt is pending
);

    // CSR Addresses (RISC-V specification)
localparam MSTATUS     = 12'h300;  // Machine status register
localparam MISA        = 12'h301;  // Machine ISA register
localparam MIE         = 12'h304;  // Machine interrupt enable
localparam MTVEC       = 12'h305;  // Machine trap handler base address
localparam MSCRATCH    = 12'h340;  // Scratch register for machine trap handlers
localparam MEPC        = 12'h341;  // Machine exception program counter
localparam MCAUSE      = 12'h342;  // Machine trap cause
localparam MTVAL       = 12'h343;  // Machine trap value
localparam MIP         = 12'h344;  // Machine interrupt pending
localparam MCYCLE      = 12'hB00;  // Machine cycle counter
localparam MINSTRET    = 12'hB02;  // Machine instructions-retired counter

// MSTATUS bit positions
localparam MIE_BIT     = 3;      // Machine Interrupt Enable
localparam MPIE_BIT    = 7;      // Previous Machine Interrupt Enable

// Standard interrupt and exception causes
localparam M_SW_INT_CAUSE    = 3;  // Machine software interrupt cause
localparam M_TIMER_INT_CAUSE = 7;  // Machine timer interrupt cause
localparam M_EXT_INT_CAUSE   = 11; // Machine external interrupt cause

// MIE and MIP bit positions for interrupt enables/pendings
localparam MSIE_BIT = 3;  // Machine software interrupt enable/pending
localparam MTIE_BIT = 7;  // Machine timer interrupt enable/pending
localparam MEIE_BIT = 11; // Machine external interrupt enable/pending

// CSR Register storage
reg [31:0] csr_mstatus;
reg [31:0] csr_misa;
reg [31:0] csr_mie;
reg [31:0] csr_mtvec;
reg [31:0] csr_mscratch;
reg [31:0] csr_mepc;
reg [31:0] csr_mcause;
reg [31:0] csr_mtval;
reg [31:0] csr_mip;
reg [63:0] csr_mcycle;    // 64-bit counter (we'll use low 32 bits only)
reg [63:0] csr_minstret;  // 64-bit counter (we'll use low 32 bits only)

reg [31:0] trap_vector;  // Address to jump on exception

// Write data to calculate based on operation
reg [31:0] write_data;
    
// Interrupt handling signals
wire [31:0] pending_interrupts;
wire [31:0] enabled_interrupts;
wire has_interrupt;
reg [4:0] interrupt_cause;
wire interrupt_enabled;

// Determine if global interrupts are enabled
assign interrupt_enabled = csr_mstatus[MIE_BIT];
    
    

    
// Determine which interrupts are both pending and enabled
assign pending_interrupts = csr_mip & csr_mie;
assign enabled_interrupts = pending_interrupts & {32{interrupt_enabled}};
assign has_interrupt = |enabled_interrupts;
    
// Determine interrupt cause with priority (external > timer > software)
always @(*) begin
    if (enabled_interrupts[MEIE_BIT])       // Machine external interrupt
        interrupt_cause = M_EXT_INT_CAUSE;
    else if (enabled_interrupts[MTIE_BIT])  // Machine timer interrupt
        interrupt_cause = M_TIMER_INT_CAUSE;
    else if (enabled_interrupts[MSIE_BIT])  // Machine software interrupt
        interrupt_cause = M_SW_INT_CAUSE;
    else
        interrupt_cause = 5'h0;
end


// Calculate trap vector address based on mode
always @(*) begin
    if (exception) begin
        if (csr_mtvec[1:0] == 2'b01) begin
            // Vectored mode for exceptions: BASE + 4 × exception_code.
            trap_vector = {csr_mtvec[31:2], 2'b00} + (exception_code<<2);
        end else begin
            // Direct mode for exceptions: use the base address.
            trap_vector = {csr_mtvec[31:2], 2'b00};
        end

    end else if (has_interrupt) begin
        // Handle interrupts if no exception is active.
        if (csr_mtvec[1:0] == 2'b01) begin
            // Vectored mode for interrupts: BASE + 4 × interrupt_cause.
            trap_vector = {csr_mtvec[31:2], 2'b00} + (interrupt_cause<<2);
        end else begin
            // Direct mode for interrupts: use the base address.
            trap_vector = {csr_mtvec[31:2], 2'b00};
        end

    end else begin
        // When no trap, default to the base address.
        trap_vector = {csr_mtvec[30:2], 2'b00};
    end
end

// Initialize CSRs on reset and handle CSR operations
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Initialize CSRs to their default values
        csr_mstatus  <= 32'h0;       // Initial machine status
        csr_misa     <= 32'h40001100; // RV32IMC ('I' and 'M' and 'C' extensions)
        csr_mie      <= 32'h0;       // No interrupts enabled
        csr_mtvec    <= 32'h0;       // Trap vector starts at address 0
        csr_mscratch <= 32'h0;       // Scratch register
        csr_mepc     <= 32'h0;       // Exception PC
        csr_mcause   <= 32'h0;       // Cause of trap
        csr_mtval    <= 32'h0;       // Trap value
        csr_mip      <= 32'h0;       // No interrupts pending
        csr_mcycle   <= 64'h0;       // Cycle counter
        csr_minstret <= 64'h0;       // Instruction counter
    end else begin

        // Update counters every cycle
        csr_mcycle <= csr_mcycle + 1;

        // Update interrupt pending bits based on input signals
        csr_mip[MSIE_BIT] <= m_software_interrupt;
        csr_mip[MTIE_BIT] <= m_timer_interrupt;
        csr_mip[MEIE_BIT] <= m_external_interrupt;


            
        // Handle trap (exception or interrupt)
        if (exception || (has_interrupt && !mret)) begin
            // Save current PC to MEPC
            csr_mepc <= pc;

            // save current interrupt enable bit and disable interrupts
            csr_mstatus[MPIE_BIT] <= csr_mstatus[MIE_BIT];  // Save current MIE to MPIE
            csr_mstatus[MIE_BIT] <= 1'b0;                  // Disable interrupts
                
            // Update mcause
            if (exception) begin
                csr_mcause <= {1'b0, 26'b0, exception_code};
            end else if (has_interrupt) begin
                csr_mcause <= {1'b1, 26'b0, interrupt_cause};
            end
        end
            

        if (mret) begin
            // Restore previous interrupt enable
            csr_mstatus[MIE_BIT] <= csr_mstatus[MPIE_BIT];  // Restore MIE from MPIE
            csr_mstatus[MPIE_BIT] <= 1'b1;                 // Set MPIE to 1
        end
            
        // CSR operations
        if (csr_enable) begin
            case (funct3)
                3'b001: write_data = rs1_data;                             // CSRRW
                3'b010: write_data = csr_read_data | rs1_data;             // CSRRS
                3'b011: write_data = csr_read_data & ~rs1_data;            // CSRRC
                3'b101: write_data = {27'b0, imm};                   // CSRRWI
                3'b110: write_data = csr_read_data | {27'b0, imm};   // CSRRSI
                3'b111: write_data = csr_read_data & ~{27'b0, imm};  // CSRRCI
                default: write_data = 32'h0;
            endcase
                
            case (csr_addr)
                MSTATUS: csr_mstatus <= write_data & 32'h00001888;
                MISA: csr_misa <= csr_misa;
                MIE: csr_mie <= write_data & 32'h00000888;
                MTVEC: csr_mtvec <= write_data & 32'hFFFFFFFC;
                MSCRATCH: csr_mscratch <= write_data;
                MEPC: csr_mepc <= write_data & 32'hFFFFFFFC;
                MCAUSE: csr_mcause <= write_data;
                MTVAL: csr_mtval <= write_data;
                MIP: csr_mip <= (csr_mip & ~32'h00000888) | (write_data & 32'h00000888);
                MCYCLE: csr_mcycle[31:0] <= write_data;
                MINSTRET: csr_minstret[31:0] <= write_data;
                default: ;
            endcase
        end
            
        // Increment instruction counter (should be connected to instruction retirement signal)
        // For this implementation, we'll just increment on each non-exceptional instruction
        if (!exception && !has_interrupt)
            csr_minstret <= csr_minstret + 1;
        end
end

reg [31:0] csr_read_data1;
reg [31:0] csr_read_data2;
reg [31:0] pc_reg;


    // Read data from CSRs
//FOR NO HAZARD OR STALL TAKE IT RIGHT AWAY
always @(*) begin
    case (csr_addr)
        MSTATUS:  csr_read_data1 = csr_mstatus;
        MISA:     csr_read_data1 = csr_misa;
        MIE:      csr_read_data1 = csr_mie;
        MTVEC:    csr_read_data1 = csr_mtvec;
        MSCRATCH: csr_read_data1 = csr_mscratch;
        MEPC:     csr_read_data1 = csr_mepc;
        MCAUSE:   csr_read_data1 = csr_mcause;
        MTVAL:    csr_read_data1 = csr_mtval;
        MIP:      csr_read_data1 = csr_mip;
        MCYCLE:   csr_read_data1 = csr_mcycle[31:0];
        MINSTRET: csr_read_data1 = csr_minstret[31:0];
        default:  csr_read_data1 = 32'h0; // Return 0 for unimplemented CSRs
    endcase
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        csr_read_data2 <= 0;
        pc_reg<=0;
    end else begin
    case (csr_addr)
        MSTATUS:  csr_read_data2 <= csr_mstatus;
        MISA:     csr_read_data2 <= csr_misa;
        MIE:      csr_read_data2 <= csr_mie;
        MTVEC:    csr_read_data2 <= csr_mtvec;
        MSCRATCH: csr_read_data2 <= csr_mscratch;
        MEPC:     csr_read_data2 <= csr_mepc;
        MCAUSE:   csr_read_data2 <= csr_mcause;
        MTVAL:    csr_read_data2 <= csr_mtval;
        MIP:      csr_read_data2 <= csr_mip;
        MCYCLE:   csr_read_data2 <= csr_mcycle[31:0];
        MINSTRET: csr_read_data2 <= csr_minstret[31:0];
        default:  csr_read_data2 <= 32'h0; // Return 0 for unimplemented CSRs
    endcase
    pc_reg<=pc;
end
end

always @(*) begin
    if (pc_reg==pc) begin
        csr_read_data=csr_read_data2;
    end else begin
        csr_read_data=csr_read_data1;
    end
end

    ///CSR JUMP HANDLING
always @(*) begin
    if (exception) begin
        csr_jmp = trap_vector;
        csr_pc_src=1;
    end else if (mret) begin
        csr_jmp = csr_mepc+4;
        csr_pc_src=1;
    end else if (has_interrupt) begin
        csr_jmp = trap_vector;
        csr_pc_src=1;
    end else begin
        csr_jmp = 0;
        csr_pc_src=0;
    end
end

endmodule