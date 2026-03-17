module Vector_Top(
	input clk,rst,
	input valid_rs_vector_i, instruction_valid_i,
	input [31:0] Rs1_i, Rs2_i,
	input [31:0] instruction_i,
	output reg req_rs
	); 

localparam [2:0] ALU = 3'd1;
localparam [2:0] MUL = 3'd2;
localparam [2:0] DIV = 3'd3;
localparam [2:0] RED = 3'd4;
localparam [2:0] PER = 3'd5;
localparam [2:0] MMU = 3'd6;


//MAJOR OPCODES
localparam [6:0] VLOAD   = 7'b0000111;
localparam [6:0] VSTORE  = 7'b0100111;
localparam [6:0] VALU 	 = 7'b1010111;

//ALU,MUL FUNCT3
localparam [2:0] OPIVV = 000;
localparam [2:0] OPIVX = 100;
localparam [2:0] OPIVI = 011;

//RED,PERM FUNCT3
localparam [2:0] OPMVV = 010;
localparam [2:0] OPMVX = 110;


//ALU FUNCT6
localparam [5:0] VADD    = 6'b000000;
localparam [5:0] VSUB    = 6'b000010;
localparam [5:0] VRSUB   = 6'b000011;
localparam [5:0] VAND    = 6'b001001;
localparam [5:0] VOR     = 6'b001010;
localparam [5:0] VXOR    = 6'b001011;
localparam [5:0] VMINU   = 6'b000100;
localparam [5:0] VMIN    = 6'b000101;
localparam [5:0] VMAXU   = 6'b000110;
localparam [5:0] VMAX    = 6'b000111;
localparam [5:0] VSLL    = 6'b100101;
localparam [5:0] VSRL    = 6'b101000;
localparam [5:0] VSRA    = 6'b101001;
localparam [5:0] VSSRL   = 6'b101010;
localparam [5:0] VSSRA   = 6'b101011;

localparam [5:0] VMSEQ   = 6'b011000;
localparam [5:0] VMSNE   = 6'b011001;
localparam [5:0] VMSLTU  = 6'b011010;
localparam [5:0] VMSLT   = 6'b011011;
localparam [5:0] VMSLEU  = 6'b011100;
localparam [5:0] VMSLE   = 6'b011101;
localparam [5:0] VMSGTU  = 6'b011110;
localparam [5:0] VMSGT   = 6'b011111;

localparam [5:0] VMAND   = 6'b011001;
localparam [5:0] VMANDN  = 6'b011000;
localparam [5:0] VMOR    = 6'b011010;
localparam [5:0] VMORN   = 6'b011010;
localparam [5:0] VMNOR   = 6'b011100;
localparam [5:0] VMXOR   = 6'b011011;
localparam [5:0] VMXNOR  = 6'b011111;
localparam [5:0] VMNAND  = 6'b011101;

//DIV FUNCT6
localparam [5:0] VDIVU   = 6'b100000;
localparam [5:0] VDIV    = 6'b100001;
localparam [5:0] VREMU   = 6'b100010;
localparam [5:0] VREM    = 6'b100011;

//MUL FUNCT6
localparam [5:0] VMULHU  = 6'b100100;
localparam [5:0] VMUL    = 6'b1000101;
localparam [5:0] VMULHSU = 6'b1000110;
localparam [5:0] VMULH  = 6'b1000111;

//Perm
localparam [5:0] VSLIDEUP  = 6'b001110;
localparam [5:0] VSLIDEDOWN = 6'b0001111;
localparam [5:0] VCOMPRESS = 6'b010111;

localparam E32 = 3'b010,
           E16 = 3'b001, 
           E8 = 3'b000;

localparam M12 = 3'b111,
           M14 = 3'b110, 
           M18 = 3'b101,
			  M1 = 3'b000,
           M2 = 3'b001, 
           M4 = 3'b010,
           M8 = 3'b011;
//	reg clk;
//	reg rst;
//	reg [31:0] instruction_i;
//	reg valid_i;
// Instruction Queue Output
	wire [31:0] instruction_o_instr_queue;
	wire valid_o_instr_queue;
// Decoder Output
	wire stall_o_Decode;
	wire busy_o_Decode;
	wire valid_o_Decode;
	wire cfg_instr_o_Decode;
	wire Vs_Vd_Same_o_Decode;
	wire [2:0] SEW_o_Decode;
	wire [5:0] ID_o_Decode;
	wire [4:0] Vs1_Addr_o_Decode, Vs2_Addr_o_Decode,Vd_addr_o_Decode;
	wire [31:0] Imm_o_Decode;
	wire [6:0] opcode_o_Decode;
	wire [2:0] funct3_o_Decode;
	wire [5:0] funct6_o_Decode;

	wire [31:0] Rs1_o_Decode, Rs2_o_Decode;
	wire [2:0] mem_width_o_Decode;
	wire [31:0] vector_length_o_Decode;
	wire vm_o_Decode;
	wire vma_o_Decode;
	wire [1:0] mop_o_Decode;


 // VRF Output
 	wire [127:0] Vs1_o_VRF, Vs2_o_VRF,mask_o_VRF;

// Sequencer Output
	wire [127:0] Vs1_o_Seq, Vs2_o_Seq,mask_o_Seq;
	wire [31:0] Imm_o_Seq;
	wire [5:0] ID_o_Seq;
	wire [2:0] SEW_o_Seq;
	wire [2:0] reservation_station_en_o_Seq;
	wire [6:0] opcode_o_Seq;
	wire [2:0] funct3_o_Seq;
	wire [5:0] funct6_o_Seq;
	wire [4:0] Vs1_Addr_o_Seq,Vs2_Addr_o_Seq,Vd_addr_o_Seq;
	wire busy_o_Seq;
	wire chaining_needed_o_Seq;
	wire valid_o_Seq,valid1_o_Seq,valid2_o_Seq;
	wire instr_waiting_o_Seq;

	wire [31:0] Rs1_o_Seq, Rs2_o_Seq;
	wire [2:0] mem_width_o_Seq;
	wire [31:0] vector_length_o_Seq;
	wire vm_o_Seq;
	wire vma_o_Seq;
	wire [1:0] mop_o_Seq;

// Chaining Output
   wire [4:0] Vs_Addr_Used_o_Chain [1:0];
   wire [1:0] Queue_Search_En_o_Chain;// ask queue for A,B
   wire [1:0] Chaining_Ready_o_Chain;
   wire Chaining_Done_o_Chain,Chaining_almost_Done_o_Chain; //high when all required ready
   wire [127:0] Chain_Vd_o_Chain [1:0];
   wire WB_Chain_o_Chain;

// Reservation Station Output
   wire [31:0] data1_o_RS [5:0][3:0];   // 5 RS units × 4 lanes
	wire [31:0] data2_o_RS [5:0][3:0];  
	wire [5:0] ID_o_RS     [5:0];
	wire [2:0] SEW_o_RS    [5:0];
	wire [6:0] opcode_o_RS [5:0];
	wire [2:0] funct3_o_RS [5:0];
	wire [5:0] funct6_o_RS [5:0];	
	wire [4:0] Vd_Addr_o_RS[5:0];
	wire [6:0] full_o_RS   ;
	wire valid_o_RS [5:0];
	wire [5:0] done_o_RS; //hatroo7 lel chaining 3ashan te3arafo eno 5alas el chain el howa ba3etha we yeb3at el ba3do //NOT USED
	wire [127:0] mask_o_RS [5:0];
	wire [31:0] Rs1_o_RS[5:0]; 
	wire [31:0] Rs2_o_RS[5:0];
	wire [2:0] mem_width_o_RS [5:0];
	wire [31:0] vector_length_o_RS [5:0];
	wire vm_o_RS [5:0];
	wire vma_o_RS [5:0];
	wire [1:0] mop_o_RS [5:0];

// Gatherer Output
   wire [127:0] Vd_o_gatherer [5:0];
   wire [5:0] ID_o_gatherer [5:0];
   wire [4:0] Vd_Addr_o_gatherer [5:0];
   wire done_o_gatherer [5:0];
   wire [5:0] almost_done_o_gatherer ;

// Writeback Queue Output
   wire [31:0] busy_registers_o_WB; 
   wire [127:0] Vd_o_WB;
   wire [4:0] Vd_Addr_o_WB;
   wire Wr_En_o_WB;
   wire [1:0] Chain_Valid_o_WB; //NOT USED RN :/ 
   wire [127:0] Chain_Vd_o_WB [1:0]; 

/*//VALU outputs   
   wire [31:0] ALU_OUT;
   wire ALU_OUT_valid;
   wire [5:0] ID_o_ALU;
   wire [2:0] SEW_o_ALU;
   wire [4:0] Vd_Addr_o_ALU;

//Vdiv outputs
  wire DIV_OUT_valid;
  wire [31:0] DIV_OUT;
  wire [5:0] ID_o_DIV;
  wire [2:0] SEW_o_DIV;
  wire [4:0] VD_add_o_DIV;

//Vmult outputs
	wire [31:0] MULT_RESULT;
   wire MULT_OUT_valid;
   wire [5:0] ID_o_MULT;
   wire [2:0] SEW_o_MULT;
   wire [4:0] VD_add_o_MULT; */

 //Exectuion Output
 	wire [31:0] EXEC_OUT [5:0] [3:0];
   wire valid_EXEC [5:0];
   wire [5:0] ID_o_EXEC [5:0];
   wire [2:0] SEW_o_EXEC [5:0];
   wire [4:0] Vd_Addr_o_EXEC [5:0];

  //MEM OUTPUT
  	wire valid_o_Mem;
   wire[5:0] ID_o_Mem;
   wire[4:0]Vd_addr_o_Mem;
   wire[127:0] Vd_o_Mem;
   wire busy_o_Mem;
/* 
0 - ALU
1 - MULT
2 - DIV
3 - RED
4 - PERM
5 - MEM 
*/


genvar i;


instruction_queue instr_queue(
	.clk          (clk),
	.rst          (rst),
	.valid_i      (instruction_valid_i),
	.valid_o      (valid_o_instr_queue),
	.instruction_i(instruction_i),
	.busy_i       (busy_o_Decode),
	.instruction_o(instruction_o_instr_queue)
	);

VDecoder VDecode(
	.valid_i    (valid_o_instr_queue),
	.clk        (clk),
	.rst        (rst),
	.Rs1_i          (Rs1_i),
	.Rs2_i          (Rs2_i),
	.req_rs         (req_rs),
	.valid_Rs       (valid_rs_vector_i),
	.busy_i     (busy_o_Seq),
	.Busy_Register_i(busy_registers_o_WB),
	.Vd_Addr_WB_i   (Vd_Addr_o_WB),
	.Wr_En_i        (Wr_En_o_WB),
	.instruction(instruction_o_instr_queue),
	.valid_o    (valid_o_Decode),
	.SEW_o      (SEW_o_Decode),
	.funct3_o   (funct3_o_Decode),
	.funct6_o   (funct6_o_Decode),
	.opcode_o   (opcode_o_Decode),
	.Vd_addr_o  (Vd_addr_o_Decode),
	.Imm_o      (Imm_o_Decode),
	.Vs1_Addr   (Vs1_Addr_o_Decode),
	.Vs2_Addr   (Vs2_Addr_o_Decode),
	.busy_o     (busy_o_Decode),
	.cfg_instr_o(cfg_instr_o_Decode),
	.Vs_Vd_Same_o(Vs_Vd_Same_o_Decode),
	.stall_o        (stall_o_Decode),
	.ID_o       (ID_o_Decode),

	.Rs1_o                 (Rs1_o_Decode),
	.Rs2_o                 (Rs2_o_Decode),
	.mem_width_o           (mem_width_o_Decode),
	.vector_length_o       (vector_length_o_Decode),
	.vm_o                  (vm_o_Decode),
	.vma_o                 (vma_o_Decode),
	.mop_o                 (mop_o_Decode)

	);

vector_regfile VRF(
	.clk   (clk),
	.rst   (rst),
	.wen   (Wr_En_o_WB),
	.waddr (Vd_Addr_o_WB),
	.wdata (Vd_o_WB),
	.raddr0(Vs1_Addr_o_Decode),
	.raddr1(Vs2_Addr_o_Decode),
	.rdata0(Vs1_o_VRF),
	.rdata1(Vs2_o_VRF),
	.rdata2(mask_o_VRF)
	);


wire [4:0] Vs_Addr_o_Seq_packed [1:0];
assign Vs_Addr_o_Seq_packed[0]=Vs1_Addr_o_Seq;
assign Vs_Addr_o_Seq_packed[1]=Vs2_Addr_o_Seq;
Sequencer Seq(
	.clk                   (clk),
	.rst                   (rst),
	.valid_i               (valid_o_Decode),
	.stall_i               (stall_o_Decode),
	.cfg_instr_i           (cfg_instr_o_Decode),
	.SEW_i                 (SEW_o_Decode),
	.Imm_i                 (Imm_o_Decode),
	.ID_i                  (ID_o_Decode),
	.Vs1_i                 (Vs1_o_VRF),
	.Vs2_i                 (Vs2_o_VRF),
	.mask_i                (mask_o_VRF),
	.funct3_i              (funct3_o_Decode),
	.opcode_i              (opcode_o_Decode),
	.funct6_i              (funct6_o_Decode),
	.full_i                ({busy_o_Mem,full_o_RS[5:0]}),
	.RS_done_i             (done_o_RS),
	.Vd_addr_i             (Vd_addr_o_Decode),
	.Busy_Register         (busy_registers_o_WB),
	.Chaining_done         (Chaining_Done_o_Chain),
	.Chaining_almost_Done_i(Chaining_almost_Done_o_Chain),
	.WB_Chain_i            (WB_Chain_o_Chain),
	.Gatherer_almost_done  (almost_done_o_gatherer),
	.Vs1_Addr              (Vs1_Addr_o_Decode),
	.Vs2_Addr              (Vs2_Addr_o_Decode),
	.ID_o                  (ID_o_Seq),
	.valid_o               (valid_o_Seq),
	.funct3_o              (funct3_o_Seq),
	.funct6_o              (funct6_o_Seq),
	.opcode_o              (opcode_o_Seq),
	.chaining_needed       (chaining_needed_o_Seq),
	.busy                  (busy_o_Seq),
	.reservation_station_en(reservation_station_en_o_Seq),
	.Vs1_o                 (Vs1_o_Seq),
	.Vs2_o                 (Vs2_o_Seq),
	.mask_o                (mask_o_Seq),
	.Imm_o                 (Imm_o_Seq),
	.SEW_o                 (SEW_o_Seq),
	.Vs1_Addr_o            (Vs1_Addr_o_Seq),
	.Vs2_Addr_o            (Vs2_Addr_o_Seq),
	.Vd_addr_o             (Vd_addr_o_Seq),
	.valid1_o              (valid1_o_Seq),
	.valid2_o              (valid2_o_Seq),

	.Rs1_i                 (Rs1_o_Decode),
	.Rs2_i                 (Rs2_o_Decode),
	.mem_width_i           (mem_width_o_Decode),
	.vector_length_i       (vector_length_o_Decode),
	.vm_i                  (vm_o_Decode),
	.vma_i                 (vma_o_Decode),
	.mop_i                 (mop_o_Decode),

	.Rs1_o                 (Rs1_o_Seq),
	.Rs2_o                 (Rs2_o_Seq),
	.mem_width_o           (mem_width_o_Seq),
	.vector_length_o       (vector_length_o_Seq),
	.vm_o                  (vm_o_Seq),
	.vma_o                 (vma_o_Seq),
	.mop_o                 (mop_o_Seq),
	.instr_waiting_o       (instr_waiting_o_Seq)
	);



generate
for (i = 0; i < 6; i++) begin
	Reservation_Station_ALU  #(.RS(i+1))
	Res_Station (
	.clk                     (clk),
	.rst                     (rst),
	.valid_i                 (valid_o_Seq),
	.SEW_i                   (SEW_o_Seq),
	.Imm_i                   (Imm_o_Seq),
	.ID_i                    (ID_o_Seq),
	.Vs1_i                   (Vs1_o_Seq),
	.Vs2_i                   (Vs2_o_Seq),
	.mask_i                  (mask_o_Seq),
	.valid1_i                (valid1_o_Seq),
	.valid2_i                (valid2_o_Seq),
	.reservation_station_en_i(reservation_station_en_o_Seq),
	.Vd_Addr_i               (Vd_addr_o_Seq),
	.funct3_i                (funct3_o_Seq),
	.opcode_i                (opcode_o_Seq),
	.funct6_i                (funct6_o_Seq),

	.Rs1_i                 (Rs1_o_Seq),
	.Rs2_i                 (Rs2_o_Seq),
	.mem_width_i           (mem_width_o_Seq),
	.vector_length_i       (vector_length_o_Seq),
	.vm_i                  (vm_o_Seq),
	.vma_i                 (vma_o_Seq),
	.mop_i                 (mop_o_Seq),

	.Rs1_o                 (Rs1_o_RS[i]),
	.Rs2_o                 (Rs2_o_RS[i]),
	.mem_width_o           (mem_width_o_RS[i]),
	.vector_length_o       (vector_length_o_RS[i]),
	.vm_o                  (vm_o_RS[i]),
	.vma_o                 (vma_o_RS[i]),
	.mop_o                 (mop_o_RS[i]),

	.funct3_o                (funct3_o_RS[i]),
	.funct6_o                (funct6_o_RS[i]),
	.opcode_o                (opcode_o_RS[i]),
	.ID_o                    (ID_o_RS[i]),
	.SEW_o                   (SEW_o_RS[i]),
	.valid_o                 (valid_o_RS[i]),
	.full                    (full_o_RS[i+1]),
	.data1_o                 (data1_o_RS[i]),
	.data2_o                 (data2_o_RS[i]),
	.Vd_Addr_o               (Vd_Addr_o_RS[i]),
	.done                    (done_o_RS[i])
	);
end
endgenerate
assign full_o_RS[0]=0;


generate 
	for (i = 0; i < 4; i++) begin
		VALU ALU(
		.SEW_i        (SEW_o_RS[0]),
		.valid_i      (valid_o_RS[0]),
		.ID_i         (ID_o_RS[0]),
		.Vd_Addr_i    (Vd_Addr_o_RS[0]),
		.Op1          (data1_o_RS[0][i]),
		.Op2          (data2_o_RS[0][i]),
		.opcode       (funct6_o_RS[0]),

		.ID_o         (ID_o_EXEC[0]),
		.Vd_Addr_o    (Vd_Addr_o_EXEC[0]),
		.SEW_o        (SEW_o_EXEC[0]),
		.ALU_OUT      (EXEC_OUT[0][i]),
		.ALU_OUT_valid(valid_EXEC[0])
		);

		Vmult mult(
		.clk     (clk),
		.rst     (rst),
		.SEW_i        (SEW_o_RS[1]),
		.start      (valid_o_RS[1]),
		.ID_i         (ID_o_RS[1]),
		.VD_add_i    (Vd_Addr_o_RS[1]),
		.A          (data1_o_RS[1][i]),
		.B          (data2_o_RS[1][i]),
		.opcode       (funct6_o_RS[1]),

		.ID_o         (ID_o_EXEC[1]),
		.VD_add_o    (Vd_Addr_o_EXEC[1]),
		.SEW_o        (SEW_o_EXEC[1]),
		.result      (EXEC_OUT[1][i]),
		.valid_o(valid_EXEC[1])
		);

		Vdiv div(
		.clk            (clk),
		.rst            (rst),
		.SEW_i        (SEW_o_RS[2]),
		.valid_i      (valid_o_RS[2]),
		.ID_i         (ID_o_RS[2]),
		.VD_add_i    (Vd_Addr_o_RS[2]),
		.data_a_ex1_i          (data1_o_RS[2][i]),
		.data_b_ex1_i          (data2_o_RS[2][i]),
		.opcode       (funct6_o_RS[2]),

		.ID_o         (ID_o_EXEC[2]),
		.VD_add_o    (Vd_Addr_o_EXEC[2]),
		.SEW_o        (SEW_o_EXEC[2]),
		.result      (EXEC_OUT[2][i]),
		.valid_o(valid_EXEC[2])
		);

	end
endgenerate



		


generate
	for (i = 0; i < 6; i++) begin
	Gatherer Gather(
		.clk      (clk),
		.rst      (rst),
		.valid_i  (valid_EXEC[i]),
		.SEW_i    (SEW_o_EXEC[i]),
		.ID_i     (ID_o_EXEC[i]),
		.Vd_Addr_i(Vd_Addr_o_EXEC[i]),
		.data_i   ({EXEC_OUT[i][3],EXEC_OUT[i][2],EXEC_OUT[i][1],EXEC_OUT[i][0]}),

		.ID_o     (ID_o_gatherer[i]),
		.Vd_Addr_o(Vd_Addr_o_gatherer[i]),
		.Vd_o     (Vd_o_gatherer[i]),
		.done     (done_o_gatherer[i]),
		.almost_done_o(almost_done_o_gatherer[i])
		);
	end
endgenerate

TopVLSU Vmem(
			.clk          (clk),
			.rst          (rst),
			.valid_i      (valid_o_Seq&&reservation_station_en_o_Seq==6),
			.ID_i         (ID_o_Seq),
			.Vd_addr_i    (Vd_addr_o_Seq),
			.vector_length_i(vector_length_o_Seq),
			.opcode_i       (opcode_o_Seq),
			.vm_i           (vm_o_Seq),
			.mop_i          (mop_o_Seq),
			.vma_i          (vma_o_Seq),
			.rs1_data_i     (Rs1_o_Seq),
			.rs2_data_i     (Rs2_o_Seq),
			.vs2_data_i     (Vs1_o_Seq),
			.vs3_data_i     (Vs2_o_Seq),
			.width_en_i     (mem_width_o_Seq),
			.mask_data_i    (mask_o_Seq),
			.busy_o         (busy_o_Mem),
			.Vd_o         (Vd_o_Mem),
			.ID_o_b1      (ID_o_Mem),
			.valid_o_b1   (valid_o_Mem),
			.Vd_addr_o_b1 (Vd_addr_o_Mem)
			);

Writeback_Queue WB_Q (
	.clk           (clk),
	.rst           (rst),

	.ID_Valid_i    (valid_o_Decode),
	.Vd_Addr       (Vd_addr_o_Decode),
	.ID_D_i        (ID_o_Decode),
	.Vs_Vd_Same_i     (Vs_Vd_Same_o_Decode),

	.ID_i          (ID_o_gatherer[5:0]),
	.Vd_i          (Vd_o_gatherer[5:0]),

	.valid_i       (done_o_gatherer[5:0]),

	.Seq_Valid_i      (valid_o_Seq),
	.ID_Seq_i         (ID_o_Seq),


	.Vd_Addr_o     (Vd_Addr_o_WB),
	.Vd_o          (Vd_o_WB),
	.Wr_En         (Wr_En_o_WB),
	.busy_registers(busy_registers_o_WB)
	);

	//vset e8
/*	instruction_i = {1'b0,5'd0,E8,M1,5'd0,3'b111,5'd0,7'b1010111};
	valid_i = 1;
	#10
	//MULT
	instruction_i = {6'b100101,1'b0,5'd2,5'd1,3'b100,5'd3,7'b1010111}; 
	valid_i = 1;
	#10

	//DIV
	instruction_i = {6'b100001,1'b0,5'd3,5'd2,3'b100,5'd4,7'b1010111}; 
	valid_i = 1;
	#10

	//ADD
	instruction_i = {6'b000000,1'b0,5'd3,5'd4,3'b000,5'd5,7'b1010111}; 
	valid_i = 1;
	#10 */

/*initial begin
	clk=0;
	forever begin
		clk = ~clk;
		#5;
	end
end

initial begin
	//reset
	rst=1;
	instruction_i = 32'b0;
	valid_i = 0;
	#10
	rst=0;

	li x1,0;
	li x2,16;
	li x3,32;
	//vset e8
	instruction_i = {1'b0,5'd0,E8,M1,5'd0,3'b111,5'd0,7'b1010111};
	valid_i = 1;
	#10

	//LOAD
	instruction_i = {3'd0,1'd0,2'd0,1'b0,5'd0,5'd1,3'b110,5'd1,7'b0000111};
	valid_i = 1;
	#10

	//LOAD
	instruction_i = {3'd0,1'd0,2'd0,1'b0,5'd0,5'd2,3'b110,5'd2,7'b0000111};
	valid_i = 1;
	#10

	//MULT
	instruction_i = {6'b100101,1'b0,5'd1,5'd1,3'b011,5'd3,7'b1010111}; 
	valid_i = 1;
	#10

	//MULT
	instruction_i = {6'b100101,1'b0,5'd2,5'd2,3'b011,5'd4,7'b1010111}; 
	valid_i = 1;
	#10

	//ADD
	instruction_i = {6'b000000,1'b0,5'd3,5'd4,3'b000,5'd5,7'b1010111}; 
	valid_i = 1;
	#10

	//STORE
	instruction_i = {3'd0,1'd0,2'd0,1'b0,5'd0,5'd3,3'b110,5'd5,7'b0100111};
	valid_i=1;
	#10 
	valid_i=0;
	#1500*/






/*	//vset e16
//	instruction_i = {1'b0,5'd0,E32,M1,5'd0,3'b111,5'd0,7'b1010111};
//	valid_i = 1;
//	#10
	//normal alu operation elw16
	instruction_i = {6'b100101,1'b0,5'd2,5'd2,3'b000,5'd12,7'b1010111}; 
	valid_i = 1;
	#10
	instruction_i = {6'b100101,1'b0,5'd2,5'd4,3'b000,5'd13,7'b1010111}; 
	valid_i = 1;
	#10 

	instruction_i = {6'b100101,1'b0,5'd4,5'd2,3'b000,5'd14,7'b1010111}; 
	valid_i = 1;
	#10
	instruction_i = {6'b100101,1'b0,5'd3,5'd4,3'b000,5'd15,7'b1010111}; 
	valid_i = 1; 
	#10 

//	instruction_i = {1'b0,5'd0,E8,M1,5'd0,3'b111,5'd0,7'b1010111};
//	valid_i = 1;
//	#10
	//normal alu operation elw8
	instruction_i = {6'b000000,1'b0,5'd15,5'd4,3'b000,5'd16,7'b1010111}; 
	valid_i = 1;
	#10
	instruction_i = {6'b000000,1'b0,5'd4,5'd16,3'b000,5'd17,7'b1010111}; 
	valid_i = 1; 
	#10 
	instruction_i = {6'b100101,1'b0,5'd16,5'd5,3'b000,5'd18,7'b1010111}; 
	valid_i = 1;
	#10
	instruction_i = {6'b000000,1'b0,5'd5,5'd6,3'b000,5'd19,7'b1010111}; 
	valid_i = 1; 
	#10 */


//$stop;
//end 

endmodule