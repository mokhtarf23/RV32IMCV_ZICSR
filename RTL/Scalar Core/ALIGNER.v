module aligner (
    input wire [31:0] current_pc, 
    input wire compressed_instr,    
    output reg [31:0] PC_INC  
);

    always @(*) begin
        if (compressed_instr) begin
            PC_INC = current_pc + 2; // Add 2 for compressed instruction
        end else begin
            PC_INC = current_pc + 4; // Add 4 for normal instruction
        end
    end

endmodule