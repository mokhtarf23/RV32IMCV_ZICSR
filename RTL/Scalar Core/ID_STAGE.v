module ID_STAGE(
	input clk, reset,
///////General Input Ouputs///////
	input [31:0] PC_ID_i, Next_PC_ID_i,
	input [31:0] Instr_ID_i,
	input [4:0] Rd_Addr_ID_i,
	input [31:0] Rd_ID_i,
	input FLUSH_ID_ID_i,
	input FLUSH_ID_EX_i,
	input STALL_ID_ID_i,
	input WR_EN_ID_i,
	input Zero_Flag_ID_i,
	input Greater_Equal_Flag_ID_i,
	input wire Frwrd_Sel5_ID_i, Frwrd_Sel6_ID_i,


	output reg [31:0] Instr_ID_o,
	output reg [6:0] opcode_ID_o,

//////Decoder Outputs//////////
output reg CSRXXX_ID_o,
output reg [31:0] CSR_Imm_ID_o,
output reg Exception_ID_o,
output reg [4:0] Exception_Info_ID_o,
output reg [31:0] Imm_ID_o,
output reg Load_ID_o,
output reg JALR_Flag_ID_o,
output reg WR_EN_ID_o,

//////GPR Outputs///////////
output reg [31:0] RS1_ID_o,
output reg [31:0] RS2_ID_o,

//////PC Outputs///////////
output reg [31:0] PC_ID_o,
output reg [31:0] Next_PC_ID_o,

//////Branching Unit Outputs///////
output reg PC_Control_Signal_IF_ID_o,
output reg [31:0] B_J_Target_IF_ID_o,
output reg Flush_IF,

//////Signal Outputs////////
output reg [4:0] Rs1_Addr_ID_o,
output reg [4:0] Rs2_Addr_ID_o,

output reg [4:0] Rs1_Addr_ID_Frwrd_o,
output reg [4:0] Rs2_Addr_ID_Frwrd_o,

output reg [4:0] RD_Addr_ID_o,

input req_rs_vector_i,
output reg valid_rs_vector_o, 
output wire vector_valid,
output reg [31:0] Rs1_ID_o_final_vector, Rs2_ID_o_final_vector, Instruction_vector_o,
output reg stall_IF_vector_o
);
localparam [6:0] R_Type = 7'b0110011,
				 I_Type = 7'b0010011,
				 Load_Type = 7'b0000011,
				 S_Type = 7'b0100011,
				 B_Type = 7'b1100011,
				 LUI = 7'b0110111,
				 AUIPC = 7'b0010111,
				 ZCSR = 7'b1110011,
				 Jal = 7'b1101111,
				 Jalr = 7'b1100111,
				 VLOAD = 7'b000111,
				 VSTORE = 7'b0100111,
				 VALU =7'b1010111;

wire Branch_Unit_Enable_ID_wire;	
wire [31:0] Imm_Decoder_Branching_ID_wire;
wire CSRXXX_ID_o_wire;
wire [31:0] CSR_Imm_ID_o_wire;
wire Exception_ID_o_wire;
wire [4:0] Exception_Info_ID_o_wire;
wire [31:0] Imm_ID_o_wire;
wire Load_ID_o_wire;
wire JALR_Flag_ID_o_wire;
wire WR_EN_ID_o_wire;
wire [31:0] RS1_ID_o_wire;
wire [31:0] RS2_ID_o_wire;
wire [31:0] Rs1_ID_o_final;
wire [31:0] Rs2_ID_o_final;
wire Flush_IF_wire;
wire PC_Control_Signal_IF_ID_o_wire;
wire [31:0] B_J_Target_IF_ID_o_wire;


wire FLUSH_ID_ID_Branching;
wire FLUSH_ID_ID_wire;
assign FLUSH_ID_ID_wire=FLUSH_ID_ID_Branching|FLUSH_ID_ID_i;

reg [31:0] Instr_ID_o_reg;
reg [4:0] Rs1_Addr_ID_o_reg;
reg [4:0] Rs2_Addr_ID_o_reg;
reg [4:0] RD_Addr_ID_o_reg;
reg CSRXXX_ID_o_reg;
reg [31:0] CSR_Imm_ID_o_reg;
reg Exception_ID_o_reg;
reg [4:0] Exception_Info_ID_o_reg;
reg [31:0] Imm_ID_o_reg;
reg Load_ID_o_reg;
reg JALR_Flag_ID_o_reg;
reg WR_EN_ID_o_reg;
reg [31:0] RS1_ID_o_reg;
reg [31:0] RS2_ID_o_reg;
reg [31:0] PC_ID_o_reg;
reg [31:0] Next_PC_ID_o_reg;

wire cnfg_instr_vector;
wire cnfg_instr_rs_vector;
assign cnfg_instr_vector = Instr_ID_i[6:0]==VALU && Instr_ID_i[14:12]==3'b111;
assign cnfg_instr_rs_vector = (cnfg_instr_vector && Instr_ID_i[30:25]==6'd0&&Instr_ID_i[31]) ||
							  (cnfg_instr_vector && !Instr_ID_i[31]);
//////VECTOR HANDLING//////
always @(posedge clk) begin
	stall_IF_vector_o<=0;
	valid_rs_vector_o<=0;
	if (Instr_ID_i[6:0]==VLOAD || Instr_ID_i[6:0]==VSTORE || cnfg_instr_rs_vector || (Instr_ID_i[6:0]==VALU && Instr_ID_i[14:12]==3'b100)) begin
		if (req_rs_vector_i) begin
			stall_IF_vector_o<=0;
			valid_rs_vector_o<=1;	
		end else begin
			stall_IF_vector_o<=1;
			valid_rs_vector_o<=0;
		end
	end
end

always @(*)begin
	Instr_ID_o_reg = Instr_ID_i;
	Rs1_Addr_ID_o_reg = Instr_ID_i[19:15];
	Rs2_Addr_ID_o_reg = Instr_ID_i[24:20];
	Rs1_Addr_ID_Frwrd_o = Instr_ID_i[19:15];
	Rs2_Addr_ID_Frwrd_o = Instr_ID_i[24:20];
	RD_Addr_ID_o_reg = Instr_ID_i [11:7];
	opcode_ID_o = Instr_ID_i[6:0];
	PC_ID_o_reg = PC_ID_i;
	Next_PC_ID_o_reg = Next_PC_ID_i;
	Flush_IF=Flush_IF_wire;

	CSRXXX_ID_o_reg = CSRXXX_ID_o_wire;
	CSR_Imm_ID_o_reg = CSR_Imm_ID_o_wire;
	Exception_ID_o_reg = Exception_ID_o_wire;
	Exception_Info_ID_o_reg = Exception_Info_ID_o_wire;
	Imm_ID_o_reg = Imm_ID_o_wire;
	Load_ID_o_reg = Load_ID_o_wire;
	JALR_Flag_ID_o_reg = JALR_Flag_ID_o_wire;
	WR_EN_ID_o_reg = WR_EN_ID_o_wire;

	RS1_ID_o_reg = Rs1_ID_o_final;
	RS2_ID_o_reg = Rs2_ID_o_final;

	PC_Control_Signal_IF_ID_o=PC_Control_Signal_IF_ID_o_wire;
	B_J_Target_IF_ID_o=B_J_Target_IF_ID_o_wire;

	Rs1_ID_o_final_vector=Rs1_ID_o_final;
	Rs2_ID_o_final_vector=Rs2_ID_o_final;
	Instruction_vector_o=Instr_ID_i;
end	

always@(posedge clk or posedge reset)begin
	if(reset)begin
		Instr_ID_o_reg <= 0;
		Rs1_Addr_ID_o_reg <= 0;
		Rs2_Addr_ID_o_reg <= 0;
		RD_Addr_ID_o_reg <= 0;
		CSRXXX_ID_o_reg <= 0;
		CSR_Imm_ID_o_reg <= 0;
		Exception_ID_o_reg <= 0;
		Exception_Info_ID_o_reg <= 0;
		Imm_ID_o_reg <= 0;
		Load_ID_o_reg <= 0;
		JALR_Flag_ID_o_reg <= 0;
		WR_EN_ID_o_reg <= 0;
		RS1_ID_o_reg <= 0;
		RS2_ID_o_reg <= 0;
		PC_ID_o_reg <= 0;
		Next_PC_ID_o_reg <= 0;

		Instr_ID_o <=0;
		CSRXXX_ID_o <=0;
		CSR_Imm_ID_o <=0;
		Exception_ID_o <=0;
		Exception_Info_ID_o <=0;
		Imm_ID_o <=0;
 		Load_ID_o <=0;
		JALR_Flag_ID_o <=0;
		WR_EN_ID_o <=0;
		RS1_ID_o <=0;
		RS2_ID_o <=0;
		PC_ID_o <=0;
		Next_PC_ID_o <=0;
		PC_Control_Signal_IF_ID_o <=0;
		B_J_Target_IF_ID_o <=0;
		Rs1_Addr_ID_o <=0;
		Rs2_Addr_ID_o <=0;
		Rs1_Addr_ID_Frwrd_o<=0;
		Rs2_Addr_ID_Frwrd_o<=0;
		RD_Addr_ID_o <=0;
		opcode_ID_o<=0;
	end

	else if (FLUSH_ID_EX_i)begin
		Instr_ID_o <=0;
		CSRXXX_ID_o <=0;
		CSR_Imm_ID_o <=0;
		Exception_ID_o <=0;
		Exception_Info_ID_o <=0;
		Imm_ID_o <=0;
 		Load_ID_o <=0;
		JALR_Flag_ID_o <=0;
		WR_EN_ID_o <=0;
		RS1_ID_o <=0;
		RS2_ID_o <=0;
		PC_ID_o <=0;
		Next_PC_ID_o <=0;
		PC_Control_Signal_IF_ID_o <=0;
		B_J_Target_IF_ID_o <=0;
		Rs1_Addr_ID_o <=0;
		Rs2_Addr_ID_o <=0;
		Rs1_Addr_ID_Frwrd_o<=0;
		Rs2_Addr_ID_Frwrd_o<=0;
		RD_Addr_ID_o <=0;
		opcode_ID_o<=0;
	end

	else if (!STALL_ID_ID_i)begin
		Instr_ID_o<=Instr_ID_o_reg;
		PC_ID_o <= PC_ID_o_reg;
		Next_PC_ID_o <= Next_PC_ID_o_reg;
		Rs1_Addr_ID_o <= Rs1_Addr_ID_o_reg;
		Rs2_Addr_ID_o <= Rs2_Addr_ID_o_reg;
		RD_Addr_ID_o <= RD_Addr_ID_o_reg;
		CSRXXX_ID_o <= CSRXXX_ID_o_reg;
		CSR_Imm_ID_o <= CSR_Imm_ID_o_reg;
		Exception_ID_o <= Exception_ID_o_reg;
		Exception_Info_ID_o <= Exception_Info_ID_o_reg;
		Imm_ID_o <= Imm_ID_o_reg;
		Load_ID_o <= Load_ID_o_reg;
		JALR_Flag_ID_o <= JALR_Flag_ID_o_reg;
		WR_EN_ID_o <= WR_EN_ID_o_reg;	
		RS1_ID_o <= RS1_ID_o_reg;
		RS2_ID_o <= RS2_ID_o_reg;
	end

	else begin
		
	end
end

MUX2X1 Frwrd_Mux_RS1 (
	.in1(RS1_ID_o_wire),
	.in2(Rd_ID_i),
	.sel(Frwrd_Sel5_ID_i),
	.out(Rs1_ID_o_final)
	);

MUX2X1 Frwrd_Mux_RS2 (
	.in1(RS2_ID_o_wire),
	.in2(Rd_ID_i),
	.sel(Frwrd_Sel6_ID_i),
	.out(Rs2_ID_o_final)
	);

Decoder DECODER (.instruction(Instr_ID_i),
		   .PC(PC_ID_i),
		   .CSRXXX(CSRXXX_ID_o_wire),
		   .stall_IF_vector_o(stall_IF_vector_o),
		   .valid_rs_vector_o       (valid_rs_vector_o),
		   .CSR_Imm(CSR_Imm_ID_o_wire),
		   .Exception(Exception_ID_o_wire),
		   .Exception_Info(Exception_Info_ID_o_wire),
		   .Imm(Imm_ID_o_wire),
		   .Load(Load_ID_o_wire),
		   .Branch_Unit_Enable(Branch_Unit_Enable_ID_wire),
		   .JALR_Flag(JALR_Flag_ID_o_wire),
		   .vector_valid      (vector_valid),
		   .WR_EN(WR_EN_ID_o_wire));

GPR GPR (.clk(clk),
	   .reset(reset),
	   .Address1(Instr_ID_i[19:15]),
	   .Address2(Instr_ID_i[24:20]),
	   .Address3(Rd_Addr_ID_i),
	   .WD_A3(Rd_ID_i),
	   .WR_EN(WR_EN_ID_i),
	   .RD1(RS1_ID_o_wire),
	   .RD2(RS2_ID_o_wire));

Branching_Unit BRANCHING_UNIT ( .clk(clk),
					.reset(reset),
					.Imm(Imm_ID_o_wire),
					.funct3(Instr_ID_i[14:12]),
					.opcode(Instr_ID_i[6:0]),
					.Branch_Unit_Enable(Branch_Unit_Enable_ID_wire),
					.PC(PC_ID_i),
					.Next_PC(Next_PC_ID_i),
					.B_J_Target(B_J_Target_IF_ID_o_wire),
					.PC_Control_Signal(PC_Control_Signal_IF_ID_o_wire),
					.Zero_Flag(Zero_Flag_ID_i),
					.Flush_IF          (Flush_IF_wire),
					.Greater_Equal_Flag(Greater_Equal_Flag_ID_i));

endmodule