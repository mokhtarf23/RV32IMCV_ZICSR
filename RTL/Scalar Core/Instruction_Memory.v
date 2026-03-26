module instruction_memory (
    input clk,
    input  [31:0] addr,    
    output reg [31:0] instruct    
);

    reg [7:0] mem[0:1024];      


    always @(negedge clk) begin
            instruct<={mem[addr[31:0]+3] , mem[addr[31:0]+2] , mem[addr[31:0]+1] , mem[addr[31:0]]};
    end

endmodule
