module Vmult (
    input  logic         clk,    
    input  logic         rst,       
    input  logic         start,
    input  logic [31:0]  A,
    input  logic [31:0]  B,
    input  logic [5:0]   opcode,
    input  logic [5:0]   ID_i,
    input  logic [2:0]   SEW_i,
    input  logic [4:0]   VD_add_i,

    output logic [31:0]  result,
    output logic         valid_o,
    output logic [5:0]   ID_o,
    output logic [2:0]   SEW_o,
    output logic [4:0]   VD_add_o
);

    logic [63:0] full_mul;
localparam VMUL    = 6'b100101;
localparam VMULHU  = 6'b100100;
localparam VMULHSU = 6'b100110;
localparam VMULH   = 6'b100111;
    always_comb begin
        // Default outputs
        result   = 32'd0;
        valid_o  = 1'b0;
        ID_o     = ID_i;
        SEW_o    = SEW_i;
        VD_add_o = VD_add_i;

        if (start) begin
            valid_o = 1'b1;
            case (opcode)
                VMUL: begin // vmul: signed * signed -> lower 32 bits
                    full_mul = $signed(A) * $signed(B);
                    result = full_mul[31:0];
                end
                VMULH: begin // vmulh: signed * signed -> upper 32 bits
                    full_mul = $signed(A) * $signed(B);
                    result = full_mul[63:32];
                end
                VMULHSU: begin // vmulhsu: signed * unsigned -> upper 32 bits
                    full_mul = $signed(A) * B;
                    result = full_mul[63:32];
                end
                VMULHU: begin // vmulhu: unsigned * unsigned -> upper 32 bits
                    full_mul = A * B;
                    result = full_mul[63:32];
                end
                default: begin
                    result  = 32'd0;
                    valid_o = 1'b0;
                end
            endcase
        end
    end

endmodule
