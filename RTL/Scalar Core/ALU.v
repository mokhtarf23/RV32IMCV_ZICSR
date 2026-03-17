module ALU (
	  input wire signed [31:0] Op1, Op2,
	  input wire [6:0] opcode,
	  input wire [2:0] funct3,
	  input wire [6:0] funct7,
	  output reg signed [31:0] ALU_OUT,
	  output reg Less_Than_Flag, Greater_Equal_Flag, Zero_Flag
);

//Decoding Opcode and Functions

reg [31:0] Op1_unsigned;
reg [31:0] Op2_unsigned;
reg [3:0] funct;


always@(*) begin
Op1_unsigned=$unsigned(Op1);
Op2_unsigned=$unsigned(Op2);
end

localparam Rtype=7'b0110011;
localparam Itype=7'b0010011;
localparam STORE=7'b0100011;
localparam LOAD=7'b0000011;
localparam JALR=7'b1100111;
localparam BRANCH=7'b1100011;

// Cases based on funct7[5] and funct3
localparam ADD=4'b0000;
localparam SUB=4'b1000;
localparam SLL=4'b0001;
localparam SLT=4'bx010;
localparam SLTU=4'bx011;
localparam XOR=4'bx100;
localparam SRL=4'b0101;
localparam SRA=4'b1101;
localparam OR=4'bx110;
localparam AND=4'bx111;

//Control
always@(*) begin
if ((funct3==000 && opcode==Itype)||opcode==STORE||opcode==LOAD||opcode==JALR)
	funct=ADD;
else if (opcode==BRANCH) begin
	funct=SUB;
end else begin
	funct={funct7[5],funct3};
end
end


//ALU
always @(*) begin
	casex (funct)
		ADD: ALU_OUT=Op1+Op2;
		SUB: ALU_OUT=Op1-Op2;
		SLL: ALU_OUT=Op1<<(Op2_unsigned[4:0]);
		SLT: ALU_OUT=(Op1<Op2)? 1:0;
		SLTU: ALU_OUT=(Op1_unsigned<Op2_unsigned)? 1:0;
		XOR: ALU_OUT=Op1^Op2;
		SRL: ALU_OUT=Op1>>(Op2_unsigned[4:0]);
		SRA: ALU_OUT=Op1>>>(Op2_unsigned[4:0]);
		OR: ALU_OUT=Op1|Op2;
		AND: ALU_OUT=Op1&Op2;
		default : ALU_OUT=ALU_OUT;
	endcase 
		if (opcode==JALR) begin
			ALU_OUT=ALU_OUT&~32'b1;
		end else begin
			ALU_OUT=ALU_OUT;
		end
end

//FLAGS
reg is_signed;

always @(*) begin
if (opcode==BRANCH && (funct3==3'b110 || funct3==3'b111)) begin
	is_signed=0;
end else if (funct!=SLTU) begin
	is_signed=1;
end else begin
	is_signed=0;
end


if (Op1[31]^Op2[31] == 0) begin
Greater_Equal_Flag= (ALU_OUT[31] == 0);
end else begin
Greater_Equal_Flag= Op1[31] ^ (is_signed); 
end

Zero_Flag=(ALU_OUT==0)? 1:0;
Less_Than_Flag=(~Greater_Equal_Flag);
end
endmodule