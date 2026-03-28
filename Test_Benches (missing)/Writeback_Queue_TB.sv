module Writeback_Queue_TB ();

	reg clk, rst;
    //FROM DECODE
    reg [5:0] ID_D_i;
    reg ID_Valid_i;
    reg [4:0] Vd_Addr; 
    // FROM EXECUTION
    reg [5:0] ID_i     [4:0];
    reg [127:0] Vd_i     [4:0];
    reg [4:0] valid_i;
    reg [4:0] Chain_Addr_i [1:0];
    reg [1:0] Chain_Valid_i;

    wire [0:31] busy_registers;
    wire [127:0] Vd_o;
    wire [4:0] Vd_Addr_o;
    wire Wr_En;
    wire [1:0] Chain_Valid_o;
    wire [127:0] Chain_Vd0_o;    
    wire [127:0] Chain_Vd1_o; 

Writeback_Queue DUT (.*);

initial begin
	clk=1;
	forever begin
		clk=~clk;
		#5;
	end
end

integer i,k;
initial begin
	rst=1;
	ID_D_i=0;
	ID_Valid_i=0;
	Vd_Addr=0;
	for (i = 0; i < 5; i++) begin
		ID_i[i]=0;
		Vd_i[i]=0;
	end
	for (i = 0; i < 2; i++) begin
		Chain_Addr_i[i]=0;
	end
	valid_i=0;
	Chain_Valid_i=0;
	#10;
	rst=0;

	//TEST CASE 1 Check busy registers (input 5 consecutive instructions from decoder)
	for (k = 1; k < 6; k++) begin
		ID_D_i=k;
		Vd_Addr=k;
		ID_Valid_i=1;
		#10;
	end
		
	for (k = 1; k <6 ; k++) begin
		if (busy_registers[k]) begin
			$display("FAILED");
		end else begin
			$display("Success");
		end
	end

	ID_Valid_i=0; //no more instructions

	//TEST CASE 2 (enter write back queue through one unit un-consecutively)\
	valid_i=5'd1;
	ID_i[0]=3;
	Vd_i[0]=3;
	#10;
	ID_i[0]=2;
	Vd_i[0]=2;
	#10;
	ID_i[0]=1;
	Vd_i[0]=1;
	#10;
	ID_i[0]=4;
	Vd_i[0]=4;
	#10;
	ID_i[0]=5;
	Vd_i[0]=5;
	#10;
	valid_i=0;
	#30


	for (k = 1; k < 6; k++) begin
		ID_D_i=k;
		Vd_Addr=k;
		ID_Valid_i=1;
		#10;
	end
		ID_Valid_i=0; //no more instructions

	//TEST CASE 3 (enter write back queue through multiple units un-consecutively) 221

	valid_i=5'b00011;
	ID_i[0]=3;
	Vd_i[0]=3;
	ID_i[1]=4;
	Vd_i[1]=4;
	#10
	valid_i=5'b01100;
	ID_i[2]=1;
	Vd_i[2]=1;
	ID_i[3]=5;
	Vd_i[3]=5;
	#20 // try and wait for a cycle see what happens
	valid_i=5'b10000;
	ID_i[4]=2;
	Vd_i[4]=2;
	#30

$stop;
end

endmodule