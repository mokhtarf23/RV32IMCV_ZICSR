module memory_disassembler (
    input              clk,
    input              rst,
    input              valid_i,busy_i,
    input [127:0] data_i1,
    input [127:0] data_i2,
    input      [5:0]   ID_i,
    input      [4:0]   Vd_addr_i,
    input      [2:0]   width_en_i,

    input [1:0] mop_i,
    input vm_i,
    input [6:0] opcode_i,
    input [31:0] rs1_data_i,
    input [31:0] rs2_data_i,
    input [127:0] mask_data_i,
    input vma_i,
    input [31:0] vector_length_i,

    output reg [1:0] mop_o,
    output reg vm_o,
    output reg [6:0] opcode_o,
    output reg [31:0] rs1_data_o,
    output reg [31:0] rs2_data_o,
    output reg [127:0] mask_data_o,
    output reg vma_o,
    output reg [31:0] vector_length_o,


    output reg         busy_o,
    output reg         valid_o,
    output reg [31:0]  data_o1, data_o2,
    output reg [5:0]   ID_o,
    output reg [2:0]   width_en_o,
    output reg [4:0]   Vd_addr_o
);
localparam [6:0] VLOAD   = 7'b0000111;

    reg [127:0] buffer1,buffer2;
    reg [3:0]   counter;
    reg [4:0]   max_cycles;

    // Assign cycles per SEW value
always @(*) begin
    if ((opcode_i!=VLOAD)) begin
        busy_o = busy_i;
        if (valid_i || counter>0)begin
            busy_o=1;
        end 
        case (width_en_i)
            3'b000: max_cycles = 4;   // 4 x 32-bit
            3'b101: max_cycles = 8;   // 8 x 16-bit
            3'b110: max_cycles = 16;  // 16 x 8-bit
            default: max_cycles = 4;
        endcase
    end else begin
            busy_o=busy_i;
            max_cycles = 0;
        end
    end
        

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buffer1     <= 0;
            buffer2     <= 0;
            counter    <= 0;
            valid_o    <= 0;
            data_o1     <= 0;
            data_o2     <= 0;
            ID_o       <= 0;
            Vd_addr_o  <= 0;
            width_en_o <= 0;
            mop_o<= 0;
            vm_o<= 0;
            opcode_o<= 0;
            rs1_data_o<= 0;
            rs2_data_o<= 0;
            mask_data_o<= 0;
            vma_o<= 0;
            vector_length_o<= 0;
        end else begin
        if (opcode_i!=VLOAD) begin
            valid_o <= 0;
            if (valid_i && counter == 0) begin
                buffer1  <= data_i1;
                buffer2  <= data_i2;
                ID_o      <= ID_i;
                Vd_addr_o <= Vd_addr_i;
                width_en_o <= width_en_i;
                mop_o<= mop_i;
                vm_o<= vm_i;
                opcode_o<= opcode_i;
                rs1_data_o<= rs1_data_i;
                rs2_data_o<= rs2_data_i;
                mask_data_o<= mask_data_i;
                vma_o<= vma_i;
                vector_length_o<= vector_length_i;
                counter <= 1;
            end else if (counter > 0 && counter <= max_cycles) begin
                valid_o <= 1;
                case (width_en_o)
                    3'b000: begin
                        data_o1 <= buffer1[127 -: 32];
                        data_o2 <= buffer2[127 -: 32];     
                    end     
                    3'b101: begin
                        data_o1 <= {16'b0, buffer1[127 -: 16]};
                        data_o2 <= {16'b0, buffer2[127 -: 16]};   
                    end 
                    3'b110: begin
                     data_o1 <= {24'b0, buffer1[127 -: 8]};
                      data_o2 <= {24'b0, buffer2[127 -: 8]}; 
                  end
                endcase

                case (width_en_o)
                    3'b000: begin 
                        buffer1 <= buffer1 << 32;
                         buffer2 <= buffer2 << 32;
                     end
                    3'b101: begin
                        buffer1 <= buffer1 << 16;
                        buffer2 <= buffer2 << 16;
                    end
                    3'b110: begin
                        buffer1 <= buffer1 << 8;
                        buffer2 <= buffer2 << 8;
                    end
                endcase

                counter <= counter + 1;

                if (counter == max_cycles) begin
                    counter <= 0;
                end
            end
        end
            
        end
    end

endmodule