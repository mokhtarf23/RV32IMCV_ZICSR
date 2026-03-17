module LSU(
			input clk,reset,
			input [6:0] opcode, // opcode
			input [2:0] funct3, //funct3
			input [31:0] Rs2_data, // write data
			input [31:0] EX_OUT, //adress + offset
			input [31:0] read_data, // from mem
			output reg [31:0] Mem_Addr,
			output reg [31:0] MEM_OUT,
			output reg [31:0] wr_data,
			output reg exception_lsu,
			output reg [4:0] missalign_code,
			output reg WR_EN,
			output reg [1:0] load_type,
			output reg [1:0] store_type
			);
		
localparam  SB = 3'b000,	
			SH = 3'b001,
			SW = 3'b010;

localparam  LB = 3'b000,
			LH = 3'b001,
			LW = 3'b010,
			LBU = 3'b100,
			LHU = 3'b101;

localparam STORE = 7'b0100011,
		   LOAD = 7'b0000011,
		   CSR = 7'b1110011;

localparam  lb = 2'b00,
			lh = 2'b01,
			lw = 2'b10;


reg [31:0] MEM_OUT_CSR;
reg [31:0] MEM_OUT1;
always @(*) begin
	wr_data = Rs2_data;
	missalign_code = 0;
	Mem_Addr = EX_OUT;
	MEM_OUT = 0;
	load_type = 0;
	store_type = 0;
		case (opcode)  			// LOAD
	LOAD : begin
				WR_EN = 0;
				store_type = 0;
			case (funct3)
				LB: begin
					load_type = lb;
					MEM_OUT1 = { {24 {read_data[7]} } ,read_data[7:0]};
				end
				LBU: begin
					load_type = lb;
					MEM_OUT1 = { 24'b0 ,read_data[7:0]};
				end
				LH: begin
					load_type = lh;
					MEM_OUT1 = { {16 {read_data[15]} } ,read_data[15:0]};
				end
				LHU: begin
					load_type = lh;
					MEM_OUT1 = { 16'b0 ,read_data[15:0]};
				end
				LW: begin
					MEM_OUT1 = read_data;
					load_type = lw;
				end
				default: begin
					load_type = lw;
					MEM_OUT1 = read_data;
				end
			endcase
		end

	STORE: begin
					WR_EN = 1; 				// STORE
					case (funct3)
					SB: store_type = lb;
					SH: store_type = lh;
					SW: store_type = lw;
					default: store_type = lb;
					endcase
				end

	default: begin
				WR_EN = 0;
			end
	endcase
end		



always @(posedge clk or posedge reset) begin
	if (reset) begin
		MEM_OUT_CSR<=0;
	end else begin
		MEM_OUT_CSR<=MEM_OUT1; //ONE CYCLE AFTER;
	end
end

always @(*) begin
	if (opcode==CSR) begin
		MEM_OUT = MEM_OUT_CSR;
	end else begin
		MEM_OUT = MEM_OUT1;
	end
end

always @(*) begin
	missalign_code=5'd0;
	exception_lsu=0;
	if (opcode==LOAD) begin
		case (funct3)
			LB,LBU: begin 
				missalign_code=5'd0;
				exception_lsu=0;
			end

			LH,LHU: begin if (EX_OUT[31]) begin
				missalign_code=5'd4;
				exception_lsu=1;
				end
			end

			LW: begin if (EX_OUT[31] || EX_OUT[30]) begin
				missalign_code=5'd4;
				exception_lsu=1;
				end
			end
		endcase
    end else if (opcode==STORE) begin
    	case (funct3)
			SB: begin 
				missalign_code=5'd0;
				exception_lsu=0;
			end

			SH: begin if (EX_OUT[31]) begin
				missalign_code=5'd4;
				exception_lsu=1;
				end
			end

			SW: begin if (EX_OUT[31] || EX_OUT[30]) begin
				missalign_code=5'd4;
				exception_lsu=1;
				end
			end
		endcase
    end
	
end
endmodule