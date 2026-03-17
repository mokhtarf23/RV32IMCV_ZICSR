module IF_STAGE (
    input clk,
    input reset,
    input [31:0] CSR_JMP_IF_i,
    input [31:0] BRNCH_JMP_TRGT_IF_i,
    input [31:0] JALR_TRGT_IF_i,
    input CSR_PC_SRC_IF_i,
    input BRANCH_PC_SRC_IF_i,
    input JALR_PC_SRC_IF_i,
    input STALL_IF_IF_i,stall_IF_vector_i,
    input FLUSH_IF_ID_i,FLUSH_IF_EX_i,

    output reg [31:0] PC_IF_o,
    output reg [31:0] NEXT_PC_IF_o,
    output reg [31:0] Instr_IF_o
);



// Internal signals
    
    wire is_compressed;
    wire [31:0] PC_IN;
    wire [31:0] Instr;

    reg [1:0] PC_SRC_CTRL;
    always @(*) begin
        if (CSR_PC_SRC_IF_i) begin
            PC_SRC_CTRL=2'b11;
        end else if (JALR_PC_SRC_IF_i) begin
            PC_SRC_CTRL=2'b10;
        end else if (BRANCH_PC_SRC_IF_i) begin
            PC_SRC_CTRL=2'b01;
        end else begin
            PC_SRC_CTRL=2'b00;
        end
    end


    reg [31:0] PC_IF_o_reg;
    reg [31:0] NEXT_PC_IF_o_reg;
    reg [31:0] Instr_IF_o_reg;

    wire [31:0] PC_IF_o_wire;
    wire [31:0] NEXT_PC_IF_o_wire;
    wire [31:0] Instr_IF_o_wire;

    always @(*) begin
        PC_IF_o_reg=PC_IF_o_wire;
        NEXT_PC_IF_o_reg=NEXT_PC_IF_o_wire;
        Instr_IF_o_reg=Instr_IF_o_wire;
    end


always@(posedge clk or posedge reset) begin
    if (reset) begin
        PC_IF_o_reg <= 0;
        NEXT_PC_IF_o_reg <= 0;
        Instr_IF_o_reg <= 0;

        PC_IF_o <= 0;
        NEXT_PC_IF_o <= 0;
        Instr_IF_o <=0;
    end else if (FLUSH_IF_ID_i || FLUSH_IF_EX_i) begin
        PC_IF_o <= 0;
        NEXT_PC_IF_o <= 0;
        Instr_IF_o <=0;
    end else if(!STALL_IF_IF_i && !stall_IF_vector_i) begin
        PC_IF_o <= PC_IF_o_reg;
        NEXT_PC_IF_o <= NEXT_PC_IF_o_reg;
        Instr_IF_o <=Instr_IF_o_reg;
    end else begin
        
    end
end


    // Instantiate mux
    MUX4X1 mux (
        .in1(NEXT_PC_IF_o_wire),
        .in2(BRNCH_JMP_TRGT_IF_i),
        .in3(JALR_TRGT_IF_i),
        .in4(CSR_JMP_IF_i),
        .sel(PC_SRC_CTRL),
        .out(PC_IN)
    );

    // Instantiate the PC module
    PC pc (
        .clk(clk),
        .reset(reset),
        .stall_PC(STALL_IF_IF_i || stall_IF_vector_i),
        .next_addr(PC_IN),
        .current_addr(PC_IF_o_wire)
    );

    aligner aligner(
        .current_pc(PC_IF_o_wire),
        .compressed_instr(is_compressed),
        .PC_INC(NEXT_PC_IF_o_wire)
        );

    // Instantiate compressed instruction decoder
    compressed_instruct_decoder decoder (
        .input_instruction(Instr), 
        .expanded_instruction(Instr_IF_o_wire),
        .illegal_instruction(illegal_instruct),
        .is_compressed(is_compressed) 
    );

    // Instantiate instruction memory
    instruction_memory memory (
        .addr(PC_IF_o_wire),
        .instruct(Instr),
        .clk(clk)
        );



endmodule