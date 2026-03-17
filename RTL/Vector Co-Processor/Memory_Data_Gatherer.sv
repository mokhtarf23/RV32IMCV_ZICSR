module memory_assembler (
    input              clk,
    input              rst,
    input              valid_i,
    input      [31:0]  data_i,
    input      [5:0]   ID_i,
    input      [4:0]   Vd_addr_i,
    input      [2:0]   SEW_i,

    output reg         valid_o,
    output reg [127:0] data_o,
    output reg [5:0]   ID_o,
    output reg [4:0]   Vd_addr_o
);

    reg [127:0] buffer;
    reg [3:0]   counter;
    reg [4:0]   max_cycles;

    // Determine required number of cycles based on SEW
    always @(*) begin
        case (SEW_i)
            3'b000: max_cycles = 4;   // 4 x 32-bit
            3'b101: max_cycles = 8;   // 8 x 16-bit
            3'b110: max_cycles = 16;  // 16 x 8-bit
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buffer      <= 0;
            counter     <= 0;
            data_o      <= 0;
            valid_o     <= 0;
            ID_o        <= 0;
            Vd_addr_o   <= 0;
        end else begin
            // Always pass through metadata
            ID_o      <= ID_i;
            Vd_addr_o <= Vd_addr_i;

            valid_o <= 0; // default

            if (valid_i) begin
                // Accumulate data into buffer
                case (SEW_i)
                    3'b000: buffer <= {buffer[95:0], data_i};          // 32-bit
                    3'b101: buffer <= {buffer[111:0], data_i[15:0]};   // 16-bit
                    3'b110: buffer <= {buffer[119:0], data_i[7:0]};    // 8-bit
                    default: buffer <= {buffer[95:0], data_i};
                endcase

                counter <= counter + 1;

                if (counter + 1 == max_cycles) begin
                    valid_o <= 1;
                    case (SEW_i)
                        3'b000: data_o <= {buffer[95:0], data_i};        // 4 x 32-bit
                        3'b101: data_o <= {buffer[111:0], data_i[15:0]}; // 8 x 16-bit
                        3'b110: data_o <= {buffer[119:0], data_i[7:0]};  // 16 x 8-bit
                        default: data_o <= {buffer[95:0], data_i};
                    endcase
                    counter <= 0;
                    buffer  <= 0;
                end
            end
        end
    end

endmodule