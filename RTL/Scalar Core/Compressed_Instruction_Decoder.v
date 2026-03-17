module compressed_instruct_decoder(
    input [31:0] input_instruction,
    output reg [31:0] expanded_instruction,
    output reg illegal_instruction,
    output wire is_compressed
);
localparam VLOAD = 7'b000111,
            VSTORE = 7'b0100111,
            VALU =7'b1010111;
assign is_compressed = (input_instruction[1:0] != 2'b11) && (input_instruction[6:0]!=VALU && input_instruction[6:0]!=VSTORE && input_instruction[6:0]!=VLOAD) ;

wire [15:0] instr = input_instruction[15:0];

wire [1:0]opcode;
wire [2:0] funct3;
wire [4:0] rs1, rs2, rd;
reg [4:0] rs1_3, rs2_3,rd_3;

assign opcode = instr[1:0]; 
assign funct3 = instr[15:13];
assign rs1 = instr[11:7];
assign rs2 = instr[6:2];
assign rd = rs1;

//////ENCODING REGISTERS FOR RS1' RS2'////////
always @(*) begin
    case (instr[9:7])
        3'b000: rs1_3 = 5'd8;
        3'b001: rs1_3 = 5'd9;
        3'b010: rs1_3 = 5'd10;
        3'b011: rs1_3 = 5'd11;
        3'b100: rs1_3 = 5'd12;
        3'b101: rs1_3 = 5'd13;
        3'b110: rs1_3 = 5'd14;
        3'b111: rs1_3 = 5'd15;
        default rs1_3 = 5'd0;
    endcase

    ///RS2_3////
    case (instr[4:2])
        3'b000: rs2_3 = 5'd8;
        3'b001: rs2_3 = 5'd9;
        3'b010: rs2_3 = 5'd10;
        3'b011: rs2_3 = 5'd11;
        3'b100: rs2_3 = 5'd12;
        3'b101: rs2_3 = 5'd13;
        3'b110: rs2_3 = 5'd14;
        3'b111: rs2_3 = 5'd15;
        default rs2_3 = 5'd0;
    endcase

    if (opcode==00) begin
        rd_3=rs2_3;
    end else begin
        rd_3=rs1_3;
    end

end




localparam [6:0] R_Type = 7'b0110011,
                 I_Type = 7'b0010011,
                 LOAD = 7'b0000011,
                 STORE = 7'b0100011,
                 BRANCH = 7'b1100011,
                 LUI = 7'b0110111,
                 AUIPC = 7'b0010111,
                 ZCSR = 7'b1110011,
                 JAL = 7'b1101111,
                 JALR = 7'b1100111;


always@(input_instruction) begin
illegal_instruction = 0;
    if(!instr) begin
        illegal_instruction=1;
        expanded_instruction=32'b0;
    end else begin

        case(opcode)
            2'b00: begin
                case(funct3)
                    0: expanded_instruction = {2'b00,instr[10:7],instr[12:11],instr[5],instr[6],2'b00,5'd2,3'b000,rd_3,I_Type}; // ADDI4SPN

                    2: expanded_instruction = {5'd0,instr[5],instr[12:10],instr[6],2'b0,rs1_3,3'b010,rd_3,LOAD}; //LW

                    6: expanded_instruction = {5'd0,instr[5],instr[12],rs2_3,rs1_3,3'b010,instr[11:10],instr[6],2'b00,STORE}; //SW

                    default: begin 
                    expanded_instruction = 32'b0;
                    illegal_instruction = 1;
                end
            endcase
            end


            2'b01: begin
                case(funct3) 
                    0: expanded_instruction = (rs1)? {{6{instr[12]}},instr[12],instr[6:2],rs1,funct3,rd,I_Type} : {25'b0,I_Type}; //ADDI

                    1: expanded_instruction = {instr[12],instr[8],instr[10:9],instr[6],instr[7],instr[2],instr[11],instr[5:3],instr[12],{8{instr[12]}},5'd1,JAL}; //JAL

                    2: expanded_instruction = {{6{instr[12]}},instr[12],instr[6:2],5'b0,3'd0,rd,I_Type}; //LI

                    3: begin 
                        if(rs1==2) begin
                            expanded_instruction = {{2{instr[12]}},instr[12],instr[4:3],instr[5],instr[2],instr[6],4'd0,5'd2,3'd0,5'd2,I_Type};//ADDI16SP
                        end else begin
                            expanded_instruction = {{15{instr[12]}},instr[12],instr[6:2],rd,LUI}; //LUI
                        end
                    end

                    4: begin
                        case(instr[11:10])
                            0: begin
                              if(!instr[12]&&instr[6:2]!=0) begin
                                    expanded_instruction = {7'd0,instr[6:2],rs1_3,3'b101,rd_3,I_Type}; //srli
                                end else begin
                                    expanded_instruction = 32'b0;
                                    illegal_instruction = 1;
                                end
                            end

                            1: begin
                              if(!instr[12]&&instr[6:2]!=0) begin
                                    expanded_instruction = {7'b0100000,instr[6:2],rs1_3,3'b101,rd_3,I_Type}; //srai
                                end else begin
                                    expanded_instruction = 32'b0;
                                    illegal_instruction = 1;
                                end
                            end

                            2: expanded_instruction = {{6{instr[12]}},instr[12],instr[6:2],rs1_3,3'b111,rd_3,I_Type}; //andi

                            3: begin
                                case(instr[6:5])
                                    0: expanded_instruction = {7'b0100000,rs2_3,rs1_3,3'b000,rd_3,R_Type}; //sub
                                    1: expanded_instruction = {7'd0,rs2_3,rs1_3,3'b100,rd_3,R_Type}; //xor
                                    2: expanded_instruction = {7'd0,rs2_3,rs1_3,3'b110,rd_3,R_Type}; //or
                                    3: expanded_instruction = {7'd0,rs2_3,rs1_3,3'b111,rd_3,R_Type}; //and
                                    default: begin
                                                expanded_instruction=32'b0;
                                                illegal_instruction=1;
                                            end
                                endcase
                            end
                        endcase
                    end
        
                            5: expanded_instruction = {instr[12],instr[8],instr[10:9],instr[6],instr[7],instr[2],instr[11],instr[5:3],instr[12],{8{instr[12]}},5'd0,JAL}; //J

                            6: expanded_instruction = {{3{instr[12]}},instr[12],instr[6:5],instr[2],5'd0,rs1_3,3'b000,instr[11:10],instr[4:3],instr[12],BRANCH}; //BEQZ

                            7: expanded_instruction = {{3{instr[12]}},instr[12],instr[6:5],instr[2],5'd0,rs1_3,3'b001,instr[11:10],instr[4:3],instr[12],BRANCH}; //BNEQZ
                        endcase
                    end


                2'b10: begin
                    case (funct3)
                        0: begin
                              if(!instr[12]&&instr[6:2]!=0) begin
                                    expanded_instruction = {7'd0,instr[6:2],rs1,3'b001,rd,I_Type}; //srli
                                end else begin
                                    expanded_instruction = 32'b0;
                                    illegal_instruction = 1;
                                end
                            end


                        2: expanded_instruction = {4'd0,instr[3:2],instr[12],instr[6:4],2'b00,5'd2,3'b010,rd,LOAD}; //LWSP

                        4: begin
                            case (instr[12])
                                0: begin
                                    case (instr[6:2])
                                        0: expanded_instruction = {12'd0,rs1,3'b000,5'd0,JALR}; //JR

                                        default: expanded_instruction = {7'd0,rs2,5'd0,3'b000,rd,R_Type}; //MV
                                    endcase
                                end

                                1: begin
                                        //if(instr[11:7]==0) begin
                                        //    expanded_instruction = {12'd1,13'd0,ZCSR}; //EBREAK
                                        //end else
                                        if(instr[6:2]==0) begin
                                            expanded_instruction = {12'd0,rs1,3'b000,5'd1,JALR}; //JALR
                                        end else begin
                                            expanded_instruction = {7'd0,rs2,rs1,3'b000,rd,R_Type}; //ADD
                                        end
                                end
                            
                            endcase
                        end

                        6: expanded_instruction = {4'd0,instr[8:7],instr[12],rs2,5'd2,3'b010,instr[11:9],2'b00,STORE};//SWSP

                        default : begin 
                            expanded_instruction = 32'b0;
                            illegal_instruction = 1;
                        end
                    endcase
                end

                default: expanded_instruction = input_instruction;
        endcase
    end
end
endmodule