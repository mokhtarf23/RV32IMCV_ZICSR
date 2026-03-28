module Branching_Unit_TB ();

reg clk,reset;
reg [6:0] opcode;
reg [2:0] funct3;
reg [31:0] Imm;
reg [31:0] PC,Next_PC;
reg Branch_Unit_Enable;
reg Zero_Flag;
reg Greater_Equal_Flag;
wire Flush_ID;
wire PC_Control_Signal;
wire [31:0] B_J_Target;

localparam [6:0] B_Type = 7'b1100011,
				 Jal = 7'b1101111;

localparam [2:0] beq = 3'b000,
		   		 bne = 3'b001,
		   		 blt = 3'b100,
		   		 bge = 3'b101,
		   		 bltu = 3'b110,
		   		 bgeu = 3'b111;

Branching_Unit U1 (
		.clk               (clk),
		.opcode            (opcode),
		.funct3            (funct3),
		.reset             (reset),
		.Zero_Flag         (Zero_Flag),
		.Next_PC           (Next_PC),
		.Imm               (Imm),
		.Greater_Equal_Flag(Greater_Equal_Flag),
		.PC                (PC),
		.Branch_Unit_Enable(Branch_Unit_Enable),
		.PC_Control_Signal (PC_Control_Signal),
		.B_J_Target        (B_J_Target),
		.Flush_ID          (Flush_ID)
	);

initial begin
	clk=1;
	forever begin
		#50 clk=~clk;
	end
end

initial begin
	reset=1;
	PC=4;
	Next_PC=8;
	Imm=10;
	Branch_Unit_Enable=0;
	#100;
	reset=0;

$display("BEQ VERIFIED");
	opcode=B_Type;
	funct3=beq;
	Branch_Unit_Enable=1;
	#100;
	Branch_Unit_Enable=0;
	Zero_Flag=1;
	#100;

$display("BEQ FALSE PREDICTION");
	Branch_Unit_Enable=1;
	#100;
	Branch_Unit_Enable=0;
	Zero_Flag=0;
	#100;




$display("*****************************************");
$display("BNE VERIFIED");
	funct3=bne;
	Branch_Unit_Enable=1;
	#100;
	Branch_Unit_Enable=0;
	Zero_Flag=0;
	#100;

$display("BNE FALSE PREDICTION");
	Branch_Unit_Enable=1;
	#100;
	Branch_Unit_Enable=0;
	Zero_Flag=1;
	#100;




$display("*****************************************");
$display("BLT VERIFIED");
	funct3=blt;
	Branch_Unit_Enable=1;
	#100;
	Branch_Unit_Enable=0;
	Greater_Equal_Flag=0;
	#100;

$display("BLT FALSE PREDICTION");
	Branch_Unit_Enable=1;
	#100;
	Branch_Unit_Enable=0;
	Greater_Equal_Flag=1;
	#100;




$display("*****************************************");
$display("BGE VERIFIED");
	funct3=bge;
	Branch_Unit_Enable=1;
	#100;
	Branch_Unit_Enable=0;
	Greater_Equal_Flag=1;
	#100;

$display("BGE FALSE PREDICTION");
	Branch_Unit_Enable=1;
	#100;
	Branch_Unit_Enable=0;
	Greater_Equal_Flag=0;
	#100;



$display("*****************************************");
$display("TWO BRANCHES IN A ROW FIRST IS FALSE");
///FIRST BRANCH
	funct3=bge;
	Branch_Unit_Enable=1;
	#100;
///SECOND BRANCH
	funct3=beq;
	Branch_Unit_Enable=1;
	Greater_Equal_Flag=0;
	#100;
	Branch_Unit_Enable=0;
	Zero_Flag=1;
	#100;

$display("*****************************************");
$display("TWO BRANCHES IN A ROW FIRST IS CORRECT SECOND IS FALSE");
///FIRST BRANCH
	funct3=bge;
	Branch_Unit_Enable=1;
	PC=4;
	Next_PC=8;
	#100;
///SECOND BRANCH
	funct3=beq;
	Branch_Unit_Enable=1;
	Greater_Equal_Flag=1;
	PC=14;
	Next_PC=16;
	#100;
	Branch_Unit_Enable=0;
	Zero_Flag=0;
	#100;




	$stop;
end

initial begin
	$monitor("Time:%0t Branch_Enable=%b | PC_CTRL=%b | Target=%d | Funct3=%b | Flush_ID=%b",$time,Branch_Unit_Enable,PC_Control_Signal,B_J_Target,funct3,Flush_ID);
end

endmodule