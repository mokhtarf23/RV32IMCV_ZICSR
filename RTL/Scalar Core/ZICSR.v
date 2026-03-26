module ZICSR (
    input wire clk,
    input wire reset,
    input wire csr_enable,
    input wire [2:0] funct3,
    input wire [11:0] csr_addr,
    input wire [31:0] rs1_data,
    input wire [4:0] imm,
    input wire [31:0] pc,

    input wire exception,
    input wire [4:0] exception_code,

    input wire m_software_interrupt,
    input wire m_timer_interrupt,
    input wire m_external_interrupt,
    input wire mret,

    output reg [31:0] csr_read_data,
    output reg [31:0] csr_jmp,
    output reg csr_pc_src
);

//CSR addresses
localparam MSTATUS     = 12'h300;
localparam MISA        = 12'h301;
localparam MIE         = 12'h304;
localparam MTVEC       = 12'h305;
localparam MSCRATCH    = 12'h340;
localparam MEPC        = 12'h341;
localparam MCAUSE      = 12'h342;
localparam MTVAL       = 12'h343;
localparam MIP         = 12'h344;
localparam MCYCLE      = 12'hB00;
localparam MINSTRET    = 12'hB02;

//bit positions
localparam MIE_BIT     = 3;
localparam MPIE_BIT    = 7;

localparam M_SW_INT_CAUSE    = 3;
localparam M_TIMER_INT_CAUSE = 7;
localparam M_EXT_INT_CAUSE   = 11;

localparam MSIE_BIT = 3;
localparam MTIE_BIT = 7;
localparam MEIE_BIT = 11;

//registers
reg [31:0] csr_mstatus;
reg [31:0] csr_misa;
reg [31:0] csr_mie;
reg [31:0] csr_mtvec;
reg [31:0] csr_mscratch;
reg [31:0] csr_mepc;
reg [31:0] csr_mcause;
reg [31:0] csr_mtval;
reg [31:0] csr_mip;
reg [63:0] csr_mcycle;
reg [63:0] csr_minstret;

reg [31:0] trap_vector;
reg [31:0] write_data;

wire [31:0] pending_interrupts;
wire [31:0] enabled_interrupts;
wire has_interrupt;
reg [4:0] interrupt_cause;
wire interrupt_enabled;

assign interrupt_enabled = csr_mstatus[MIE_BIT];
assign pending_interrupts = csr_mip & csr_mie;
assign enabled_interrupts = pending_interrupts & {32{interrupt_enabled}};
assign has_interrupt = |enabled_interrupts;

always @(*) begin
    if (enabled_interrupts[MEIE_BIT])
        interrupt_cause = M_EXT_INT_CAUSE;
    else if (enabled_interrupts[MTIE_BIT])
        interrupt_cause = M_TIMER_INT_CAUSE;
    else if (enabled_interrupts[MSIE_BIT])
        interrupt_cause = M_SW_INT_CAUSE;
    else
        interrupt_cause = 5'h0;
end

always @(*) begin
    if (exception) begin
        if (csr_mtvec[1:0] == 2'b01)
            trap_vector = {csr_mtvec[31:2], 2'b00} + (exception_code << 2);
        else
            trap_vector = {csr_mtvec[31:2], 2'b00};
    end else if (has_interrupt) begin
        if (csr_mtvec[1:0] == 2'b01)
            trap_vector = {csr_mtvec[31:2], 2'b00} + (interrupt_cause << 2);
        else
            trap_vector = {csr_mtvec[31:2], 2'b00};
    end else begin
        trap_vector = {csr_mtvec[30:2], 2'b00};
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        csr_mstatus  <= 32'h0;
        csr_misa     <= 32'h40001100;
        csr_mie      <= 32'h0;
        csr_mtvec    <= 32'h0;
        csr_mscratch <= 32'h0;
        csr_mepc     <= 32'h0;
        csr_mcause   <= 32'h0;
        csr_mtval    <= 32'h0;
        csr_mip      <= 32'h0;
        csr_mcycle   <= 64'h0;
        csr_minstret <= 64'h0;
    end else begin

        csr_mcycle <= csr_mcycle + 1;

        csr_mip[MSIE_BIT] <= m_software_interrupt;
        csr_mip[MTIE_BIT] <= m_timer_interrupt;
        csr_mip[MEIE_BIT] <= m_external_interrupt;

        if (exception || (has_interrupt && !mret)) begin
            csr_mepc <= pc;
            csr_mstatus[MPIE_BIT] <= csr_mstatus[MIE_BIT];
            csr_mstatus[MIE_BIT] <= 1'b0;

            if (exception)
                csr_mcause <= {1'b0, 26'b0, exception_code};
            else if (has_interrupt)
                csr_mcause <= {1'b1, 26'b0, interrupt_cause};
        end

        if (mret) begin
            csr_mstatus[MIE_BIT] <= csr_mstatus[MPIE_BIT];
            csr_mstatus[MPIE_BIT] <= 1'b1;
        end

        if (csr_enable) begin
            case (funct3)
                3'b001: write_data = rs1_data;
                3'b010: write_data = csr_read_data | rs1_data;
                3'b011: write_data = csr_read_data & ~rs1_data;
                3'b101: write_data = {27'b0, imm};
                3'b110: write_data = csr_read_data | {27'b0, imm};
                3'b111: write_data = csr_read_data & ~{27'b0, imm};
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

        if (!exception && !has_interrupt)
            csr_minstret <= csr_minstret + 1;
    end
end

reg [31:0] csr_read_data1;
reg [31:0] csr_read_data2;
reg [31:0] pc_reg;

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
        default:  csr_read_data1 = 32'h0;
    endcase
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        csr_read_data2 <= 0;
        pc_reg <= 0;
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
            default:  csr_read_data2 <= 32'h0;
        endcase
        pc_reg <= pc;
    end
end

always @(*) begin
    if (pc_reg == pc)
        csr_read_data = csr_read_data2;
    else
        csr_read_data = csr_read_data1;
end

always @(*) begin
    if (exception) begin
        csr_jmp = trap_vector;
        csr_pc_src = 1;
    end else if (mret) begin
        csr_jmp = csr_mepc + 4;
        csr_pc_src = 1;
    end else if (has_interrupt) begin
        csr_jmp = trap_vector;
        csr_pc_src = 1;
    end else begin
        csr_jmp = 0;
        csr_pc_src = 0;
    end
end

endmodule
