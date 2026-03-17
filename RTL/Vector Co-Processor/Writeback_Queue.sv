module Writeback_Queue
(
    input clk, rst,
    //FROM DECODE
    input [5:0] ID_D_i,
    input ID_Valid_i,      
    input [4:0] Vd_Addr, 
    input Vs_Vd_Same_i,

    //FROM SEQ
    input Seq_Valid_i,

    input [5:0] ID_Seq_i,
    // FROM EXECUTION
    input [5:0] ID_i [5:0],
    input [127:0] Vd_i [5:0],
    input valid_i [5:0],



    output reg [31:0] busy_registers, 

    output reg [127:0] Vd_o,
    output reg [4:0] Vd_Addr_o,
    output reg Wr_En

);

    localparam DEPTH = 8;
    localparam PTR_W = $clog2(DEPTH);

    reg valid_q [0:DEPTH-1];
    reg ready_q [0:DEPTH-1];
    reg  [5:0] id_q    [0:DEPTH-1];
    reg  [4:0] addr_q  [0:DEPTH-1];
    reg [127:0] data_q  [0:DEPTH-1];

    reg [PTR_W-1:0]   head;   
    reg [PTR_W-1:0]   tail; 

    integer i, lane;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        head <= {PTR_W{1'b0}};
        tail <= {PTR_W{1'b0}};
        busy_registers <= 32'd0;          // all free
        for (i = 0; i < DEPTH; i = i + 1) begin
            valid_q[i] <= 1'b0;
            ready_q[i] <= 1'b0;
            id_q[i] <= 6'd0;
            addr_q[i] <= 5'd0;
            data_q[i] <= 128'd0;
        end
    end else begin

        if (ID_Valid_i) begin
            valid_q[tail] <= 1'b1;
            ready_q[tail] <= 1'b0;
            id_q[tail] <= ID_D_i;
            addr_q[tail] <= Vd_Addr;
            data_q[tail] <= 128'd0;
            busy_registers[Vd_Addr] <= (Vs_Vd_Same_i||Vd_Addr==5'd0)? busy_registers[Vd_Addr]:1;
            tail <= tail + 1'b1; //wraps around automatically bel overflow
        end



        ////taking results from gatherers
         for (lane = 0; lane < 5; lane = lane + 1) begin
        if (valid_i[lane]) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                if (valid_q[i] && (id_q[i] == ID_i[lane])) begin
                    data_q [i] <= Vd_i[lane];
                    ready_q[i] <= 1'b1;
                end
            end
        end
    end

        if (Wr_En) begin
            valid_q[head] <= 1'b0;  
            busy_registers[Vd_Addr_o] <= (ID_Valid_i&&Vd_Addr==addr_q[head])? 1'b1:1'b0;   //free the reg only IF NO NEW INSTRUCTION WANTS TO USE SAME REGISTER
            ready_q[head] <= 1'b0;
            id_q[head] <= 0;
            addr_q[head] <= 0;
     //       data_q[head] <= 128'd0;
            head <= head + 1'b1;
        end

    end
end





wire head_ready = valid_q[head] && ready_q[head];

//commit
always @(*) begin
    if (head_ready) begin
        Vd_o = data_q [head];
        Vd_Addr_o = addr_q[head];
        Wr_En = 1'b1;
    end else begin
        Vd_o = 128'd0;
        Vd_Addr_o = 5'd0;
        Wr_En = 1'b0;
    end
end


endmodule