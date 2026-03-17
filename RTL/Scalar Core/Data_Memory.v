module Data_Memory (
    input clk,
    input reset,
    input wr_en,
    input [31:0] wr_data,
    input [31:0] Mem_Addr,
    input [1:0] load_type,
    input [1:0] store_type,
    output reg [31:0] read_data
);

reg [7:0] mem[0:4096];
integer i;

reg [7:0] data_B;
reg [15:0] data_H;

localparam  lb = 2'b00,
            lh = 2'b01, 
            lw = 2'b10;

always @(posedge clk or posedge reset) begin
         if (wr_en) begin
            case(store_type)
            lw: begin
                mem[Mem_Addr] <= wr_data[7:0];
                mem[Mem_Addr + 1] <= wr_data [15:8];
                mem[Mem_Addr + 2] <= wr_data [23:16];
                mem[Mem_Addr + 3] <= wr_data [31:24];

            end

            lh: begin
                mem[Mem_Addr] <= wr_data[7:0];
                mem[Mem_Addr + 1] <= wr_data [15:8];
            end

            lb: begin
                mem[Mem_Addr] <= wr_data[7:0];
            end

            endcase
        end    
        else begin

        end
end  
    

always@(negedge clk or posedge reset) begin  
    if (reset)begin
        read_data <= 0;
    end   
    else begin
        case (load_type)
            lb: begin
                    read_data <= {24'd0,mem[Mem_Addr]};
                end
            lh: begin
                    read_data <= {16'd0,mem[Mem_Addr + 1],mem[Mem_Addr]};
                end
            lw: begin
                    read_data <= {mem[Mem_Addr+3],mem[Mem_Addr+2],mem[Mem_Addr+1],mem[Mem_Addr]};
                end
        endcase
    end
end

endmodule