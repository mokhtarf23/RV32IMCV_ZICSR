module EX_STAGE(
	input clk, rst,
///////General Input Ouputs///////
	input [31:0] Instr_EX_i,
	input [31:0] PC_EX_i, Next_PC_EX_i,
	input [31:0] Imm_EX_i,
	input [31:0] Rs1_EX_i,
	input [31:0] Rs2_EX_i,
	input WR_EN_EX_i,
	input WR_EN_WB_EX_i,
	input JALR_Flag_EX_i,
	input is_load_WB_EX_i,

	output reg [31:0] Next_PC_EX_o, ///FOR JUMP//
	output reg [31:0] Rs1_EX_o, ///FOR CSR///
	output reg [31:0] Rs2_EX_o, ///FOR LOAD//
	output reg [4:0] Rd_Addr_EX_o, ///For WB///
	output reg [31:0] EX_OUT_EX_o, //EX OUT//
	output reg [31:0] Instr_EX_o,
	output reg WR_EN_EX_o,
	output reg [31:0] PC_EX_o,
	output reg JALR_Flag_EX_o,
	output reg [31:0] JALR_TRGT_EX_o,

///////Hazards and Forwarding/////
	input [4:0] Rs1_Addr_EX_i,Rs2_Addr_EX_i,Rs1_Addr_D_i,Rs2_Addr_D_i,
	input [4:0] Rd_Addr_M_i, Rd_Addr_EX_i,
	input [31:0] EX_OUT_M_i,
	input is_load_EX_i,
	input [6:0] opcode_ID_EX_i, ///FOR CSR INSTR
	input FRWRD_EN,

	output reg  STALL_PC_EX_o,STALL_IF_EX_o,STALL_ID_EX_o,FLUSH_ID_EX_o,is_load_EX_o,

///////Exceptions and CSR/////
	input [4:0] Exception_Info_EX_i, //not sure about the size
	input Exception_EX_i, CSRXXX_EX_i,
	input [31:0] CSR_Imm_EX_i,

	output reg [4:0] Exception_Info_EX_o, //not sure about the size
	output reg Exception_EX_o, CSRXXX_EX_o,
	output reg [31:0] CSR_Imm_EX_o,

//////ALU FLAGS///////
	output reg Less_Than_Flag_EX_o, Greater_Equal_Flag_EX_o, Zero_Flag_EX_o,
//////FORWARDING SIGNALS FOR GPR//////
	output reg Frwrd_Sel5_EX_o, Frwrd_Sel6_EX_o
	);

////FOR OP2_SEL and EX_OUT_Sel///
localparam Rtype=7'b0110011;
localparam Itype=7'b0010011;
localparam STORE=7'b0100011;
localparam LOAD=7'b0000011;
localparam JALR=7'b1100111;

localparam LUI=7'b0110111;
localparam AUIPC=7'b0010111;



////registers for General outputs
reg [31:0] PC_EX_o_reg;
reg [31:0] Next_PC_EX_o_reg;
reg [31:0] Rs1_EX_o_reg;
reg [31:0] Rs2_EX_o_reg;
reg [4:0] Rd_Addr_EX_o_reg;
reg [31:0] Instr_EX_o_reg;
reg [31:0] EX_OUT_EX_o_reg;
reg WR_EN_EX_o_reg;
reg is_load_EX_o_reg;
 
//// NO REGISTERS FOR HAZARDS AND FORWARDING BECAUSE THEY ONLY GO BACK IN THE PIPELINE////

///Registers for Exceptions and csr//////
reg Exception_EX_o_reg,CSRXXX_EX_o_reg;
reg [4:0] Exception_Info_EX_o_reg;
reg [31:0] CSR_Imm_EX_o_reg;

///WIRES FOR STALL AND FLAGS
wire  STALL_PC_EX_o_wire,STALL_IF_EX_o_wire,STALL_ID_EX_o_wire,FLUSH_ID_EX_o_wire;
wire Less_Than_Flag_EX_o_wire, Greater_Equal_Flag_EX_o_wire, Zero_Flag_EX_o_wire;
wire STALL_EX_wire;


////////////////Operand Selection ALU////////////////////////
wire signed [31:0]  Op1_final; /// output of forwarding mux for OP1
wire signed [31:0]  Op2_Src1; ///output of first mux for Op2
wire signed [31:0]  Op2_final; ///output of second mux for Op2 (Forwarding)

wire signed [31:0]  Rs1_EX_o_final;
wire signed [31:0]  Rs2_EX_o_final;


//For hazard and forwarding
reg Op2_Sel;
wire mult_div_stall; //FOR MULT/DIV

//FOR ALU///
reg[6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;
wire signed [31:0] ALU_OUT_EX;

//FOR BOTH ALU AND GPR FORWARDING
wire Frwrd_Sel1, Frwrd_Sel2,Frwrd_Sel3, Frwrd_Sel4,Frwrd_Sel5_o_wire, Frwrd_Sel6_o_wire;
always @(*) begin
	Exception_EX_o_reg=Exception_EX_i;
	Exception_Info_EX_o_reg=Exception_Info_EX_i;
	CSRXXX_EX_o_reg=CSRXXX_EX_i;
	CSR_Imm_EX_o_reg=CSR_Imm_EX_i;

	Next_PC_EX_o_reg=Next_PC_EX_i;
	PC_EX_o_reg=PC_EX_i;
	Rs1_EX_o_reg=Rs1_EX_o_final;
	Rs2_EX_o_reg=Rs2_EX_o_final;
	Rd_Addr_EX_o_reg=Rd_Addr_EX_i;
	Instr_EX_o_reg=Instr_EX_i;
	WR_EN_EX_o_reg=WR_EN_EX_i;
	JALR_Flag_EX_o=JALR_Flag_EX_i;
	JALR_TRGT_EX_o=ALU_OUT_EX;

	STALL_PC_EX_o=STALL_PC_EX_o_wire;
	STALL_IF_EX_o=STALL_IF_EX_o_wire;
	STALL_ID_EX_o=STALL_ID_EX_o_wire;
	FLUSH_ID_EX_o=FLUSH_ID_EX_o_wire;
	Less_Than_Flag_EX_o=Less_Than_Flag_EX_o_wire;
	Greater_Equal_Flag_EX_o=Greater_Equal_Flag_EX_o_wire;
	Zero_Flag_EX_o=Zero_Flag_EX_o_wire;
	Frwrd_Sel5_EX_o=Frwrd_Sel5_o_wire;
	Frwrd_Sel6_EX_o=Frwrd_Sel6_o_wire;
	is_load_EX_o_reg=is_load_EX_i;
end

///// NO REGISTERS FOR ALU FLAGS ALSO BECAUSE THE ONLY GO BACK IN THE PIPELINE////

always @(posedge clk or posedge rst) begin
	if(rst) begin
		 PC_EX_o_reg<=0;
		 Next_PC_EX_o_reg<=0;
		 Rs1_EX_o_reg<=0;
		 Rs2_EX_o_reg<=0;
		 Rd_Addr_EX_o_reg<=0;
		 Instr_EX_o_reg<=0;
		 EX_OUT_EX_o_reg<=0;
		 Exception_EX_o_reg<=0;
		 Exception_Info_EX_o_reg<=0;
		 CSRXXX_EX_o_reg<=0;
		 WR_EN_EX_o_reg<=0;
		 CSR_Imm_EX_o_reg<=0;
		 is_load_EX_o_reg<=0;

		 PC_EX_o<=0;
		 Next_PC_EX_o<=0;
		 Rs1_EX_o<=0;
		 Rs2_EX_o<=0;
		 Rd_Addr_EX_o<=0;
		 Instr_EX_o<=0;
		 EX_OUT_EX_o<=0;
		 Exception_EX_o<=0;
		 Exception_Info_EX_o<=0;
		 CSRXXX_EX_o<=0;
		 WR_EN_EX_o<=0;
		 STALL_PC_EX_o<=0;
		 STALL_IF_EX_o<=0;
		 STALL_ID_EX_o<=0;
		 FLUSH_ID_EX_o<=0;
		 CSR_Imm_EX_o<=0;
		 is_load_EX_o<=0;


	end else if(!STALL_EX_wire) begin
		 PC_EX_o<=PC_EX_o_reg;
		 Next_PC_EX_o<=Next_PC_EX_o_reg;
		 Rs1_EX_o<=Rs1_EX_o_reg;
		 Rs2_EX_o<=Rs2_EX_o_reg;
		 Rd_Addr_EX_o<=Rd_Addr_EX_o_reg;
		 Instr_EX_o<=Instr_EX_o_reg;
		 EX_OUT_EX_o<=EX_OUT_EX_o_reg;
		 Exception_EX_o<=Exception_EX_o_reg;
		 Exception_Info_EX_o<=Exception_Info_EX_o_reg;
		 CSRXXX_EX_o<=CSRXXX_EX_o_reg;
		 WR_EN_EX_o<=WR_EN_EX_o_reg;
		 CSR_Imm_EX_o<=CSR_Imm_EX_o_reg;
		 is_load_EX_o<=is_load_EX_o_reg;
	end else begin
		
	end
end


////////////////////////////////INTERNAL SIGNALS//////////////////////////////

////////////////Operand Selection////////////////////////



always @(*) begin
	opcode=Instr_EX_i[6:0];
	funct3=Instr_EX_i[14:12];
	funct7=Instr_EX_i[31:25];
end
//FOR MULT/DIV///
wire signed [31:0]  MULT_DIV_OUT;
wire mult_div_rst;
assign mult_div_rst=(opcode==Rtype && funct7==7'd1 && !rst)? 0:1;

////U_TYPE/////
wire [31:0] U_TYPE_OUT;

/////FOR OUTPUT  MUX///////
reg [1:0] EX_OUT_Sel;

MUX2X1 Frwrd_Mux_1 (
	.in1(Rs1_EX_i),
	.in2(EX_OUT_M_i),
	.sel(Frwrd_Sel1),
	.out(Op1_final)
	);
always@(*) begin
Op2_Sel= ((opcode==Itype)||(opcode==JALR)||(opcode==STORE)||(opcode==LOAD))? 1:0; //FOR IMMEDIATE
end
MUX2X1 Op2_Src (
	.in1(Rs2_EX_i),
	.in2(Imm_EX_i),
	.sel(Op2_Sel),
	.out(Op2_Src1)
	);

MUX2X1 Frwrd_Mux_2 (
	.in1(Op2_Src1),
	.in2(EX_OUT_M_i),
	.sel(Frwrd_Sel2),
	.out(Op2_final)
	);

MUX2X1 Frwrd_Mux_3 (
	.in1(Rs1_EX_i),
	.in2(EX_OUT_M_i),
	.sel(Frwrd_Sel3),
	.out(Rs1_EX_o_final)
	);

MUX2X1 Frwrd_Mux_4 (
	.in1(Rs2_EX_i),
	.in2(EX_OUT_M_i),
	.sel(Frwrd_Sel4),
	.out(Rs2_EX_o_final)
	);

//////////FORWARD HAZARD UNIT////////////
FORWARD_HAZARD_UNIT FORWARD_HAZARD_UNIT1 (
	.clk(clk),
	.rst(rst),
	.Rs1_Addr_E(Rs1_Addr_EX_i),
	.Rs2_Addr_E(Rs2_Addr_EX_i),
	.Rd_Addr_E(Rd_Addr_EX_i),
	.Rs1_Addr_D(Rs1_Addr_D_i),
	.Rs2_Addr_D(Rs2_Addr_D_i),
	.Rd_Addr_M(Rd_Addr_M_i),
	.WR_EN(WR_EN_WB_EX_i),
	.FRWRD_EN(FRWRD_EN),
	.is_load(is_load_EX_i),
	.is_load_WB (is_load_WB_EX_i),
	.opcode(opcode),
	.opcode_ID     (opcode_ID_EX_i),
	.funct3(funct3),
	.mult_div_stall(mult_div_stall),
	.Sel1(Frwrd_Sel1),
	.Sel2(Frwrd_Sel2),
	.Sel3 (Frwrd_Sel3),
	.Sel4(Frwrd_Sel4),
	.Sel5(Frwrd_Sel5_o_wire),
	.Sel6(Frwrd_Sel6_o_wire),
	.STALL_IF(STALL_IF_EX_o_wire),
	.STALL_ID(STALL_ID_EX_o_wire),
	.FLUSH_ID(FLUSH_ID_EX_o_wire),
	.STALL_PC(STALL_PC_EX_o_wire),
	.STALL_EX(STALL_EX_wire)
	);


/////////////ALU/////////////////




ALU ALU1 (
	.Op1(Op1_final),
	.Op2(Op2_final),
	.opcode(opcode),
	.funct3(funct3),
	.funct7(funct7),
	.ALU_OUT(ALU_OUT_EX),
	.Less_Than_Flag(Less_Than_Flag_EX_o_wire),
	.Greater_Equal_Flag(Greater_Equal_Flag_EX_o_wire),
	.Zero_Flag(Zero_Flag_EX_o_wire)
	);

////////U_TYPE//////////
U_TYPE U_TYPE1(
	.pc(PC_EX_i),
	.Imm(Imm_EX_i),
	.opcode(opcode),
	.U_TYPE_OUT(U_TYPE_OUT)
	);

/////////MULT/DIV UNIT/////////////

MULT_DIV MULT_DIV1 (
	.clk(clk),
	.rst(mult_div_rst),
	.Op1(Op1_final),
	.Op2(Op2_final),
	.funct3(funct3),
	.mult_div_stall(mult_div_stall),
	.MULT_DIV_OUT(MULT_DIV_OUT)
	);



////////EX_OUT MUX/////////
always @(*) begin
	case (opcode)
		LUI, AUIPC: EX_OUT_Sel=2'b00; //UTYPE OUT
		Rtype: begin 
			if (funct7==7'd1) begin
				EX_OUT_Sel=2'b10; //MULT OUT
			end else begin
				EX_OUT_Sel=2'b01; //ALU OUT
			end
		end
		default: EX_OUT_Sel=2'b01; //ALU_OUT
	endcase
end

wire [31:0] EX_OUT_MUX;
MUX3X1 OutputMux (
	.in1(U_TYPE_OUT),
	.in2(ALU_OUT_EX),
	.in3(MULT_DIV_OUT),
	.sel(EX_OUT_Sel),
	.out(EX_OUT_MUX)
	);

always @(*) begin
	EX_OUT_EX_o_reg=EX_OUT_MUX;
end 

endmodule