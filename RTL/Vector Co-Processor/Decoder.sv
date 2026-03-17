module  VDecoder(
	input clk,rst,
	input valid_i,busy_i,
	input [31:0] Busy_Register_i,
	input [31:0] instruction,
	input [31:0] Rs1_i, Rs2_i,
	input valid_Rs,
	input [4:0] Vd_Addr_WB_i,
	input Wr_En_i,

	output reg busy_o,
	output reg valid_o,
	output reg [5:0] ID_o,

	output reg [2:0] SEW_o,
	
	output reg [4:0] Vs1_Addr, Vs2_Addr,Vd_addr_o,
	output reg [31:0] Imm_o,
	output reg [6:0] opcode_o,
	output reg [2:0] funct3_o,
	output reg [5:0] funct6_o,
	output reg [31:0] Rs1_o, Rs2_o,
	

	output reg [2:0] mem_width_o,
	output reg [31:0] vector_length_o,
	output reg vm_o,
	output reg vma_o,
	output reg [1:0] mop_o,


	output reg cfg_instr_o,
	output reg Vs_Vd_Same_o,
	output reg stall_o,
	output reg req_rs
);

localparam [6:0] VLOAD   = 7'b0000111;
localparam [6:0] VSTORE  = 7'b0100111;
localparam [6:0] VALU 	 = 7'b1010111;

reg cnfg_instr_rs_reg;
reg [31:0] Busy_Registers;
wire stall_cond;
wire cnfg_instr, cnfg_instr_rs, cnfg_instr_uimm;
reg [4:0] Vs1_Addr_reg, Vs2_Addr_reg,Vd_addr_reg;

assign stall_cond = (Busy_Register_i[instruction[19:15]] || Busy_Register_i[instruction[24:20]] || 
					instruction[24:20]==Vd_addr_o || instruction[19:15]==Vd_addr_o || instruction[19:15]==Vd_addr_reg ||
					instruction[24:20]==Vd_addr_reg) && (instruction[11:7]!=0) && !cnfg_instr;

assign cnfg_instr = instruction[6:0]==7'b1010111 && instruction[14:12] == 3'b111;
assign cnfg_instr_rs = (cnfg_instr && instruction[30:25]==6'd0 && instruction[31]==1) || (cnfg_instr && instruction[31]==0);
assign cnfg_instr_uimm = cnfg_instr && !cnfg_instr_rs;
reg [2:0] LMUL;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		ID_o<=0;
		SEW_o<=3'b010; //default 32bits
		LMUL <= 3'b000;
		Rs1_o<=0;
		Rs2_o<=0;
		Imm_o<=0;

		opcode_o<=0;
		funct3_o<=0;
		funct6_o<=0;

		Vs1_Addr<=0;
		Vs2_Addr<=0;
		Vd_addr_o<=0;

		vm_o<=0;
		mop_o<=0;
		vma_o<=0;

		valid_o <= 0;
		cfg_instr_o <= 0;
		Vs_Vd_Same_o <= 0;
		Busy_Registers <=0;
		vector_length_o <=0;
		mem_width_o<=0;
		stall_o <= 0;
		cnfg_instr_rs_reg<=0;
	end else begin
		Vs_Vd_Same_o <= 0;
		ID_o<=(!busy_i && valid_i)? ID_o+1:ID_o;
		cnfg_instr_rs_reg<=cnfg_instr_rs;

		if (!cnfg_instr) begin
			if (instruction[24:20]==instruction[11:7] || instruction[19:15]==instruction[11:7]) begin
				Busy_Registers[instruction[11:7]] <= Busy_Registers[instruction[11:7]];
			end else begin
				Busy_Registers[instruction[11:7]] <= 1;
			end
		end

		if (Wr_En_i) begin
			Busy_Registers[Vd_Addr_WB_i] <= 0;
		end

		if (cnfg_instr_rs_reg && valid_Rs) begin
			vector_length_o <= Rs1_i;
		end else if (cnfg_instr_uimm) begin
			vector_length_o <= {27'd0,instruction[19:15]};
		end 



		
		if (valid_i && !cnfg_instr && !busy_o) begin
			Rs1_o<=Rs1_i;
			Rs2_o<=Rs2_i;
			Imm_o<={27'd0,instruction[19:15]};

			opcode_o<=instruction[6:0];
			funct3_o<=instruction[14:12];
			funct6_o<=instruction[31:26];

			Vs1_Addr<=instruction[19:15];
			Vs2_Addr<=instruction[24:20];
			Vd_addr_o<=instruction[11:7];


			vm_o<=instruction[25];
			mop_o<=instruction[27:26];
			mem_width_o <= instruction[14:12];

			Vs_Vd_Same_o <= instruction[19:15]==instruction[11:7] || instruction[24:20]==instruction[11:7];

			cfg_instr_o <= 0;
			valid_o <= busy_i? 0:1;
		end else begin
			valid_o <= 0;
		end 

		if (cnfg_instr) begin //vconfig
			valid_o <= 0;
			cfg_instr_o <= 1;
			if (instruction[31:25]=={1'd0,6'd0}) begin //vsetvli
				SEW_o<=instruction[25:23];
				LMUL <= instruction[22:20];
				vma_o <= instruction[27];
			end else begin 
				if (valid_Rs) begin
					SEW_o<=Rs2_i[25:23];
					LMUL <=Rs2_i[22:20];
					vma_o <=Rs2_i[7];
				end
			end
		end
	end
end

always @(*) begin
	if (stall_o && Wr_En_i && Vd_Addr_WB_i==Vd_addr_o) begin
		stall_o=0;
	end else if ((Busy_Registers[instruction[19:15]] || Busy_Registers[instruction[24:20]] )&& !cnfg_instr &&!(instruction[6:0]==VALU && instruction[14:12]==3'b100)) begin
		stall_o=1;
	end else begin
		stall_o=0;
	end
	busy_o = stall_o? 1:busy_i;

	if (stall_o || busy_i || (cnfg_instr_rs&&!valid_Rs)) begin
		busy_o = 1;
	end else begin
		busy_o = 0;
	end

	if (cnfg_instr_rs || instruction[6:0]==VLOAD || instruction[6:0]==VSTORE || (instruction[6:0]==VALU && instruction[14:12]==3'b100)) begin
		req_rs = 1;
	end else begin
		req_rs = 0;
	end

	
end

endmodule