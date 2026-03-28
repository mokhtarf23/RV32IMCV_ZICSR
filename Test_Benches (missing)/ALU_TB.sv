module ALU_TB();

reg signed [31:0] Op1; 
reg signed [31:0] Op2;
reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;
wire signed [31:0] ALU_OUT_EX;
wire Less_Than_Flag, Greater_Equal_Flag, Zero_Flag;

ALU U1 (
	.Op1(Op1),
	.Op2(Op2),
	.opcode(opcode),
	.funct3(funct3),
	.funct7(funct7),
	.Zero_Flag(Zero_Flag),
	.Greater_Equal_Flag(Greater_Equal_Flag),
	.Less_Than_Flag(Less_Than_Flag),
	.ALU_OUT_EX(ALU_OUT_EX)
	);

initial begin
	//ADD
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b000;
funct7=7'b0000000;
#100

	//SUB
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b000;
funct7=7'b0100000;
#100

   //SLL
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b001;
funct7=7'b0000000;
#100
	
	//SLT
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b010;
funct7=7'b0000000;
#100

	//SLTU
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b011;
funct7=7'b0000000;
#100

	//XOR
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b100;
funct7=7'b0000000;
#100

	//SRL
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b101;
funct7=7'b0000000;
#100

	//SRA
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b101;
funct7=7'b0100000;
#100

	//OR
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b110;
funct7=7'b0000000;
#100

	//AND
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0110011;
funct3=3'b111;
funct7=7'b0000000;
#100

////////////////////////////////////ITYPE/////////////////////////////


	//ADD
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0010011;
funct3=3'b000;
funct7=7'b0000000;
#100


   //SLL
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0010011;
funct3=3'b001;
funct7=7'b0000000;
#100
	
	//SLT
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0010011;
funct3=3'b010;
funct7=7'b0000000;
#100

	//SLTU
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0010011;
funct3=3'b011;
funct7=7'b0000000;
#100

	//XOR
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0010011;
funct3=3'b100;
funct7=7'b0000000;
#100

	//SRL
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0010011;
funct3=3'b101;
funct7=7'b0000000;
#100

	//SRA
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0010011;
funct3=3'b101;
funct7=7'b0100000;
#100

	//OR
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0010011;
funct3=3'b110;
funct7=7'b0000000;
#100

	//AND
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b0010011;
funct3=3'b111;
funct7=7'b0000000;
#100



/////////////////////////BRANCHING//////////////////////////



	//BEQ
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b1100011;
funct3=3'b000;
funct7=7'b0000000;
#100

	//BNE
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b1100011;
funct3=3'b001;
funct7=7'b0100000;
#100

   //BLT
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b1100011;
funct3=3'b100;
funct7=7'b0000000;
#100
	
	//BGE
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b1100011;
funct3=3'b101;
funct7=7'b0000000;
#100

	//BLTU
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b1100011;
funct3=3'b110;
funct7=7'b0000000;
#100

	//BGEU
Op1=32'b011;
Op2=32'hfffffff4;
opcode=7'b1100011;
funct3=3'b111;
funct7=7'b0000000;
#100

$stop;
end
initial begin
    $monitor("time:%0t | Op1=%d | Op2=%d | ALU_OUT_EX=%d | Less_Than_Flag=%b | Greater_Equal_Flag=%b | Zero_Flag=%b",
             $time, Op1, Op2, ALU_OUT_EX, Less_Than_Flag, Greater_Equal_Flag, Zero_Flag);
end

endmodule