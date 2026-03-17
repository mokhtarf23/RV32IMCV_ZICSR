module MUX2X1(input  [31:0] in1, input  [31:0] in2, input sel, output reg [31:0] out);
    always @(*) begin
        case(sel)
            0:out=in1;
            1:out=in2;
        endcase 
    end
endmodule