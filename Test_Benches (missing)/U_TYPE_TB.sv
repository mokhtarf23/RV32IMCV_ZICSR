module U_TYPE_TB();
	reg [31:0] pc;
	reg [31:0] Imm;
	reg [6:0] opcode;
	wire [31:0] U_TYPE_OUT;

	U_TYPE inst
	(
	.opcode(opcode),
	.pc (pc),
	.Imm (Imm),
	.U_TYPE_OUT(U_TYPE_OUT)
		);

	initial begin
		pc=4;
		Imm=8;
		opcode=7'b0110111;
		#100
		opcode=7'b0010111;
		#100
		$stop;
	end
endmodule