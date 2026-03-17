module U_TYPE (
	input [31:0] pc,
	input [31:0] Imm,
	input [6:0] opcode,
	output reg [31:0] U_TYPE_OUT
);

localparam LUI=7'b0110111;
localparam AUIPC=7'b0010111;

always @(*) begin
	case(opcode)
		LUI: U_TYPE_OUT={Imm[31:12],12'h000};
		AUIPC: U_TYPE_OUT=pc+{Imm[31:12],12'h000};
		default: U_TYPE_OUT=0;
	endcase
end
endmodule 