module MULT_DIV_TB();
reg clk,rst; //rst comes from funct 7& opcode from top module
reg signed [31:0] Op1, Op2;
reg [2:0] funct3;
wire signed [31:0] MULT_DIV_OUT;
wire mult_div_stall;

localparam MAXPOS= 32'h7FFFFFFF,
		   MAXNEG= -32'd2_147_483_648;

MULT_DIV U1(
	.rst           (rst),
	.Op1           (Op1),
	.Op2           (Op2),
	.funct3        (funct3),
	.mult_div_stall(mult_div_stall),
	.clk           (clk),
	.MULT_DIV_OUT  (MULT_DIV_OUT)
	);

initial begin
	clk=0;
	forever begin
		clk=~clk;
		#50;
	end
end
initial begin
	rst=1;
	Op1=32'd0;
	Op2=32'd0;
	#100;
	rst=0;

$display("**********************************************************************");
$display("***************************TESTCASE1:MULT***************************");
$display("**********************************************************************");
$display("TESTCASE1.1: POSITIVE POSITIVE");
	Op1=32'd5000;
	Op2=32'd1000;
	funct3=3'b000;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);



$display("TESTCASE1.2: NEGATIVE NEGATIVE");
	Op1=-32'd20;
	Op2=-32'd1000;
	funct3=3'b000;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE1.3: NEGATIVE POSITIVE");
	Op1=-32'd20;
	Op2=32'd1000;
	funct3=3'b000;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE1.4: POSITIVE NEGATIVE");
	Op1=32'd20;
	Op2=-32'd1000;
	funct3=3'b000;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE1.5: MAX POSITIVE MAX POSITIVE");
	Op1=MAXPOS;
	Op2=MAXPOS;
	funct3=3'b000;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE1.6: MAX NEGATIVE MAX NEGATIVE");
	Op1=MAXNEG;
	Op2=MAXNEG;
	funct3=3'b000;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE1.7: MAX POSITIVE MAX NEGATIVE");
	Op1=MAXPOS;
	Op2=MAXNEG;
	funct3=3'b000;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE1.8: MAX NEGATIVE MAX POSITIVE");
	Op1=MAXNEG;
	Op2=MAXPOS;
	funct3=3'b000;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);











$display("**********************************************************************");
$display("***************************TESTCASE2:MULTH***************************");
$display("**********************************************************************");
$display("TESTCASE2.1: POSITIVE POSITIVE");
	Op1=32'd20;
	Op2=32'd1000;
	funct3=3'b001;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE2.2: NEGATIVE NEGATIVE");
	Op1=-32'd20;
	Op2=-32'd1000;
	funct3=3'b001;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE2.3: NEGATIVE POSITIVE");
	Op1=-32'd20;
	Op2=32'd1000;
	funct3=3'b001;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);

$display("TESTCASE2.4: POSITIVE NEGATIVE");
	Op1=32'd20;
	Op2=-32'd1000;
	funct3=3'b001;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE2.5: MAX POSITIVE MAX POSITIVE");
	Op1=MAXPOS;
	Op2=MAXPOS;
	funct3=3'b001;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE2.6: MAX NEGATIVE MAX NEGATIVE");
	Op1=MAXNEG;
	Op2=MAXNEG;
	funct3=3'b001;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE2.7: MAX POSITIVE MAX NEGATIVE");
	Op1=MAXPOS;
	Op2=MAXNEG;
	funct3=3'b001;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE2.8: MAX NEGATIVE MAX POSITIVE");
	Op1=MAXNEG;
	Op2=MAXPOS;
	funct3=3'b001;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);















$display("**********************************************************************");
$display("***************************TESTCASE3:MULTHSU***************************");
$display("**********************************************************************");
$display("TESTCASE3.1: POSITIVE POSITIVE");
	Op1=32'd20;
	Op2=32'd1000;
	funct3=3'b010;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE3.2: NEGATIVE NEGATIVE");
	Op1=-32'd20;
	Op2=-32'd1000;
	funct3=3'b010;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE3.3: NEGATIVE POSITIVE");
	Op1=-32'd20;
	Op2=32'd1000;
	funct3=3'b010;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE3.4: POSITIVE NEGATIVE");
	Op1=32'd20;
	Op2=-32'd1000;
	funct3=3'b010;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE3.5: MAX POSITIVE MAX POSITIVE");
	Op1=MAXPOS;
	Op2=MAXPOS;
	funct3=3'b010;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE3.6: MAX NEGATIVE MAX NEGATIVE");
	Op1=MAXNEG;
	Op2=MAXNEG;
	funct3=3'b010;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE3.7: MAX POSITIVE MAX NEGATIVE");
	Op1=MAXPOS;
	Op2=MAXNEG;
	funct3=3'b010;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE3.8: MAX NEGATIVE MAX POSITIVE");
	Op1=MAXNEG;
	Op2=MAXPOS;
	funct3=3'b010;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);













$display("**********************************************************************");
$display("***************************TESTCASE4:MULTHU***************************");
$display("**********************************************************************");
$display("TESTCASE4.1: POSITIVE POSITIVE");
	Op1=32'd20;
	Op2=32'd1000;
	funct3=3'b011;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE4.2: NEGATIVE NEGATIVE");
	Op1=-32'd20;
	Op2=-32'd1000;
	funct3=3'b011;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE4.3: NEGATIVE POSITIVE");
	Op1=-32'd20;
	Op2=32'd1000;
	funct3=3'b011;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE4.4: POSITIVE NEGATIVE");
	Op1=32'd20;
	Op2=-32'd1000;
	funct3=3'b011;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE4.5: MAX POSITIVE MAX POSITIVE");
	Op1=MAXPOS;
	Op2=MAXPOS;
	funct3=3'b011;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE4.6: MAX NEGATIVE MAX NEGATIVE");
	Op1=MAXNEG;
	Op2=MAXNEG;
	funct3=3'b011;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE4.7: MAX POSITIVE MAX NEGATIVE");
	Op1=MAXPOS;
	Op2=MAXNEG;
	funct3=3'b011;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);


$display("TESTCASE4.8: MAX NEGATIVE MAX POSITIVE");
	Op1=MAXNEG;
	Op2=MAXPOS;
	funct3=3'b011;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);













$display("**********************************************************************");
$display("***************************TESTCASE5:DIVISION***************************");
$display("**********************************************************************");
$display("TESTCASE5.1: POSITIVE POSITIVE");
	Op1=32'd1000;
	Op2=32'd20;
	funct3=3'b100;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);

$display("TESTCASE5.2: NEGATIVE NEGATIVE");
	Op1=-32'd1000;
	Op2=-32'd20;
	funct3=3'b100;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);

$display("TESTCASE5.3: NEGATIVE POSITIVE");
	Op1=-32'd1000;
	Op2=32'd20;
	funct3=3'b100;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);

$display("TESTCASE5.4: POSITIVE NEGATIVE");
	Op1=32'd1000;
	Op2=-32'd20;
	funct3=3'b100;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
	$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);

$display("TESTCASE5.5: MAX POSITIVE MAX POSITIVE");
	Op1=MAXPOS;
	Op2=MAXPOS;
	funct3=3'b100;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);

$display("TESTCASE5.6: MAX NEGATIVE MAX NEGATIVE");
	Op1=MAXNEG;
	Op2=MAXNEG;
	funct3=3'b100;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);

$display("TESTCASE5.7: MAX POSITIVE MAX NEGATIVE");
	Op1=MAXPOS;
	Op2=MAXNEG;
	funct3=3'b100;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);

$display("TESTCASE5.8: MAX NEGATIVE MAX POSITIVE");
	Op1=MAXNEG;
	Op2=MAXPOS;
	funct3=3'b100;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b | rem=%d",$time,Op1,Op2, MULT_DIV_OUT, mult_div_stall, U1.remainder);












$display("**********************************************************************");
$display("***************************TESTCASE6:DIVU***************************");
$display("**********************************************************************");
$display("TESTCASE6.1: POSITIVE POSITIVE");
	Op1=32'd1000;
	Op2=32'd20;
	funct3=3'b101;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b",$time,$unsigned(Op1),$unsigned(Op2), MULT_DIV_OUT, mult_div_stall);

$display("TESTCASE6.2: NEGATIVE NEGATIVE");
	Op1=-32'd1000;
	Op2=-32'd20;
	funct3=3'b101;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b",$time,$unsigned(Op1),$unsigned(Op2), MULT_DIV_OUT, mult_div_stall);

$display("TESTCASE6.3: NEGATIVE POSITIVE");
	Op1=-32'd1000;
	Op2=32'd20;
	funct3=3'b101;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b",$time,$unsigned(Op1),$unsigned(Op2), MULT_DIV_OUT, mult_div_stall);

$display("TESTCASE6.4: POSITIVE NEGATIVE");
	Op1=32'd1000;
	Op2=-32'd20;
	funct3=3'b101;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b",$time,$unsigned(Op1),$unsigned(Op2), MULT_DIV_OUT, mult_div_stall);

$display("TESTCASE6.5: MAX POSITIVE MAX POSITIVE");
	Op1=MAXPOS;
	Op2=MAXPOS;
	funct3=3'b101;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b",$time,$unsigned(Op1),$unsigned(Op2), MULT_DIV_OUT, mult_div_stall);

$display("TESTCASE6.6: MAX NEGATIVE MAX NEGATIVE");
	Op1=MAXNEG;
	Op2=MAXNEG;
	funct3=3'b101;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b",$time,$unsigned(Op1),$unsigned(Op2), MULT_DIV_OUT, mult_div_stall);

$display("TESTCASE6.7: MAX POSITIVE MAX NEGATIVE");
	Op1=MAXPOS;
	Op2=MAXNEG;
	funct3=3'b101;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b",$time,$unsigned(Op1),$unsigned(Op2), MULT_DIV_OUT, mult_div_stall);

$display("TESTCASE6.8: MAX NEGATIVE MAX POSITIVE");
	Op1=MAXNEG;
	Op2=MAXPOS;
	funct3=3'b101;
	@(posedge mult_div_stall);
	wait(mult_div_stall==0);
$display("time:%t Op1=%d | Op2=%d | MULT_DIV_OUT=%d | mult_div_stall=%b",$time,$unsigned(Op1),$unsigned(Op2), MULT_DIV_OUT, mult_div_stall);


	$stop;
end

endmodule