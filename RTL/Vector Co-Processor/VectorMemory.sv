module Memory4Bank (
    input clk,
    input reset,
    input [31:0] address_b1,
    input write_enable_b1,
    input valid_i_b1,
    input [5:0] ID_i_b1,
    input [4:0] Vd_addr_i_b1,
    input [31:0] write_data_b1,
    input [1:0] byte_en_b1,
    input [2:0] SEW_i,
    output reg valid_o_b1,
    output reg [5:0] ID_o_b1,
    output reg [4:0]Vd_addr_o_b1,
    output reg [31:0] read_data_b1,
    output reg memory_ready_b1,
    output reg [2:0] SEW_o
);

    // Memory arrays
    reg [7:0] memory_b1 [0:4096];

    // Synchronous write/remove logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            
            memory_ready_b1 <= 1'b1;
            valid_o_b1 <= 0;
            Vd_addr_o_b1 <= 0;
            ID_o_b1 <= 0;
        end  else begin
            valid_o_b1 <= 0;
            // Bank 1
            if (valid_i_b1) begin
                if (write_enable_b1) begin
                    memory_ready_b1 <= 1'b0;
                    case (byte_en_b1)
                        2'b00: memory_b1[address_b1][7:0]   <= write_data_b1[7:0];
                        2'b01: memory_b1[address_b1][15:0]  <= write_data_b1[15:0];
                        2'b10: memory_b1[address_b1]        <= write_data_b1;
                    endcase
                    memory_ready_b1 <= 1'b1;
                end
                else begin
                    case (byte_en_b1)
                        2'b00: begin
                            read_data_b1[7:0] <= memory_b1[address_b1];
                        end
                        2'b01: begin
                            read_data_b1 [7:0] <= memory_b1[address_b1];
                            read_data_b1 [15:8] <= memory_b1[address_b1+1];
                        end
                        2'b10: begin
                            read_data_b1 [7:0] <= memory_b1[address_b1];
                            read_data_b1 [15:8] <= memory_b1[address_b1+1];
                            read_data_b1 [23:16] <= memory_b1[address_b1+2];
                            read_data_b1 [31:24] <= memory_b1[address_b1+3];
                        end
                        default : ;
                    endcase
                    valid_o_b1 <= 1;
                    Vd_addr_o_b1 <= Vd_addr_i_b1;
                    ID_o_b1 <= ID_i_b1;
                    SEW_o <= SEW_i;
                end
            end 
        end
    end
endmodule
