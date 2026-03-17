module WB_STAGE(
//GENERAL INPUTS
	input clk,reset,
	input [31:0] Instr_WB_i,
	input [31:0] Rs1_WB_i,
	input [31:0] RS2_WB_i,
	input [4:0] Rd_Addr_WB_i,
	input [31:0] EX_OUT_WB_i,
	input [31:0] PC_WB_i,
	input [31:0] NEXT_PC_WB_i,
	input WR_EN_WB_i,
	input is_load_WB_i,

	input Exception_WB_i,CSRXXX_WB_i,
	input [4:0] Exception_Info_WB_i, 

	input m_software_interrupt_WB_i,
	input m_timer_interrupt_WB_i,
	input m_external_interrupt_WB_i,

////OUTPUTS
	output reg FRWRD_EN_o,
 	output reg [31:0] EX_OUT_WB_o,
 	output reg [31:0] Rd_WB_o,
 	output reg [4:0] Rd_Addr_WB_o,
 	output reg [31:0] CSR_JMP_WB_o,
 	output reg CSR_PC_SRC_WB_o,
 	output reg WR_EN_WB_o,
 	output reg is_load_WB_o
	);


localparam CSR = 7'b1110011,
		   LOAD = 7'b0000011,
		   JAL = 7'b1101111,
		   JALR = 7'b1100111,
		   STORE = 7'b0100011;


//LSU TO DATA MEM
wire [31:0] Write_Data_LSU_o;
wire WR_EN_LSU_o;
wire [1:0] load_type_LSU_o;
wire [1:0] store_type_LSU_o;
wire [31:0] Mem_Addr_LSU_o;

//LSU TO CSR AND WB_MUX
wire exception_LSU_o;
wire [4:0] missalign_code_LSU_o;
wire [31:0] MEM_OUT_LSU_o;

//DATA MEM TO LSU
wire [31:0] Read_Data_MEM_o;


//CSR OUTPUTS
wire [31:0] CSR_JMP_WB_o_wire;
wire CSR_PC_SRC_WB_o_wire;
//CSR internal signal to WB_MUX
wire [31:0] CSR_OUT;
wire [11:0] CSR_Index;
assign CSR_Index=Instr_WB_i[31:20];

wire exception;
wire [4:0] exception_info;
assign exception = Exception_WB_i | exception_LSU_o;
assign exception_info = Exception_WB_i? Exception_Info_WB_i:
						exception_LSU_o? missalign_code_LSU_o:0;
// MUX OUT
wire [31:0] WB_MUX_OUT;


reg [1:0] wb_mux_sel;
always @(*) begin
	case (Instr_WB_i[6:0])
		CSR: wb_mux_sel=2'b00;
		LOAD: wb_mux_sel=2'b01;
		JAL, JALR: wb_mux_sel=2'b11;
		default : wb_mux_sel=2'b10;
	endcase
end

wire FRWRD_EN_o_wire;
assign FRWRD_EN_o_wire = (Instr_WB_i[6:0]!=STORE);


always @(*) begin
	EX_OUT_WB_o=EX_OUT_WB_i;
	Rd_Addr_WB_o=Rd_Addr_WB_i;
	WR_EN_WB_o=WR_EN_WB_i;

	Rd_WB_o=WB_MUX_OUT;

	CSR_JMP_WB_o=CSR_JMP_WB_o_wire;
	CSR_PC_SRC_WB_o=CSR_PC_SRC_WB_o_wire;

	FRWRD_EN_o=FRWRD_EN_o_wire;

	is_load_WB_o=is_load_WB_i;
end

/////STALLING AND FORWARDING LOGIC FOR CSR/////////
reg [6:0] old_opcode;
reg [4:0] old_rd_addr;
reg [6:0] new_opcode;
reg [31:0] Rs1_data_final; //for csr data forwarding
reg FRWRD_ON;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		old_opcode<=0;
		old_rd_addr<=0;
	end else begin
		old_opcode<=Instr_WB_i[6:0];
		old_rd_addr<=Instr_WB_i[11:7];
	end
end

always @(*) begin
	if (Instr_WB_i[6:0]==7'b1110011 && old_opcode==7'b0000011 && old_rd_addr==Instr_WB_i[19:15]) begin
		Rs1_data_final=MEM_OUT_LSU_o;
		FRWRD_ON=1;
	end else begin
		Rs1_data_final=Rs1_WB_i;
		FRWRD_ON=0;
	end
end


Data_Memory Data_Memory (
	.clk       (clk),
	.reset     (reset),
	.wr_en     (WR_EN_LSU_o),
	.wr_data   (Write_Data_LSU_o),
	.Mem_Addr  (Mem_Addr_LSU_o),
	.load_type (load_type_LSU_o),
	.store_type(store_type_LSU_o),
	.read_data (Read_Data_MEM_o)
	);

LSU LOAD_STORE_UNIT (
	.clk           (clk),
	.reset         (reset),
	.opcode        (Instr_WB_i[6:0]),
	.funct3        (Instr_WB_i[14:12]),
	.Rs2_data      (RS2_WB_i),
	.EX_OUT        (EX_OUT_WB_i),
	.read_data     (Read_Data_MEM_o),
	.wr_data       (Write_Data_LSU_o),
	.WR_EN         (WR_EN_LSU_o),
	.load_type     (load_type_LSU_o),
	.store_type    (store_type_LSU_o),
	.Mem_Addr      (Mem_Addr_LSU_o),
	.exception_lsu (exception_LSU_o),
	.missalign_code (missalign_code_LSU_o),
	.MEM_OUT       (MEM_OUT_LSU_o)
	);

ZICSR ZCSR(
	.clk                 (clk),
	.reset               (reset),
	.funct3              (Instr_WB_i[14:12]),
	.csr_enable          (CSRXXX_WB_i),
	.csr_addr            (CSR_Index),
	.rs1_data            (Rs1_data_final),
	.imm            (Instr_WB_i[19:15]),
	.pc                  (PC_WB_i),
	.exception           (exception),
	.exception_code      (exception_info),
	.m_software_interrupt(m_software_interrupt_WB_i),
	.m_timer_interrupt   (m_timer_interrupt_WB_i),
	.m_external_interrupt(m_external_interrupt_WB_i),
	.mret                (Instr_WB_i==32'h3000073),
	.csr_read_data       (CSR_OUT),
	.csr_jmp             (CSR_JMP_WB_o_wire),
	.csr_pc_src          (CSR_PC_SRC_WB_o_wire)
	);



MUX4X1 WB_MUX (
	.in1(CSR_OUT),
	.in2(MEM_OUT_LSU_o),
	.in3(EX_OUT_WB_i),
	.in4(NEXT_PC_WB_i),
	.out(WB_MUX_OUT),
	.sel(wb_mux_sel)
	);


endmodule