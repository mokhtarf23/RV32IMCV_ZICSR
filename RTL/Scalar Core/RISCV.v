module RISCV (
	input clk,reset,
	input req_rs_vector_i,
	input m_software_interrupt,
	input m_external_interrupt,
	input m_timer_interrupt,
	output wire valid_rs_vector_o, instruction_vector_valid_o,
	output wire [31:0] Rs1_ID_o_final_vector, Rs2_ID_o_final_vector,
	output wire [31:0] instruction_vector_o
	);


/////////////////IF STAGE///////////////////
wire [31:0] PC_IF_o;
wire [31:0] NEXT_PC_IF_o;
wire [31:0] Instr_IF_o;


/////////////////ID STAGE///////////////////
///////General wire Ouputs///////
wire [31:0] Instr_ID_o;
//////Decoder Outputs//////////
wire CSRXXX_ID_o;
wire [31:0] CSR_Imm_ID_o;
wire Exception_ID_o;
wire [4:0] Exception_Info_ID_o;
wire [31:0] Imm_ID_o;
wire Load_ID_o;
wire JALR_Flag_ID_o;
wire WR_EN_ID_o;
wire stall_IF_vector_o_Decode;


//////GPR Outputs///////////
wire [31:0] RS1_ID_o;
wire [31:0] RS2_ID_o;

//////PC Outputs///////////
wire [31:0] PC_ID_o;
wire [31:0] Next_PC_ID_o;

//////Branching Unit Outputs///////
wire PC_Control_Signal_IF_ID_o;
wire [31:0] B_J_Target_IF_ID_o;
wire Flush_IF_ID_o;

//////Signal Outputs////////
wire [4:0] Rs1_Addr_ID_o;
wire [4:0] Rs2_Addr_ID_o;
wire [4:0] Rs1_Addr_ID_Frwrd_o;
wire [4:0] Rs2_Addr_ID_Frwrd_o;
wire [4:0] RD_Addr_ID_o;
wire [6:0] opcode_ID_o;


/////////////////EX STAGE///////////////////
///////General wire Ouputs///////
wire [31:0] Next_PC_EX_o; ///FOR JUMP//
wire [31:0] Rs1_EX_o; ///FOR CSR///
wire [31:0] Rs2_EX_o; ///FOR LOAD//
wire [4:0] Rd_Addr_EX_o; ///For WB///
wire [31:0] EX_OUT_EX_o; //EX OUT//
wire [31:0] Instr_EX_o;
wire [31:0]PC_EX_o;
wire WR_EN_EX_o;
wire JALR_Flag_EX_o;
wire [31:0] JALR_TRGT_EX_o;
///////Hazards and Forwarding/////
wire  STALL_PC_EX_o,STALL_IF_EX_o,STALL_ID_EX_o,FLUSH_ID_EX_o;
wire is_load_EX_o;
///////Exceptions and CSR/////
wire [4:0] Exception_Info_EX_o; //not sure about the size
wire Exception_EX_o, CSRXXX_EX_o;
wire [31:0] CSR_Imm_EX_o;
//////ALU FLAGS///////
wire Less_Than_Flag_EX_o, Greater_Equal_Flag_EX_o, Zero_Flag_EX_o;
wire Frwrd_Sel5_EX_o,Frwrd_Sel6_EX_o;



/////////////////WB STAGE////////////////////////

 	wire [31:0] EX_OUT_WB_o;
 	wire [31:0] Rd_WB_o;
 	wire [4:0] Rd_Addr_WB_o;
 	wire [31:0] CSR_JMP_WB_o;
 	wire CSR_PC_SRC_WB_o;
 	wire WR_EN_WB_o;
 	wire FRWRD_EN_o;
 	wire is_load_WB_o;



IF_STAGE IF(
	.clk               (clk),
	.reset             (reset),
	.CSR_JMP_IF_i       (CSR_JMP_WB_o),
	.CSR_PC_SRC_IF_i    (CSR_PC_SRC_WB_o),
	.BRNCH_JMP_TRGT_IF_i(B_J_Target_IF_ID_o),
	.BRANCH_PC_SRC_IF_i (PC_Control_Signal_IF_ID_o),
	.JALR_TRGT_IF_i     (JALR_TRGT_EX_o),
	.JALR_PC_SRC_IF_i   (JALR_Flag_EX_o),
	.STALL_IF_IF_i      (STALL_IF_EX_o),
	.FLUSH_IF_ID_i      (Flush_IF_ID_o),
	.FLUSH_IF_EX_i      (JALR_Flag_EX_o),
	.stall_IF_vector_i  (stall_IF_vector_o_Decode),

	.PC_IF_o            (PC_IF_o),
	.Instr_IF_o         (Instr_IF_o),
	.NEXT_PC_IF_o       (NEXT_PC_IF_o)
	);



ID_STAGE ID(
	.reset                    (reset),
	.clk                      (clk),
	.req_rs_vector_i          (req_rs_vector_i),
	.Instr_ID_i               (Instr_IF_o),
	.PC_ID_i                  (PC_IF_o),
	.Next_PC_ID_i             (NEXT_PC_IF_o),
	.Rd_ID_i                  (Rd_WB_o),
	.WR_EN_ID_i               (WR_EN_WB_o),
	.Rd_Addr_ID_i             (Rd_Addr_WB_o),
	.FLUSH_ID_ID_i            (FLUSH_ID_EX_o),
	.STALL_ID_ID_i            (STALL_ID_EX_o),
	.Zero_Flag_ID_i           (Zero_Flag_EX_o),
	.Greater_Equal_Flag_ID_i  (Greater_Equal_Flag_EX_o),
	.Frwrd_Sel5_ID_i          (Frwrd_Sel5_EX_o),
	.Frwrd_Sel6_ID_i          (Frwrd_Sel6_EX_o),
	.FLUSH_ID_EX_i            (JALR_Flag_EX_o),
	.PC_ID_o                  (PC_ID_o),
	.RS1_ID_o                 (RS1_ID_o),
	.RS2_ID_o                 (RS2_ID_o),
	.Load_ID_o                (Load_ID_o),
	.Instr_ID_o               (Instr_ID_o),
	.WR_EN_ID_o               (WR_EN_ID_o),
	.CSRXXX_ID_o              (CSRXXX_ID_o),
	.CSR_Imm_ID_o             (CSR_Imm_ID_o),
	.Next_PC_ID_o             (Next_PC_ID_o),
	.RD_Addr_ID_o             (RD_Addr_ID_o),
	.Exception_ID_o           (Exception_ID_o),
	.JALR_Flag_ID_o           (JALR_Flag_ID_o),
	.B_J_Target_IF_ID_o       (B_J_Target_IF_ID_o),
	.Exception_Info_ID_o      (Exception_Info_ID_o),
	.PC_Control_Signal_IF_ID_o(PC_Control_Signal_IF_ID_o),
	.Rs1_Addr_ID_o            (Rs1_Addr_ID_o),
	.Rs2_Addr_ID_o            (Rs2_Addr_ID_o),
	.Imm_ID_o                 (Imm_ID_o),
	.Rs1_Addr_ID_Frwrd_o      (Rs1_Addr_ID_Frwrd_o),
	.Rs2_Addr_ID_Frwrd_o      (Rs2_Addr_ID_Frwrd_o),
	.Flush_IF                 (Flush_IF_ID_o),
	.opcode_ID_o              (opcode_ID_o),
	.valid_rs_vector_o        (valid_rs_vector_o),
	.Rs1_ID_o_final_vector    (Rs1_ID_o_final_vector),
	.Rs2_ID_o_final_vector    (Rs2_ID_o_final_vector),
	.stall_IF_vector_o        (stall_IF_vector_o_Decode),

	.vector_valid             (instruction_vector_valid_o),
	.Instruction_vector_o     (instruction_vector_o)
	);



EX_STAGE EX (
	.clk                    (clk),
	.rst                    (reset),
	.PC_EX_i                (PC_ID_o),
	.Next_PC_EX_i           (Next_PC_ID_o),
	.is_load_EX_i           (Load_ID_o),
	.WR_EN_EX_i             (WR_EN_ID_o),
	.CSRXXX_EX_i            (CSRXXX_ID_o),
	.Exception_EX_i         (Exception_ID_o),
	.Exception_Info_EX_i    (Exception_Info_ID_o),
	.Rs1_Addr_D_i           (Rs1_Addr_ID_Frwrd_o),
	.Rs2_Addr_D_i           (Rs2_Addr_ID_Frwrd_o),
	.Rs1_Addr_EX_i          (Rs1_Addr_ID_o),
	.Rs2_Addr_EX_i          (Rs2_Addr_ID_o),
	.Imm_EX_i               (Imm_ID_o),
	.Rs1_EX_i               (RS1_ID_o),
	.Rs2_EX_i               (RS2_ID_o),
	.Instr_EX_i             (Instr_ID_o),
	.CSR_Imm_EX_i           (CSR_Imm_ID_o),
	.JALR_Flag_EX_i         (JALR_Flag_ID_o),
	.Rd_Addr_M_i            (Rd_Addr_WB_o),
	.EX_OUT_M_i             (EX_OUT_WB_o),
	.Rd_Addr_EX_i           (RD_Addr_ID_o),
	.is_load_WB_EX_i        (is_load_WB_o),
	.WR_EN_WB_EX_i          (WR_EN_WB_o),
	.opcode_ID_EX_i         (opcode_ID_o),

	.PC_EX_o                (PC_EX_o),
	.FLUSH_ID_EX_o          (FLUSH_ID_EX_o),
	.STALL_ID_EX_o          (STALL_ID_EX_o),
	.STALL_IF_EX_o          (STALL_IF_EX_o),
	.STALL_PC_EX_o          (STALL_PC_EX_o),
	.Zero_Flag_EX_o         (Zero_Flag_EX_o),
	.Less_Than_Flag_EX_o    (Less_Than_Flag_EX_o),
	.Greater_Equal_Flag_EX_o(Greater_Equal_Flag_EX_o),
	.Rs1_EX_o               (Rs1_EX_o),
	.Rs2_EX_o               (Rs2_EX_o),
	.Instr_EX_o             (Instr_EX_o),
	.WR_EN_EX_o             (WR_EN_EX_o),
	.CSRXXX_EX_o            (CSRXXX_EX_o),
	.Rd_Addr_EX_o           (Rd_Addr_EX_o),
	.Exception_EX_o         (Exception_EX_o),
	.Exception_Info_EX_o    (Exception_Info_EX_o),
	.EX_OUT_EX_o            (EX_OUT_EX_o),
	.Next_PC_EX_o           (Next_PC_EX_o),
	.CSR_Imm_EX_o           (CSR_Imm_EX_o),
	.JALR_Flag_EX_o         (JALR_Flag_EX_o),
	.Frwrd_Sel5_EX_o        (Frwrd_Sel5_EX_o),
	.Frwrd_Sel6_EX_o        (Frwrd_Sel6_EX_o),
	.is_load_EX_o           (is_load_EX_o),
	.FRWRD_EN               (FRWRD_EN_o),
	.JALR_TRGT_EX_o         (JALR_TRGT_EX_o)
	);

	WB_STAGE WB (
		.clk                (clk),
		.reset              (reset),
		.m_software_interrupt_WB_i(m_software_interrupt_WB_i),
		.m_timer_interrupt_WB_i   (m_timer_interrupt_WB_i),
		.m_external_interrupt_WB_i(m_external_interrupt_WB_i),
		.Instr_WB_i         (Instr_EX_o),
		.Rs1_WB_i           (Rs1_EX_o),
		.RS2_WB_i           (Rs2_EX_o),
		.Rd_Addr_WB_i       (Rd_Addr_EX_o),
		.EX_OUT_WB_i        (EX_OUT_EX_o),
		.PC_WB_i            (PC_EX_o),
		.NEXT_PC_WB_i       (Next_PC_EX_o),
		.WR_EN_WB_i         (WR_EN_EX_o),
		.Exception_WB_i     (Exception_EX_o),
		.CSRXXX_WB_i        (CSRXXX_EX_o),
		.Exception_Info_WB_i(Exception_Info_EX_o),
		.is_load_WB_i       (is_load_EX_o),
		.WR_EN_WB_o         (WR_EN_WB_o),
		.Rd_WB_o            (Rd_WB_o),
		.EX_OUT_WB_o        (EX_OUT_WB_o),
		.CSR_JMP_WB_o       (CSR_JMP_WB_o),
		.Rd_Addr_WB_o       (Rd_Addr_WB_o),
		.CSR_PC_SRC_WB_o    (CSR_PC_SRC_WB_o),
		.FRWRD_EN_o         (FRWRD_EN_o),
		.is_load_WB_o       (is_load_WB_o)
		);


endmodule