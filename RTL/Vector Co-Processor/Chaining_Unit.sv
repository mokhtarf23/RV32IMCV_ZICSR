module Chaining_Unit
(
   input clk,rst,
   input Chaining_needed, //from sequencer combinational mesh hatet2a5ar
   input [1:0] Chain_Operand, //bit0 = need A, bit1 = need B
   input [4:0] Vs_Addr [1:0], 

   input [127:0] Writeback_Queue_Vd_i [1:0], // A,B

   input [1:0] Chain_Valid_WB_i, //if found in wb

   output reg [4:0] Vs_Addr_Used [1:0], //for queue
   output reg [1:0] Queue_Search_En,// ask queue for A,B
   output reg [1:0] Chaining_Ready_o,
   output reg Chaining_Done,Chaining_almost_Done_o,//high when all required ready
   output reg WB_Chain_o, // for seq // from wb to chain to seq
   output reg [127:0] Chain_Vd_o [1:0] 
);

integer i;
localparam E32 = 3'b010,
           E16 = 3'b001, 
           E8 = 3'b000;

always @(*) begin
    WB_Chain_o = Chain_Valid_WB_i[0] || Chain_Valid_WB_i[1];
	Queue_Search_En = 2'd0;   
	Chaining_Ready_o = 2'd0;     
	Chaining_Done = 0; 
	for (i = 0; i < 2; i++) begin
		Chain_Vd_o[i] = 128'd0;
	end

    if (Chaining_needed) begin
        Queue_Search_En[0] = Chain_Operand[0]; 
        Queue_Search_En[1] = Chain_Operand[1]; 

        if (!Chaining_Ready_o[0] && Queue_Search_En[0] && Chain_Valid_WB_i[0]) begin
            Chain_Vd_o [0] = Writeback_Queue_Vd_i[0];
            Chaining_Ready_o[0] = 1'b1;
        end

        if (!Chaining_Ready_o[1] && Queue_Search_En[1] && Chain_Valid_WB_i[1]) begin
            Chain_Vd_o [1] = Writeback_Queue_Vd_i[1];
            Chaining_Ready_o[1] = 1'b1;
        end

        case (Chain_Operand)
            2'b00: Chaining_Done = 1;
            2'b01: Chaining_Done = Chaining_Ready_o[0];
            2'b10: Chaining_Done = Chaining_Ready_o[1];
            2'b11: Chaining_Done = Chaining_Ready_o[0]&&Chaining_Ready_o[1];
        endcase
            
    end else begin
        Chaining_Done = 0;
        Chaining_almost_Done_o = 0;
    end
end

endmodule

   