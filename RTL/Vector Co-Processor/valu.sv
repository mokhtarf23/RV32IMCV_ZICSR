module VALU (
	input valid_i,
	input [31:0] Op1, Op2,
	input [5:0] opcode,
	input [5:0] ID_i,
	input [2:0] SEW_i,
	input [4:0] Vd_Addr_i,
	output reg [31:0] ALU_OUT,
	output reg ALU_OUT_valid,
	output reg [5:0] ID_o,
	output reg [2:0] SEW_o,
	output reg [4:0] Vd_Addr_o
);


reg [31:0] result;
reg result_valid;

localparam [5:0] VADD     = 6'b000000;
localparam [5:0] VSUB     = 6'b000010;
localparam [5:0] VRSUB    = 6'b000011;
localparam [5:0] VAND     = 6'b001001;
localparam [5:0] VOR      = 6'b001010;
localparam [5:0] VXOR     = 6'b001011;
localparam [5:0] VMINU    = 6'b000100;
localparam [5:0] VMIN     = 6'b000101;
localparam [5:0] VMAXU    = 6'b000110;
localparam [5:0] VMAX     = 6'b000111;
localparam [5:0] VSLL     = 6'b100101;
localparam [5:0] VSRL     = 6'b101000;
localparam [5:0] VSRA     = 6'b101001;
localparam [5:0] VSSRL    = 6'b101010;
localparam [5:0] VSSRA    = 6'b101011;

localparam [5:0] VMSEQ    = 6'b011000;
localparam [5:0] VMSNE    = 6'b011001;
localparam [5:0] VMSLTU   = 6'b011010;
localparam [5:0] VMSLT    = 6'b011011;
localparam [5:0] VMSLEU   = 6'b011100;
localparam [5:0] VMSLE    = 6'b011101;
localparam [5:0] VMSGTU   = 6'b011110;
localparam [5:0] VMSGT    = 6'b011111;

localparam [5:0] VMAND    = 6'b011001;
localparam [5:0] VMANDN   = 6'b011000;
localparam [5:0] VMOR     = 6'b011010;
localparam [5:0] VMORN    = 6'b011010;
localparam [5:0] VMNOR    = 6'b011100;
localparam [5:0] VMXOR    = 6'b011011;
localparam [5:0] VMXNOR   = 6'b011111;
localparam [5:0] VMNAND   = 6'b011101;

reg [31:0] Op1_unsigned;
reg [31:0] Op2_unsigned;

always@(*) begin
Op1_unsigned=$unsigned(Op1);
Op2_unsigned=$unsigned(Op2);
end


always @(*) begin
	case (opcode)
		VADD: begin
			result=Op1+Op2;
			result_valid=1'b1;
		end

		VSUB: begin
			result=Op1-Op2;
			result_valid=1'b1;
		end

		VRSUB: begin
			result=Op2-Op1;
			result_valid=1'b1;
		end

		VAND: begin
			result=Op1&Op2;
			result_valid=1'b1;
		end

		VOR: begin
			result=Op1|Op2;
			result_valid=1'b1;
		end

		VXOR: begin
			result=Op1^Op2;
			result_valid=1'b1;
		end

		VMINU: begin
			result=(Op1_unsigned<Op2_unsigned)? Op1:Op2;
			result_valid=1'b1;
		end

		VMIN: begin
			result=(Op1<Op2)? Op1:Op2;
			result_valid=1'b1;
		end

		VMAXU: begin
			result=(Op1_unsigned>Op2_unsigned)? Op1:Op2;
			result_valid=1'b1;
		end

		VMAX: begin
			result=(Op1>Op2)? Op1:Op2;
			result_valid=1'b1;
		end

		VSLL: begin
			result=Op2<<(Op1_unsigned[4:0]);
			result_valid=1'b1;
		end

		VSRL: begin
			result=Op2>>(Op1_unsigned[4:0]);
			result_valid=1'b1;
		end

		VSRA: begin
			result=Op2>>>(Op1_unsigned[4:0]);
			result_valid=1'b1;
		end

		VSSRL: begin
			if (Op1_unsigned[4:0]>='d32) begin
				result=0;
				result_valid=1'b1;
			end else begin
				result=Op2>>(Op1_unsigned[4:0]);
				result_valid=1'b1;
			end

		end

		VSSRA: begin
			if (Op1_unsigned[4:0]>='d32) begin
				result= (Op2<0)? -32'b1 : 0;
				result_valid=1'b1;
			end else begin
				result=Op2>>>(Op1_unsigned[4:0]);
				result_valid=1'b1;
			end
		end


///////MASK INSTRUCTIONS///////

		VMSEQ: begin
			result=(Op1===Op2)? 32'd1:0;
			result_valid=1'b1;
		end

		VMSNE: begin
			result=(Op1===Op2)? 0:32'd1;
			result_valid=1'b1;
		end

		VMSLTU: begin
			result=(Op1_unsigned<Op2_unsigned)? 32'd1:0;
			result_valid=1'b1;
		end

		VMSLT: begin
			result=(Op1<Op2)? 32'd1:0;
			result_valid=1'b1;
		end

		VMSLEU: begin
			result=(Op1_unsigned<=Op2_unsigned)? 32'd1:0;
			result_valid=1'b1;
		end

		VMSLE: begin
			result=(Op1<=Op2)? 32'd1:0;
			result_valid=1'b1;
		end

		VMSGTU: begin
			result=(Op1_unsigned>Op2_unsigned)? 32'd1:0;
			result_valid=1'b1;
		end

		VMSGT: begin
			result=(Op1>Op2)? 32'd1:0;
			result_valid=1'b1;
		end

		VMAND: begin
			result=Op1[0]&Op2[0];
			result_valid=1'b1;
		end

		VMNAND: begin
			result=~(Op1[0]&Op2[0]);
			result_valid=1'b1;
		end

		VMANDN: begin
			result=(Op1[0]&(~Op2[0]));
			result_valid=1'b1;
		end

		VMOR: begin
			result=Op1[0]|Op2[0];
			result_valid=1'b1;
		end

		VMNOR: begin
			result=~(Op1[0]|Op2[0]);
			result_valid=1'b1;
		end

		VMORN: begin
			result=(Op1[0]|(~Op2[0]));
			result_valid=1'b1;
		end

		VMXOR: begin
			result=Op1[0]^Op2[0];
			result_valid=1'b1;
		end

		VMXNOR: begin
			result=~(Op1[0]^Op2[0]);
			result_valid=1'b1;
		end

            default : begin
            	result='x;
				result_valid=1'b0;
            end
        endcase
    ALU_OUT = result;
    ID_o = ID_i;
	SEW_o = SEW_i;
	Vd_Addr_o = Vd_Addr_i;
    ALU_OUT_valid= valid_i? result_valid:0;
    end

endmodule