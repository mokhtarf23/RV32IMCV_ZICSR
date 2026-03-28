module EX_STAGE_TB();
	reg clk, rst;
	reg [31:0] Instr_EX_i;
	reg [31:0] PC_EX_i, Next_PC_EX_i;
	reg [31:0] Imm_EX_i;
	reg [31:0] Rs1_EX_i;
	reg [31:0] Rs2_EX_i;
	reg WR_EN_EX_i;
	///////Hazards and Forwarding/////
	reg [4:0] Rs1_Addr_EX_i,Rs2_Addr_EX_i,Rs1_Addr_D_i,Rs2_Addr_D_i;
	reg [4:0] Rd_Addr_M_i, Rd_Addr_EX_i;
	reg [31:0] EX_OUT_M_i;
	reg is_load_EX_i;
	///////Exceptions and CSR/////
	reg [4:0] Exception_Info_EX_i; //not sure about the size
	reg Exception_EX_i, CSRXXX_EX_i;

	wire [31:0] Next_PC_EX_o; ///FOR JUMP//
	wire [31:0] Rs1_EX_o; ///FOR CSR///
	wire [31:0] Rs2_EX_o; ///FOR LOAD//
	wire [4:0] Rd_Addr_EX_o; ///For WB///
	wire [31:0] EX_OUT_EX_o;//EX OUT//
	wire [31:0] Instr_EX_o;
	wire WR_EN_EX_o;
	wire PC_EX_o;

///////Hazards and Forwarding/////
	wire  STALL_PC_EX_o,STALL_IF_EX_o,STALL_ID_EX_o,FLUSH_ID_EX_o;

///////Exceptions and CSR/////
	wire [4:0] Exception_Info_EX_o; //not sure about the size
	wire Exception_EX_o, CSRXXX_EX_o;

//////ALU FLAGS///////
	wire Less_Than_Flag_EX_o, Greater_Equal_Flag_EX_o, Zero_Flag_EX_o;

	localparam Cycle=100;

	EX_STAGE U1 (.rst                    (rst),
		.clk                    (clk),
		.PC_EX_i                (PC_EX_i),
		.Next_PC_EX_i              (Next_PC_EX_i),
		.Instr_EX_i             (Instr_EX_i),
		.Imm_EX_i               (Imm_EX_i),
		.Rs1_EX_i               (Rs1_EX_i),
		.Rs2_EX_i               (Rs2_EX_i),
		.WR_EN_EX_i             (WR_EN_EX_i),
		.PC_EX_o                (PC_EX_o),
		.is_load_EX_i           (is_load_EX_i),
		.CSRXXX_EX_i            (CSRXXX_EX_i),
		.Rd_Addr_M_i            (Rd_Addr_M_i),
		.Rs1_Addr_D_i           (Rs1_Addr_D_i),
		.Rs2_Addr_D_i           (Rs2_Addr_D_i),
		.FLUSH_ID_EX_o          (FLUSH_ID_EX_o),
		.Rs1_Addr_EX_i          (Rs1_Addr_EX_i),
		.Rs2_Addr_EX_i          (Rs2_Addr_EX_i),
		.STALL_ID_EX_o          (STALL_ID_EX_o),
		.STALL_IF_EX_o          (STALL_IF_EX_o),
		.STALL_PC_EX_o          (STALL_PC_EX_o),
		.Exception_EX_i         (Exception_EX_i),
		.Zero_Flag_EX_o         (Zero_Flag_EX_o),
		.Exception_Info_EX_i    (Exception_Info_EX_i),
		.Less_Than_Flag_EX_o    (Less_Than_Flag_EX_o),
		.Greater_Equal_Flag_EX_o(Greater_Equal_Flag_EX_o),
		.Next_PC_EX_o              (Next_PC_EX_o),
		.Rs1_EX_o               (Rs1_EX_o),
		.Rs2_EX_o               (Rs2_EX_o),
		.EX_OUT_M_i             (EX_OUT_M_i),
		.Instr_EX_o             (Instr_EX_o),
		.WR_EN_EX_o             (WR_EN_EX_o),
		.CSRXXX_EX_o            (CSRXXX_EX_o),
		.EX_OUT_EX_o            (EX_OUT_EX_o),
		.Rd_Addr_EX_i           (Rd_Addr_EX_i),
		.Rd_Addr_EX_o           (Rd_Addr_EX_o),
		.Exception_EX_o         (Exception_EX_o),
		.Exception_Info_EX_o    (Exception_Info_EX_o)
		);

	initial begin
		clk=0;
		forever begin
			#50 clk=~clk;
		end
	end

	initial begin
		rst=0;
		#Cycle;
		rst=1;
		Imm_EX_i=32'd50;
		Rs1_EX_i=32'd500;
		Rs2_EX_i=32'd20;

		Rs1_Addr_EX_i=1;Rs2_Addr_EX_i=2;Rs1_Addr_D_i=3;Rs2_Addr_D_i=4;
		Rd_Addr_M_i=5; Rd_Addr_EX_i=6;
		EX_OUT_M_i=7;


		$display("Testcase 1: R_type");
		Instr_EX_i=32'b0000001_xxxxx_xxxxx_100_xxxxx_0110011;
		#(35*Cycle);
		$display("EX_OUT=%d", EX_OUT_EX_o);
$stop;
	end
endmodule


