module Branching_Unit (
    clk,
    reset,
    Imm,
    funct3,
    opcode,
    Branch_Unit_Enable,
    PC,
    Next_PC,
    B_J_Target,
    Flush_IF,
    PC_Control_Signal,
    Zero_Flag,
    Greater_Equal_Flag
);

input clk, reset;
input [6:0] opcode;
input [2:0] funct3;
input [31:0] Imm;
input [31:0] PC, Next_PC;
input Branch_Unit_Enable;
input Zero_Flag;
input Greater_Equal_Flag;
output reg Flush_IF;
output reg PC_Control_Signal;
output reg [31:0] B_J_Target;

localparam [6:0] B_Type = 7'b1100011,
                 Jal    = 7'b1101111;

localparam [2:0] beq  = 3'b000,
                 bne  = 3'b001,
                 blt  = 3'b100,
                 bge  = 3'b101,
                 bltu = 3'b110,
                 bgeu = 3'b111;

localparam Branch_Prediction = 0,
           Condition_Checking = 1;

reg cs, ns;
reg [2:0] funct3_reg;
reg [31:0] Next_PC_reg;
reg capture_enable;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        cs <= Branch_Prediction;
    end else begin
        cs <= ns;
     end
end

///// SAVING FUNCT3 AND NEXT_PC
always @(posedge clk or posedge reset) begin
	if(reset) begin
		funct3_reg <= 0;
    	Next_PC_reg <= 0;
	end else begin
		 if (capture_enable) begin
            funct3_reg <= funct3;
            Next_PC_reg <= Next_PC;
        end
	end
end

always @(*) begin
    Flush_IF = 0;
    PC_Control_Signal = 0;
    B_J_Target = 0;
    ns = cs;
    capture_enable=0;
    case (cs)
        Branch_Prediction: begin
            if (Branch_Unit_Enable) begin
                PC_Control_Signal = 1;
                B_J_Target = Imm + PC;
                Flush_IF = 1;
                capture_enable=1;
                if (opcode==B_Type) begin
                    ns = Condition_Checking;
                end else if (opcode==Jal) begin
                    ns = Branch_Prediction;
                end
            end else begin
                PC_Control_Signal = 0;
                B_J_Target = 0;
                Flush_IF = 0;
                capture_enable=0;
                ns = Branch_Prediction;
            end
        end

        Condition_Checking: begin
                case (funct3_reg)
                    beq: begin
                        if (!Zero_Flag) begin
                            PC_Control_Signal = 1;
                            B_J_Target = Next_PC_reg;
                            Flush_IF = 1;
                        end
                        ns = Branch_Prediction;
                    end
                    bne: begin
                        if (Zero_Flag) begin
                            PC_Control_Signal = 1;
                            B_J_Target = Next_PC_reg;
                            Flush_IF = 1;
                        end
                        ns = Branch_Prediction;
                    end
                    bltu, blt: begin
                        if (Greater_Equal_Flag) begin
                            PC_Control_Signal = 1;
                            B_J_Target = Next_PC_reg;
                            Flush_IF = 1;
                        end
                        ns = Branch_Prediction;
                    end
                    bge, bgeu: begin
                        if (!Greater_Equal_Flag) begin
                            PC_Control_Signal = 1;
                            B_J_Target = Next_PC_reg;
                            Flush_IF = 1;
                        end
                        ns = Branch_Prediction;
                    end
                    default: begin
                        PC_Control_Signal = 1;
                        B_J_Target = Next_PC_reg;
                        Flush_IF = 1;
                        ns = Branch_Prediction;
                    end
                endcase 
        end

        default: begin
            PC_Control_Signal = 0;
            B_J_Target = 0;
            Flush_IF = 0;
            ns = Branch_Prediction;
        end
    endcase    
end

endmodule
