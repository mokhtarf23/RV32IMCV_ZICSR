module FORWARD_HAZARD_UNIT_TB();
	reg [4:0] Rs1_Addr_E, Rs2_Addr_E, Rd_Addr_E;
	reg [4:0] Rs1_Addr_D, Rs2_Addr_D;
	reg [4:0] Rd_Addr_M;
	reg is_load, mult_div_stall;
	wire Sel1, Sel2;
	wire STALL_ID, FLUSH_ID, STALL_IF, STALL_PC;

	FORWARD_HAZARD_UNIT inst1 (
		.Rs1_Addr_E(Rs1_Addr_E),
		.Rs2_Addr_E(Rs2_Addr_E),
		.Rd_Addr_E (Rd_Addr_E),
		.Rs1_Addr_D(Rs1_Addr_D),
		.Rs2_Addr_D(Rs2_Addr_D),
		.is_load   (is_load),
		.Rd_Addr_M (Rd_Addr_M),
		.Sel1      (Sel1),
		.Sel2      (Sel2),
		.FLUSH_ID  (FLUSH_ID),
		.STALL_IF  (STALL_IF),
		.STALL_PC  (STALL_PC),
		.STALL_ID (STALL_ID),
		.mult_div_stall (mult_div_stall)
		);

	initial begin
		Rs1_Addr_E=3; Rs2_Addr_E=3;
		Rs1_Addr_D=4; Rs2_Addr_D=4;
		Rd_Addr_E=4; Rd_Addr_M=3;
		is_load=1; mult_div_stall=0; 
		#100;

		Rs1_Addr_E=3; Rs2_Addr_E=5;
		Rs1_Addr_D=4; Rs2_Addr_D=4;
		Rd_Addr_E=4; Rd_Addr_M=3;
		is_load=0; mult_div_stall=0; 
		#100;

		Rs1_Addr_E=5; Rs2_Addr_E=3;
		Rs1_Addr_D=4; Rs2_Addr_D=4;
		Rd_Addr_E=4; Rd_Addr_M=3;
		is_load=0; mult_div_stall=0; 
		#100;

		Rs1_Addr_E=3; Rs2_Addr_E=3;
		Rs1_Addr_D=2; Rs2_Addr_D=4;
		Rd_Addr_E=4; Rd_Addr_M=3;
		is_load=1; mult_div_stall=0; 
		#100;

		Rs1_Addr_E=3; Rs2_Addr_E=3;
		Rs1_Addr_D=4; Rs2_Addr_D=2;
		Rd_Addr_E=4; Rd_Addr_M=3;
		is_load=1; mult_div_stall=0; 
		#100;

		Rs1_Addr_E=3; Rs2_Addr_E=3;
		Rs1_Addr_D=2; Rs2_Addr_D=4;
		Rd_Addr_E=4; Rd_Addr_M=3;
		is_load=1; mult_div_stall=0; 
		#100;

		Rs1_Addr_E=3; Rs2_Addr_E=3;
		Rs1_Addr_D=4; Rs2_Addr_D=2;
		Rd_Addr_E=4; Rd_Addr_M=3;
		is_load=1; mult_div_stall=0; 
		#100;

		Rs1_Addr_E=3; Rs2_Addr_E=3;
		Rs1_Addr_D=2; Rs2_Addr_D=2;
		Rd_Addr_E=4; Rd_Addr_M=3;
		is_load=1; mult_div_stall=0; 
		#100;

		Rs1_Addr_E=3; Rs2_Addr_E=3;
		Rs1_Addr_D=2; Rs2_Addr_D=2;
		Rd_Addr_E=4; Rd_Addr_M=3;
		is_load=1; mult_div_stall=1; 
		#100;

		$stop;
	end

endmodule