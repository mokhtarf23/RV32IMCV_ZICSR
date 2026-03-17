module FORWARD_HAZARD_UNIT(
	input clk,rst,WR_EN,
	input [4:0] Rs1_Addr_E, Rs2_Addr_E, Rd_Addr_E,
	input [4:0] Rs1_Addr_D, Rs2_Addr_D,
	input [4:0] Rd_Addr_M,
	input is_load,FRWRD_EN,is_load_WB,
	input mult_div_stall,
	input [6:0] opcode,opcode_ID,
	input [2:0] funct3,
	output reg Sel1, Sel2,Sel3,Sel4,Sel5,Sel6, //SELECT 1 AND 2 FOR ALU, 3 AND 4 FOR RS1 AND RS2, 5 AND 6 FOR GPR OUT
	output reg STALL_ID, STALL_IF, STALL_PC, FLUSH_ID,STALL_EX
	);

	localparam STORE=7'b0100011,
			   CSR = 7'b1110011,
			   Itype = 7'b0010011;
			   localparam [6:0] VLOAD   = 7'b0000111;
localparam [6:0] VSTORE  = 7'b0100111;
localparam [6:0] VALU 	 = 7'b1010111;
//////////MEM/ALU FORWARDING/////////
always @(*) begin
	if (Rd_Addr_M==0) begin
			Sel1=0;
			Sel2=0;
			Sel3=0;
			Sel4=0;
    end else if (Rs1_Addr_E==Rd_Addr_M && Rs2_Addr_E==Rd_Addr_M) begin
			Sel1=1;
			Sel2=1;
			Sel3=1;
			Sel4=1;
	end else if (Rs1_Addr_E==Rd_Addr_M) begin
			Sel1=1;
			Sel2=0;
			Sel3=1;
			Sel4=0;
	end else if (Rs2_Addr_E==Rd_Addr_M) begin
			Sel1=0;
			Sel2=1;
			Sel3=0;
			Sel4=1;
	end else begin
			Sel1=0;
			Sel2=0;
			Sel3=0;
			Sel4=0;
	end

	if (opcode==STORE || opcode==Itype) begin
		Sel2=0;
	end

	if (is_load) begin
		Sel2=0;
		Sel3=0;
		Sel4=0;
	end

	//if (is_load_WB) begin
	//	Sel1=0;
	//	Sel2=0;
	//	Sel3=0;
		//Sel4=0;
	//end

	if (opcode==CSR && funct3[2]) begin
		Sel1=0;
		Sel2=0;
		Sel3=0;
		Sel4=0;
	end else if (opcode==CSR && !funct3[2]) begin
		Sel1=0;
		Sel2=0;
		Sel4=0;
	end
		
end


//////////MEM/GPR FORWARDING/////////
always @(*) begin
	if (Rd_Addr_M==0 || !WR_EN) begin
			Sel5=0;
			Sel6=0;
    end else if (Rs1_Addr_D==Rd_Addr_M && Rs2_Addr_D==Rd_Addr_M) begin
			Sel5=1;
			Sel6=1;
	end else if (Rs1_Addr_D==Rd_Addr_M) begin
			Sel5=1;
			Sel6=0;
	end else if (Rs2_Addr_D==Rd_Addr_M) begin
			Sel5=0;
			Sel6=1;
	end else begin
			Sel5=0;
			Sel6=0;
	end

	if (opcode==VLOAD || opcode==VSTORE || opcode==VALU) begin
		Sel5=0;
		Sel6=0;
	end
	
end




/////////HAZARDS//////
	always @(*) begin
		if (mult_div_stall) begin
			STALL_ID=1;
			FLUSH_ID=0;
			STALL_IF=1;
			STALL_PC=1;
			STALL_EX=1;
		end else if (!is_load) begin
			STALL_ID=0;
			FLUSH_ID=0;
			STALL_IF=0;
			STALL_PC=0;
			STALL_EX=0;
		end else if((Rs1_Addr_D==Rd_Addr_E || Rs2_Addr_D==Rd_Addr_E)&&Rd_Addr_E!=0 && opcode_ID!=CSR) begin
			STALL_ID=0;
			FLUSH_ID=1;
			STALL_IF=1;
			STALL_PC=1;
			STALL_EX=0;
		end else begin
			STALL_ID=0;
			FLUSH_ID=0;
			STALL_IF=0;
			STALL_PC=0;
			STALL_EX=0;
		end
	end

endmodule