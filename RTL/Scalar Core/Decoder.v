module Decoder (instruction,PC,CSRXXX,CSR_Imm,Exception,
	Exception_Info,Imm,Load,Branch_Unit_Enable,JALR_Flag,WR_EN,vector_valid,stall_IF_vector_o,valid_rs_vector_o);

localparam PC_Address = 32; 

input valid_rs_vector_o;
input stall_IF_vector_o;
input [31:0] instruction;
input [PC_Address-1:0] PC;
output reg CSRXXX;
output reg [31:0] CSR_Imm;
output reg Exception;
output reg [4:0] Exception_Info;
output reg [31:0] Imm;
output reg Load;
output reg Branch_Unit_Enable; 
output reg JALR_Flag;
output reg WR_EN;
output reg vector_valid;

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
				 Fence = 7'b0001111,
				 VLOAD = 7'b000111,
				 VSTORE = 7'b0100111,
				 VALU =7'b1010111;


wire [6:0] opcode;

assign opcode = instruction [6:0];

always@(*)begin

	Exception = 0;
	Exception_Info = 0;
	CSRXXX = 0;
	CSR_Imm = 0;
	Imm = 0;
	Load = 0;
	Branch_Unit_Enable = 0;
	JALR_Flag = 0;
	WR_EN = 0;
	vector_valid = 0;

if (PC[0]) begin //PC misalgin
	Exception = 1;
	Exception_Info = 0;
	CSRXXX = 0;
	CSR_Imm = 0;
	Imm = 0;
	Load = 0;
	Branch_Unit_Enable = 0;
	JALR_Flag = 0;
	WR_EN = 0;
end

else if (PC > 32'd1024) begin //address unavailable
	Exception = 1;
	Exception_Info = 1;
	CSRXXX = 0;
	CSR_Imm = 0;
	Imm = 0;
	Load = 0;
	Branch_Unit_Enable = 0;
	JALR_Flag = 0;
	WR_EN = 0;
end

else begin 
case (opcode)
VALU, VLOAD, VSTORE: begin
	if (stall_IF_vector_o) begin
		vector_valid = 0;
	end else begin
		vector_valid = 1;
	end
	
end
R_Type: 	begin
			CSRXXX = 0;
			CSR_Imm = 0;
			Imm = 0;
			Load = 0;
			Branch_Unit_Enable = 0;
			JALR_Flag = 0;
			WR_EN = 1;
			case(instruction[31:25])
			7'd0,7'd1: begin
						Exception = 0;
						Exception_Info = 0;
						end
			7'd32: begin
					case(instruction[14:12])
					3'b000,3'b101: begin
							Exception = 0;
							Exception_Info = 0;
							end
					default: begin
							Exception = 1;
							Exception_Info = 2;
							end
					endcase				
					end
			default:	begin
						Exception = 1;
						Exception_Info = 2;
						end
			endcase							
			end

I_Type:		begin
			CSRXXX = 0;
			CSR_Imm = 0;
			Exception = 0;
			Exception_Info = 0;
			Load = 0;
			Branch_Unit_Enable = 0;
			JALR_Flag = 0;
			WR_EN = 1;
			case(instruction[14:12])
			3'b000,3'b010,3'b011,3'b100,3'b110,3'b111: Imm = {{20{instruction[31]}},instruction[31:20]};
			3'b001: begin 
			Imm = {20'd0,instruction[31:20]};
			if(instruction[31:25]!=7'b0) begin
			 	Exception = 1;
				Exception_Info = 2;
			 end
			end
			3'b101: begin
			 Imm = {27'd0,instruction[24:20]};
			 if(instruction[31:25]!=7'b0 && instruction[31:25]!=7'b0100000) begin
			 	Exception = 1;
				Exception_Info = 2;
			 end
			end
			default: Imm = {{20{instruction[31]}},instruction[31:20]};
			endcase									
			end

Load_Type: 	begin
			case(instruction[14:12])
			3'b000,3'b001,3'b101,3'b010,3'b100: begin
				Imm = {{20{instruction[31]}},instruction[31:20]};
				CSRXXX = 0;
				CSR_Imm = 0;
				Exception = 0;
				Exception_Info = 0;
				Load = 1;
				Branch_Unit_Enable = 0;
				JALR_Flag = 0;
				WR_EN = 1;
				end
			default: begin
						Exception = 1;
						Exception_Info = 2;
						CSRXXX = 0;
						CSR_Imm = 0;
						Load = 0;
						Branch_Unit_Enable = 0;
						JALR_Flag = 0;
						WR_EN = 0;
						Imm = 0;
					end	
			endcase		
			end		

S_Type: 	begin
				case(instruction[14:12])
				3'b000,3'b001,3'b010: begin
				Imm = {{20{instruction[31]}}, instruction[31:25],instruction[11:7]};	
				CSRXXX = 0;
				CSR_Imm = 0;
				Exception = 0;
				Exception_Info = 0;
				Load = 0;
				Branch_Unit_Enable = 0;
				JALR_Flag = 0;
				WR_EN = 0;
				end
				default: begin
						Exception = 1;
						Exception_Info = 2;
						CSRXXX = 0;
						CSR_Imm = 0;
						Load = 0;
						Branch_Unit_Enable = 0;
						JALR_Flag = 0;
						WR_EN = 0;
						Imm = 0;
					end	
				endcase	
			end

B_Type:		begin
				case(instruction[14:12])
				3'b000,3'b001,3'b100,3'b101,3'b110,3'b111: begin
				Imm = {{19{instruction[31]}},instruction [31],instruction[7],instruction[30:25],instruction[11:8],1'b0}	;
				CSRXXX = 0;
				CSR_Imm = 0;
				Exception = 0;
				Exception_Info = 0;
				Load = 0;
				Branch_Unit_Enable = 1;
				JALR_Flag = 0;
				WR_EN = 0;
				end
				default: begin
						Exception = 1;
						Exception_Info = 2;
						CSRXXX = 0;
						CSR_Imm = 0;
						Load = 0;
						Branch_Unit_Enable = 0;
						JALR_Flag = 0;
						Imm = 0;
						WR_EN = 0;
					end	
				endcase	
			end			

Jal: 		begin
				Imm = {{11{instruction[31]}},instruction[31],instruction [19:12],instruction [20],instruction [30:21],1'b0};
				CSRXXX = 0;
				CSR_Imm = 0;
				Exception = 0;
				Exception_Info = 0;
				Load = 0;
				Branch_Unit_Enable = 1;
				JALR_Flag = 0;
				WR_EN = 1;
			end	

Jalr:		begin
			if (instruction[14:12]!=3'b000) begin
				Exception = 1;
				Exception_Info = 2;
				CSRXXX = 0;
				CSR_Imm = 0;
				Load = 0;
				Branch_Unit_Enable = 0;
				JALR_Flag = 0;
				WR_EN = 0;
				Imm = 0;
			end else begin
				Imm = {{20{instruction[31]}},instruction[31:20]};
				CSRXXX = 0;
				CSR_Imm = 0;
				Exception = 0;
				Exception_Info = 0;														
				Load = 0;
				Branch_Unit_Enable = 0;
				JALR_Flag = 1;
				WR_EN = 1;
			end	
		end

LUI,AUIPC: begin
				Imm = {instruction[31:12],12'b0};
				CSRXXX = 0;
				CSR_Imm = 0;
				Exception = 0;
				Exception_Info = 0;														
				Load = 0;
				JALR_Flag = 0;
				Branch_Unit_Enable = 0;
				WR_EN = 1;
			end	

ZCSR: 	begin
		case(instruction [31:7])
		25'd0:  begin  ////EBREAK OR ECALL DONT REMEMBER
				CSRXXX = 0;
				CSR_Imm = 0;
				Exception = 1;
				Exception_Info = 8;
				Load = 0;
				Branch_Unit_Enable = 0;
				JALR_Flag = 0;
				Imm = 0;
				end
		25'd8192: begin /////SAME
				CSRXXX = 0;
				CSR_Imm = 0;
				Exception = 1;
				Exception_Info = 3;
				Load = 0;
				Branch_Unit_Enable = 0;
				JALR_Flag = 0;
				Imm = 0;
				end	

		32'h3000073: begin /////mret
				CSRXXX = 0;
				CSR_Imm = 0;
				Exception = 0;
				Exception_Info = 0;
				Load = 0;
				Branch_Unit_Enable = 0;
				JALR_Flag = 0;
				Imm = 0;
				end	
		default: begin
				case(instruction [14:12])
				3'b101,3'b110,3'b111: begin
										CSR_Imm = {27'd0,instruction[19:15]};
										CSRXXX = 1;
										Exception = 0;
										Exception_Info = 0;
										Load = 0;
										Branch_Unit_Enable = 0;
										JALR_Flag = 0;
										Imm = 0;
										WR_EN = 1;
									  end
				3'b001,3'b010,3'b011:	begin
										CSR_Imm = 0;
										CSRXXX = 1;
										Exception = 0;
										Exception_Info = 0;
										Load = 0;
										Branch_Unit_Enable = 0;
										JALR_Flag = 0;
										Imm = 0;
										WR_EN = 1;
									  end
				default:				begin
										CSR_Imm = 0;
										CSRXXX = 0;
										Exception = 1;
										Exception_Info = 2;
										Load = 0;
										Branch_Unit_Enable = 0;
										JALR_Flag = 0;
										Imm = 0;
										WR_EN = 0;
									  end
				endcase					  				  				  
				end
		endcase					
		end	

Fence: begin 
	CSR_Imm = 0;
	CSRXXX = 0;
	Exception = 0;
	Exception_Info = 0;
	Load = 0;
	Branch_Unit_Enable = 0;
	JALR_Flag = 0;
	Imm = 0;
	WR_EN = 0;
	end

default: 	begin
			if (instruction==32'b0) begin
				Exception = 0;
				Exception_Info = 0;
				CSRXXX = 0;
				CSR_Imm = 0;
				Load = 0;
				Imm = 0;
				Branch_Unit_Enable = 0;
				JALR_Flag = 0;
				WR_EN = 0;
			end else begin
				Exception = 1;
				Exception_Info = 2;
				CSRXXX = 0;
				CSR_Imm = 0;
				Load = 0;
				Imm = 0;
				Branch_Unit_Enable = 0;
				JALR_Flag = 0;
				WR_EN = 0;
			end
			end
endcase
end											
end
endmodule