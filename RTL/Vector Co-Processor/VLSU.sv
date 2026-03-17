module VectorLSU (
    input clk,
    input reset,

    input [2:0] width_en,
    input [1:0] mop,
    input vm,
    input [6:0] opcode,

    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] vs2_data,
    input [31:0] vs3_data,
    input [127:0] mask_data,
    input vma,

    input memory_ready_b1,


    input [31:0] vector_length,
    input valid_i,
    input [5:0] ID_i,
    input [4:0] Vd_addr_i,

    output reg valid_o_b1,
    output reg [5:0] ID_o_b1,
    output reg [4:0]Vd_addr_o_b1,

    output reg [31:0] memory_address_b1,

    output reg memory_write_enable_b1,

    output reg [31:0] memory_data_b1,
    output reg busy,
    output reg [1:0] byte_en_b1,
    output reg [2:0] SEW,
    output reg busy_o,
    output reg error
);
localparam E32 = 3'b000,
           E16 = 3'b101, 
           E8 = 3'b110;
    
    reg [31:0] expected_final_index;


    reg [31:0] offset;
    reg [31:0] stride;
    reg [31:0] current_address;
    reg [31:0] current_index;

    typedef enum logic [2:0] {
        IDLE,
        LOAD,
        STORE
    } state_t;

    state_t current_state, next_state;
    reg was_store_op;

    always @(*) begin
        offset = rs2_data;
        stride = vs2_data;
        error = 0;
        if (valid_i) begin
            busy_o = 1;
        end else if(busy_o==1 && current_index != expected_final_index) begin
            busy_o = 1;
        end else begin
            busy_o = busy;
        end

        case (width_en)
            3'b000: SEW = E32;
            3'b101: SEW = E16;
            3'b110: SEW = E8;
            default: begin
                SEW = 0;
                error = 1;
            end
        endcase
    end

    reg [1:0] byte_en;

    always @(*) begin
        case (SEW)
            8: byte_en = 2'b00;
            16: byte_en = 2'b01;
            32: byte_en = 2'b10;
            default: byte_en = 2'b00;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            busy <= 0;
            error <= 0;
            expected_final_index <= 0;
        end else begin
            current_state <= next_state;
            case (current_state)
                IDLE: begin
                    if (valid_i) begin
                        busy <= 1;
                        expected_final_index <= vector_length;
                    end
                    memory_write_enable_b1 <= 0;
                    current_index <= 0;
                    current_address <= rs1_data;
                    valid_o_b1 <= 0;
                end

                LOAD: begin
                    busy <= 1;

                    if (vma || !vm || (vm & mask_data[current_index])) begin
                                if(memory_ready_b1) begin
                                    memory_address_b1 <= current_address;
                                    memory_write_enable_b1 <= 0;
                                    byte_en_b1 <= byte_en;
                                    current_index = current_index + 1;
                                    case (mop)
                                        2'b00: current_address <= current_address + (1 << (SEW == E8 ? 0 : SEW == E16 ? 1 : SEW == E32 ? 2 : 3));
                                        2'b01: current_address <= current_address + stride;
                                        2'b10: current_address <= current_address + vs2_data;
                                        default: ;
                                    endcase
                                    valid_o_b1 <= 1;
                                    Vd_addr_o_b1 <= Vd_addr_i;
                                    ID_o_b1 <= ID_i;
                                end
                    end else begin
                        current_index <= current_index + 1;
                    case (mop)
                        2'b00: current_address <= current_address + (1 << (SEW == E8 ? 0 : SEW == E16 ? 1 : SEW == E32 ? 2 : 3));
                        2'b01: current_address <= current_address + stride;
                        2'b10: current_address <= rs1_data + vs2_data;
                        default: ;
                    endcase
                    end
                end

                
                STORE: begin
                    busy <= 1;
                    if (vma || !vm || (vm & mask_data[current_index])) begin
                        if(memory_ready_b1) begin
                            memory_address_b1 <= current_address;
                            memory_data_b1 <= vs3_data;
                            memory_write_enable_b1 <= 1;
                            byte_en_b1 <= byte_en;
                            current_index = current_index + 1;
                                case (mop)
                                    2'b00: current_address <= current_address + (1 << (SEW == E8 ? 0 : SEW == E16 ? 1 : SEW == E32 ? 2 : 3));
                                    2'b01: current_address <= current_address + stride;
                                    2'b10: current_address <= rs1_data + vs2_data;
                                endcase
                        end
                    end else begin
                        current_index <= current_index + 1;
                    case (mop)
                        2'b00: current_address <= current_address + (1 << (SEW == E8 ? 0 : SEW == E16 ? 1 : SEW == E32 ? 2 : 3));
                        2'b01: current_address <= current_address + stride;
                        2'b10: current_address <= rs1_data + vs2_data;
                    endcase
                end
            end
        endcase
    end
end
    always @(*) begin
        case (current_state)
            IDLE: begin
                next_state = IDLE;
                if (valid_i) begin
                    if (opcode == 7'b0000111) begin
                            next_state = LOAD;
                        end
                    else if (opcode == 7'b0100111) begin
                        next_state = STORE;
                    end
                    else next_state = IDLE;

                end
            end
            LOAD: begin 
                if ((current_index == expected_final_index) && (memory_ready_b1)) begin
                    next_state = IDLE;
                end else begin
                    next_state = LOAD;
                end
            end
            STORE: begin    
                if ((current_index == expected_final_index) && (memory_ready_b1)) begin
                    next_state = IDLE; 
                end else begin
                    next_state = STORE;
                end
            end
        endcase
    end
endmodule