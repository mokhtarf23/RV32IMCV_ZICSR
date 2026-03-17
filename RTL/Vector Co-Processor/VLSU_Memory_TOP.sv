module TopVLSU (
    input clk,
    input rst,

    input [2:0] width_en_i,
    input [1:0] mop_i,
    input vm_i,
    input [6:0] opcode_i,

    input [31:0] rs1_data_i,
    input [31:0] rs2_data_i,
    input [127:0] vs2_data_i,
    input [127:0] vs3_data_i,
    input [127:0] mask_data_i,
    input vma_i,


    input [31:0] vector_length_i,
    input valid_i,
    input [5:0] ID_i,
    input [4:0] Vd_addr_i,

    output reg valid_o_b1,
    output reg busy_o,
    output reg [5:0] ID_o_b1,
    output reg [4:0]Vd_addr_o_b1,
    output reg [127:0] Vd_o
);
localparam [6:0] VLOAD   = 7'b0000111;
wire load;
assign load = opcode_i==VLOAD;
    wire [31:0] read_data_b1;
    wire memory_ready_b1;    
    wire valid_o_b1_lsu;
    wire valid_o_b1_mem;
    wire [5:0] ID_o_b1_lsu;
    wire [4:0] Vd_addr_o_b1_lsu;
    wire [31:0] memory_address_b1;
    wire memory_write_enable_b1;
    wire [31:0] memory_data_b1;
    wire [1:0] byte_en_b1;
    wire [2:0] SEW_lsu, SEW_mem;

    wire [5:0] ID_o_mem;
    wire [4:0] Vd_addr_o_mem;

    wire busy_o_VLSU;


     wire [1:0] mop_o_dissassembler;
     wire [2:0] width_en_o_dissassembler;
     wire vm_o_dissassembler;
     wire [6:0] opcode_o_dissassembler;
     wire [31:0] rs1_data_o_dissassembler;
     wire [31:0] rs2_data_o_dissassembler;
     wire [127:0] mask_data_o_dissassembler;
     wire vma_o_dissassembler;
     wire [31:0] vector_length_o_dissassembler;
     wire [5:0] ID_o_dissassembler;
     wire [4:0] Vd_addr_o_dissassembler;
     wire valid_o_dissassembler;
     wire [31:0] data_o1_dissassembler, data_o2_dissassembler;

     memory_disassembler dissassembler (
        .clk            (clk),
        .rst            (rst),
        .Vd_addr_i      (Vd_addr_i),
        .ID_i           (ID_i),
        .valid_i        (valid_i),
        .opcode_i       (opcode),
        .vm_i           (vm_i),
        .mop_i          (mop_i),
        .vma_i          (vma_i),
        .busy_i         (busy_o_VLSU),
        .vector_length_i(vector_length_i),
        .data_i1        (vs2_data),
        .data_i2        (vs3_data),
        .width_en_i     (width_en_i),
        .rs1_data_i     (rs1_data_i),
        .rs2_data_i     (rs2_data_i),
        .mask_data_i    (mask_data_i),
        .ID_o           (ID_o_dissassembler),
        .valid_o        (valid_o_dissassembler),
        .Vd_addr_o      (Vd_addr_o_dissassembler),
        .opcode_o       (opcode_o_dissassembler),
        .busy_o         (busy_o),
        .vm_o           (vm_o_dissassembler),
        .vma_o          (vma_o_dissassembler),
        .vector_length_o(vector_length_o_dissassembler),
        .mop_o          (mop_o_dissassembler),
        .rs1_data_o     (rs1_data_o_dissassembler),
        .rs2_data_o     (rs2_data_o_dissassembler),
        .mask_data_o    (mask_data_o_dissassembler),
        .width_en_o     (width_en_o_dissassembler),
        .data_o1        (data_o1_dissassembler),
        .data_o2        (data_o2_dissassembler)
        );

    VectorLSU VectorLSU (
        .clk                   (clk ),
        .reset                 (rst),
        .width_en              (load? width_en_i:width_en_o_dissassembler),
        .mop                   (load? mop_i:mop_o_dissassembler),
        .vm                    (load? vm_i:vm_o_dissassembler),
        .opcode                (load? opcode_i:opcode_o_dissassembler),
        .rs1_data              (load? rs1_data_i:rs1_data_o_dissassembler),
        .rs2_data              (load? rs2_data_i:rs2_data_o_dissassembler  ),
        .vs2_data              (load? data_i1:data_o1_dissassembler),
        .vs3_data              (load? data_i2:data_o2_dissassembler),
        .mask_data             (load? mask_data_i:mask_data_o_dissassembler  ),
        .vma                   (load? vma_i:vma_o_dissassembler  ),
        .memory_ready_b1       (memory_ready_b1 ),
        .vector_length         (load? vector_length_i:vector_length_o_dissassembler),
        .valid_i               (load? valid_i:valid_o_dissassembler ),
        .ID_i                  (load? ID_i:ID_o_dissassembler ),
        .Vd_addr_i             (load? Vd_addr_i:Vd_addr_o_dissassembler ),
        .busy_o                (busy_o_VLSU),
        .SEW                   (SEW_lsu),

        .valid_o_b1            (valid_o_b1_lsu        ),
        .ID_o_b1               (ID_o_b1_lsu           ),
        .Vd_addr_o_b1          (Vd_addr_o_b1_lsu      ),
        .memory_address_b1     (memory_address_b1     ),
        .memory_write_enable_b1(memory_write_enable_b1),
        .memory_data_b1        (memory_data_b1        ),
        .byte_en_b1            (byte_en_b1            ),
        .busy                  (busy                  ),
        .error                 (error                 )
    );
        
    Memory4Bank Memory4Bank (
        .clk            (clk                   ),
        .reset          (rst                 ),
        .address_b1     (memory_address_b1     ),
        .write_enable_b1(memory_write_enable_b1),
        .valid_i_b1     (valid_o_b1_lsu        ),
        .SEW_i          (SEW_lsu),
        .ID_i_b1        (ID_o_b1_lsu           ),
        .Vd_addr_i_b1   (Vd_addr_o_b1_lsu      ),
        .write_data_b1  (memory_data_b1        ),
        .byte_en_b1     (byte_en_b1            ),
        .valid_o_b1     (valid_o_b1_mem        ),
        .ID_o_b1        (ID_o_mem               ),
        .Vd_addr_o_b1   (Vd_addr_o_mem          ),
        .read_data_b1   (read_data_b1          ),
        .memory_ready_b1(memory_ready_b1       ),
        .SEW_o          (SEW_mem)
    );


    memory_assembler memory_gatherer (
        .clk      (clk),
        .rst      (rst),
        .ID_i     (ID_i),
        .Vd_addr_i(Vd_addr_i),
        .SEW_i    (3'b110),
        .valid_i  (valid_o_b1_mem),
        .data_i   (read_data_b1),
        .ID_o     (ID_o_b1),
        .data_o   (Vd_o),
        .valid_o  (valid_o_b1),
        .Vd_addr_o(Vd_addr_o_b1)
        );


endmodule