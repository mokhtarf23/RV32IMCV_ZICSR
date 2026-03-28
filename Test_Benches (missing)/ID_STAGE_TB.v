module ID_STAGE_TB();
reg clk, reset;
///////General Input Ouputs///////
reg [31:0] PC_ID_i, Next_PC_ID_i;
reg [31:0] Instr_ID_i;
reg [4:0] Rd_Addr_ID_i;
reg [31:0] Rd_ID_i;
reg FLUSH_ID_ID_i;
reg STALL_ID_ID_i;
reg WR_EN_ID_i;
reg Zero_Flag_ID_i;
reg Greater_Equal_Flag_ID_i;
wire [31:0] Instr_ID_o;

//////Decoder Outputs//////////
wire CSRXXX_ID_o;
wire [31:0] CSR_Imm_ID_o;
wire Exception_ID_o;
wire [3:0] Exception_Info_ID_o;
wire [31:0] Imm_ID_o;
wire Load_ID_o;
wire JALR_Flag_ID_o;
wire WR_EN_ID_o;

//////GPR Outputs///////////
wire [31:0] RS1_ID_o;
wire [31:0] RS2_ID_o;

//////PC Outputs///////////
wire [31:0] PC_ID_o;
wire [31:0] Next_PC_ID_o;

//////Branching Unit Outputs///////
wire PC_Control_Signal_IF_ID_o;
wire [31:0] B_J_Target_IF_ID_o;

//////Signal Outputs////////
wire [4:0] Rs1_Addr_ID_o;
wire [4:0] Rs2_Addr_ID_o;
wire [4:0] RD_Addr_ID_o;

ID_STAGE U1 (
	.B_J_Target_IF_ID_o       (B_J_Target_IF_ID_o),
	.clk                      (clk),
	.reset                    (reset),
	.PC_ID_i                  (PC_ID_i),
	.Next_PC_ID_i             (Next_PC_ID_i),
	.Instr_ID_i               (Instr_ID_i),
	.Rd_Addr_ID_i             (Rd_Addr_ID_i),
	.Rd_ID_i                  (Rd_ID_i),
	.FLUSH_ID_ID_i            (FLUSH_ID_ID_i),
	.STALL_ID_ID_i            (STALL_ID_ID_i),
	.WR_EN_ID_i               (WR_EN_ID_i),
	.Zero_Flag_ID_i           (Zero_Flag_ID_i),
	.Greater_Equal_Flag_ID_i  (Greater_Equal_Flag_ID_i),
	.PC_ID_o                  (PC_ID_o),
	.Imm_ID_o                 (Imm_ID_o),
	.RS1_ID_o                 (RS1_ID_o),
	.RS2_ID_o                 (RS2_ID_o),
	.Load_ID_o                (Load_ID_o),
	.Instr_ID_o               (Instr_ID_o),
	.WR_EN_ID_o               (WR_EN_ID_o),
	.CSRXXX_ID_o              (CSRXXX_ID_o),
	.CSR_Imm_ID_o             (CSR_Imm_ID_o),
	.Next_PC_ID_o             (Next_PC_ID_o),
	.RD_Addr_ID_o             (RD_Addr_ID_o),
	.Rs1_Addr_ID_o            (Rs1_Addr_ID_o),
	.Rs2_Addr_ID_o            (Rs2_Addr_ID_o),
	.Exception_ID_o           (Exception_ID_o),
	.JALR_Flag_ID_o           (JALR_Flag_ID_o),
	.Exception_Info_ID_o      (Exception_Info_ID_o),
	.PC_Control_Signal_IF_ID_o(PC_Control_Signal_IF_ID_o)
	);


initial begin
	clk=1;
	forever begin
		#50 clk=~clk;
	end
end

initial begin
///////INITIALIZATION AND RESET///////
	PC_ID_i=4;
	Next_PC_ID_i=8;
	Instr_ID_i=32'b0;
	Rd_Addr_ID_i=5'b01010;
	Rd_ID_i=50;
	FLUSH_ID_ID_i=0;
	STALL_ID_ID_i=0;
	WR_EN_ID_i=1;
	Zero_Flag_ID_i=0;
	Greater_Equal_Flag_ID_i=0;
	reset=1;
	#100;
	reset=0;


	Instr_ID_i=32'h00A282B3;
	#100;

	Instr_ID_i=32'b000000010000_01010_000_00101_0010011;
	#101;
	$stop;
end

initial begin
	$monitor("Time:%0t Rs1_Addr=%b | Rs2_Addr=%b | Imm_ID_o=%d",$time,Rs1_Addr_ID_o, Rs2_Addr_ID_o, Imm_ID_o);
end
endmodule