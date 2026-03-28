module Sequencer_TB ();
localparam [2:0] ALU = 3'd1;
localparam [2:0] MUL = 3'd2;
localparam [2:0] DIV = 3'd3;
localparam [2:0] RED = 3'd4;
localparam [2:0] PER = 3'd5;
localparam [2:0] MMU = 3'd6;


//MAJOR OPCODES
localparam [6:0] VLOAD   = 7'b0000111;
localparam [6:0] VSTORE  = 7'b0100111;
localparam [6:0] VALU 	 = 7'b1010111;

//ALU,MUL FUNCT3
localparam [2:0] OPIVV = 000;
localparam [2:0] OPIVX = 100;
localparam [2:0] OPIVI = 011;

//RED,PERM FUNCT3
localparam [2:0] OPMVV = 010;
localparam [2:0] OPMVX = 110;


//ALU FUNCT6
localparam [5:0] VADD    = 6'b000000;
localparam [5:0] VSUB    = 6'b000010;
localparam [5:0] VRSUB   = 6'b000011;
localparam [5:0] VAND    = 6'b001001;
localparam [5:0] VOR     = 6'b001010;
localparam [5:0] VXOR    = 6'b001011;
localparam [5:0] VMINU   = 6'b000100;
localparam [5:0] VMIN    = 6'b000101;
localparam [5:0] VMAXU   = 6'b000110;
localparam [5:0] VMAX    = 6'b000111;
localparam [5:0] VSLL    = 6'b100101;
localparam [5:0] VSRL    = 6'b101000;
localparam [5:0] VSRA    = 6'b101001;
localparam [5:0] VSSRL   = 6'b101010;
localparam [5:0] VSSRA   = 6'b101011;

localparam [5:0] VMSEQ   = 6'b011000;
localparam [5:0] VMSNE   = 6'b011001;
localparam [5:0] VMSLTU  = 6'b011010;
localparam [5:0] VMSLT   = 6'b011011;
localparam [5:0] VMSLEU  = 6'b011100;
localparam [5:0] VMSLE   = 6'b011101;
localparam [5:0] VMSGTU  = 6'b011110;
localparam [5:0] VMSGT   = 6'b011111;

localparam [5:0] VMAND   = 6'b011001;
localparam [5:0] VMANDN  = 6'b011000;
localparam [5:0] VMOR    = 6'b011010;
localparam [5:0] VMORN   = 6'b011010;
localparam [5:0] VMNOR   = 6'b011100;
localparam [5:0] VMXOR   = 6'b011011;
localparam [5:0] VMXNOR  = 6'b011111;
localparam [5:0] VMNAND  = 6'b011101;

//DIV FUNCT6
localparam [5:0] VDIVU   = 6'b100000;
localparam [5:0] VDIV    = 6'b100001;
localparam [5:0] VREMU   = 6'b100010;
localparam [5:0] VREM    = 6'b100011;

//MUL FUNCT6
localparam [5:0] VMULHU  = 6'b100100;
localparam [5:0] VMUL    = 6'b1000101;
localparam [5:0] VMULHSU = 6'b1000110;
localparam [5:0] VMULH   = 6'b1000111;

//Perm
localparam [5:0] VSLIDEUP  = 6'b001110;
localparam [5:0] VSLIDEDOWN    = 6'b0001111;
localparam [5:0] VCOMPRESS = 6'b010111;

reg clk;    // Clock
reg rst;  // Asynchronous reset active low
reg valid_i;
reg [6:0] full_i;
reg [2:0] SEW_i;
reg [4:0] ID_i;
reg [0:31] Busy_Register;
reg [4:0] Vs1_Addr, Vs2_Addr;
reg [127:0] Vs1_i, Vs2_i,mask_i;
reg [31:0] Imm_i;
reg [6:0] opcode_i;
reg [2:0] funct3_i;
reg [5:0] funct6_i;

wire [127:0] Vs1_o, Vs2_o,mask_o;
wire [31:0] Imm_o;
wire [4:0] ID_o;
wire [2:0] SEW_o;
wire [2:0] reservation_station_en;
wire [6:0] opcode_o;
wire [2:0] funct3_o;
wire [5:0] funct6_o;
wire valid_o,valid1_o,valid2_o;

Sequencer DUT(.*);

initial begin
	clk=1;
	forever begin
		#50;
		clk=~clk;
	end
end

initial begin
	rst=1;
	#100
	rst=0;

////////////GENERAL TEST/////////////
	ID_i=5'b1;
	SEW_i=3'b100;
	full_i=0;
	valid_i=1;

	Vs1_i=128'd250; Vs1_Addr=5'd3;
	Vs2_i=128'd500; Vs2_Addr=5'd5;
	mask_i={128{1'b1}}; Busy_Register={32{1'b1}};

	opcode_i=VALU;
	funct3_i=OPIVV;
	funct6_i=VADD;
	#100;

////////////BUSY REGISTER/////////////
	ID_i=5'b1;
	SEW_i=3'b100;
	full_i=0;
	valid_i=1;

	Vs1_i=128'd250; Vs1_Addr=5'd3;
	Vs2_i=128'd500; Vs2_Addr=5'd5;
	mask_i={128{1'b1}}; Busy_Register={{3{1'b1}},1'b0,1'b1,1'b0,{26{1'b1}}};

	opcode_i=VALU;
	funct3_i=OPIVV;
	funct6_i=VADD;
	#100;

////////////MMU RESERVATION STATION TEST/////////////
	ID_i=5'b1;
	SEW_i=3'b100;
	full_i=0;
	valid_i=1;

	Vs1_i=128'd250; Vs1_Addr=5'd3;
	Vs2_i=128'd500; Vs2_Addr=5'd5;
	mask_i={128{1'b1}}; Busy_Register={32{1'b1}};

	opcode_i=VLOAD;
	funct3_i=OPIVV;
	funct6_i=VADD;
	#100;

////////////RED RESERVATION STATION TEST/////////////
	ID_i=5'b1;
	SEW_i=3'b100;
	full_i=0;
	valid_i=1;

	Vs1_i=128'd250; Vs1_Addr=5'd3;
	Vs2_i=128'd500; Vs2_Addr=5'd5;
	mask_i={128{1'b1}}; Busy_Register={32{1'b1}};

	opcode_i=VALU;
	funct3_i=OPMVV;
	funct6_i=VMAX;
	#100;

////////////PERM RESERVATION STATION TEST/////////////
	ID_i=5'b1;
	SEW_i=3'b100;
	full_i=0;
	valid_i=1;

	Vs1_i=128'd250; Vs1_Addr=5'd3;
	Vs2_i=128'd500; Vs2_Addr=5'd5;
	mask_i={128{1'b1}}; Busy_Register={32{1'b1}};

	opcode_i=VALU;
	funct3_i=OPMVX;
	funct6_i=VSLIDEUP;
	#100;
	$stop;


end

endmodule