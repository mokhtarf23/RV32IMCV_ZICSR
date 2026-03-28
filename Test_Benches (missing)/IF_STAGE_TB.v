module IF_STAGE_TB ();
	reg clk;
	reg reset;
	reg [31:0] CSR_JMP;
	reg [31:0] BRNCH_JMP_TRGT;
	reg [31:0] JALR_TRGT;
    reg CSR_PC_SRC_IF_i;
    reg BRANCH_PC_SRC_IF_i;
    reg JALR_PC_SRC_IF_i;
    reg STALL_IF_IF_i;

	wire [31:0] PC_IF_o;
	wire [31:0] NEXT_PC_IF_o;
	wire [31:0] Instr_IF_o;

IF_STAGE U1 (
	.CSR_JMP           (CSR_JMP),
	.clk               (clk),
	.reset             (reset),
	.BRNCH_JMP_TRGT    (BRNCH_JMP_TRGT),
	.JALR_TRGT         (JALR_TRGT),
	.CSR_PC_SRC_IF_i   (CSR_PC_SRC_IF_i),
	.BRANCH_PC_SRC_IF_i(BRANCH_PC_SRC_IF_i),
	.JALR_PC_SRC_IF_i  (JALR_PC_SRC_IF_i),
	.STALL_IF_IF_i     (STALL_IF_IF_i),
	.PC_IF_o           (PC_IF_o),
	.NEXT_PC_IF_o      (NEXT_PC_IF_o),
	.Instr_IF_o        (Instr_IF_o)
		);

initial begin
	clk=1;
	forever begin
		#50 clk=~clk;
	end
end

initial begin
	reset=1;
	STALL_IF_IF_i=0;
	CSR_PC_SRC_IF_i=0;
	BRANCH_PC_SRC_IF_i=0;
	JALR_PC_SRC_IF_i=0;
	#100
	reset=0;
	#1300;
	$stop;
end

initial begin
	$monitor("Time=%0t | PC=%d | NEXT_PC=%d | Instr=%h",$time, PC_IF_o, NEXT_PC_IF_o, Instr_IF_o);
end

endmodule