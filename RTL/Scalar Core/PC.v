module PC (
    input wire clk,                
    input wire reset,              
    input wire stall_PC,           
    input wire [31:0] next_addr, 
    output reg [31:0] current_addr
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_addr <= 32'b0; 
        end else if (!stall_PC) begin
            current_addr <= next_addr; // Update
        end else begin
            current_addr <= current_addr; // Hold the current address if stall_PC is asserted
        end
    end

endmodule
