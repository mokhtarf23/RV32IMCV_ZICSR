module Sequencer(
	input clk,
	input rst,
	input valid_i,
	input [6:0] full_i,
	input [5:0] RS_done_i,
	input [2:0] SEW_i,
	input [5:0] ID_i,
	input [31:0] Busy_Register,
	input [4:0] Vs1_Addr, Vs2_Addr,Vd_addr_i,
	input [127:0] Vs1_i, Vs2_i,mask_i,
	input [31:0] Rs1_i,Rs2_i,
	input [31:0] Imm_i,
	input [6:0] opcode_i,
	input [2:0] funct3_i,
	input [5:0] funct6_i,

	input [2:0] mem_width_i,
	input [31:0] vector_length_i,
	input vm_i,
	input vma_i,
	input [1:0] mop_i,

	input stall_i,
	input Chaining_done, Chaining_almost_Done_i,Gatherer_almost_done,WB_Chain_i,
	input cfg_instr_i,
 

	output reg [127:0] Vs1_o, Vs2_o,mask_o,
	output reg [31:0] Rs1_o,Rs2_o,
	output reg [31:0] Imm_o,
	output reg [5:0] ID_o,
	output reg [2:0] SEW_o,
	output reg [2:0] reservation_station_en,
	output reg [6:0] opcode_o,
	output reg [2:0] funct3_o,
	output reg [5:0] funct6_o,
	output reg [4:0] Vs1_Addr_o, Vs2_Addr_o,Vd_addr_o,

	output reg [2:0] mem_width_o,
	output reg [31:0] vector_length_o,
	output reg vm_o,
	output reg vma_o,
	output reg [1:0] mop_o,

	output reg chaining_needed,
	output reg busy,
	output reg valid_o,valid1_o,valid2_o,
	output reg instr_waiting_o
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
localparam [5:0] VMUL    = 6'b100101;
localparam [5:0] VMULHSU = 6'b1000110;
localparam [5:0] VMULH  = 6'b1000111;

//Perm
localparam [5:0] VSLIDEUP  = 6'b001110;
localparam [5:0] VSLIDEDOWN = 6'b0001111;
localparam [5:0] VCOMPRESS = 6'b010111;

localparam E32 = 3'b010,
           E16 = 3'b001, 
           E8 = 3'b000;

reg chaining_needed_q; //might remove
reg busy_reg, busy_chain;
reg stall;
reg [5:0] ID_o_reg;
reg [2:0] reservation_station_en_reg;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		Vs1_o <= 0;
		Vs2_o <= 0;
		mask_o <= 0;
		Imm_o<=0;
		SEW_o <= 0;
		ID_o <= 0;
		Vs1_Addr_o <= 0;
		Vs2_Addr_o <= 0;
		Vd_addr_o<=0;
		Rs1_o <= 0;
		Rs2_o <= 0;

		mem_width_o<=0;
		vector_length_o<=0;
		vm_o<=0;
		vma_o<=0;
		mop_o<=0;
		
		opcode_o <= 0;
		funct3_o <= 0;
		funct6_o <= 0;
		chaining_needed_q<=0;
		chaining_needed <= 0;
		valid1_o <= 0;
		valid2_o <= 0;
		busy_reg<=0;
		instr_waiting_o <= 0;
		ID_o_reg <= 0;
		busy_chain <=0;
		reservation_station_en<=0;
	end else begin
	instr_waiting_o <= valid_i;
	busy_reg <= busy;
	chaining_needed_q <= chaining_needed;
	ID_o_reg <= ID_o;
	reservation_station_en <= reservation_station_en_reg;

	
	if (valid_i || busy_reg && !busy) begin
		if (!busy) begin
			Vs1_o <= Vs1_i;
			Vs2_o <= Vs2_i;
			mask_o <= mask_i;
			Rs1_o <= Rs1_i;
			Rs2_o <= Rs2_i;
			Imm_o<=Imm_i;
			SEW_o <= SEW_i;
			ID_o <= ID_i;
			mem_width_o<= mem_width_i;
			vector_length_o<= vector_length_i;
			vm_o<= vm_i;
			vma_o<= vma_i;
			mop_o<= mop_i;
			opcode_o <= opcode_i;
			funct3_o <= funct3_i;
			funct6_o <= funct6_i;
			Vd_addr_o<=Vd_addr_i;
			Vs1_Addr_o <= Vs1_Addr;
			Vs2_Addr_o <= Vs2_Addr;
			valid_o <=1;
		end else begin
			valid_o <= 0;
		end 
	end else begin
		valid_o <= 0;
	end


end
end

always @(*) begin
	if (opcode_i==VLOAD || opcode_i==VSTORE) begin //IF OPCODE IS LOAD STORE GO TO MMU
		reservation_station_en_reg=MMU;
	end else if (opcode_i==VALU) begin //IF OPCODE IS VALU DECODE FURTHER WITH FUNCT 3 AND FUNCT 6
		case (funct3_i)

			OPIVV,OPIVX,OPIVI: begin //ALU,MUL,DIV
				case (funct6_i)
					VMUL,VMULHU,VMULHSU,VMULH: reservation_station_en_reg = MUL;
					VDIV,VDIVU,VREM,VREMU : reservation_station_en_reg = DIV;
					default : reservation_station_en_reg = ALU;
				endcase
			end

			OPMVV,OPMVX:begin //RED,PER
				if (funct6_i==6'b000111) begin //RED
					reservation_station_en_reg = RED;
				end else if(funct6_i==VSLIDEUP || funct6_i==VSLIDEDOWN || funct6_i==VCOMPRESS) begin
					reservation_station_en_reg = PER;
				end else begin
					reservation_station_en_reg=0;
				end
				
			end
			default : reservation_station_en_reg=0;
		endcase
	end else begin
		reservation_station_en_reg=0;
	end

	busy = full_i[reservation_station_en_reg];

	
	valid1_o = 1;
	valid2_o = 1;
end
endmodule

// chaining done means chaining only is done not nessecarily the instruction so if resrevation is not full i can start another instruction