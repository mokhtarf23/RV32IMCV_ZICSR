`timescale 1ns/1ps
module rs_alu_tb;

  reg         clk;
  reg         rst;


  reg         valid_i;
  reg [127:0] Vs1_i, Vs2_i, mask_i;
  reg [31:0]  Imm_i;
  reg [4:0]   ID_i;
  reg [2:0]   SEW_i;
  reg [2:0]   reservation_station_en_i;
  reg [6:0]   opcode_i;
  reg [2:0]   funct3_i;
  reg [5:0]   funct6_i;
  reg         valid1_i, valid2_i;

 
  reg [127:0]  chain1_i;
  reg [127:0]  chain2_i;
  reg chain_ready_1_i, chain_ready_2_i;

  wire [31:0] data1_o [0:3];
  wire [31:0] data2_o [0:3];
  wire [4:0]  ID_o;
  wire [6:0]  opcode_o;
  wire [2:0]  funct3_o;
  wire [5:0]  funct6_o;
  wire full;
  wire        valid_o;


  Reservation_Station_ALU dut (
    .clk(clk),
    .rst(rst),
    .valid_i(valid_i),
    .Vs1_i(Vs1_i),
    .Vs2_i(Vs2_i),
    .mask_i(mask_i),
    .Imm_i(Imm_i),
    .ID_i(ID_i),
    .SEW_i(SEW_i),
    .reservation_station_en_i(reservation_station_en_i),
    .opcode_i(opcode_i),
    .funct3_i(funct3_i),
    .funct6_i(funct6_i),
    .valid1_i(valid1_i),
    .valid2_i(valid2_i),
    .chain1_i(chain1_i),
    .chain2_i(chain2_i),
    .chain_ready_1_i(chain_ready_1_i),
    .chain_ready_2_i(chain_ready_2_i),
    .data1_o(data1_o),
    .data2_o(data2_o),
    .ID_o(ID_o),
    .opcode_o(opcode_o),
    .funct3_o(funct3_o),
    .funct6_o(funct6_o),
    .full(full),
    .valid_o(valid_o)
  );


  initial begin
    clk = 1;
    forever #5 clk = ~clk;
  end


  initial begin
    integer i;
    rst                       = 1;
    valid_i                   = 0;
    reservation_station_en_i  = 3'b000;
    Vs1_i                     = 0;
    Vs2_i                     = 0;
    mask_i                    = 0;
    Imm_i                     = 0;
    ID_i                      = 0;
    SEW_i                     = 0;
    opcode_i                  = 0;
    funct3_i                  = 0;
    funct6_i                  = 0;
    valid1_i                  = 0;
    valid2_i                  = 0;

    chain1_i = {32'h11,32'h11,32'h11,32'h11};
    chain2_i = {32'h22,32'h22,32'h22,32'h22};

 

    #10; rst = 0;


//////////TEST CASE 1: multiple SEW=32 instructions wara ba3d NO CHAINING///////////
    SEW_i                    = 3'b010;
    valid1_i                 = 1;
    valid2_i                 = 1;
    chain_ready_1_i=1;
    chain_ready_2_i=1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h1,32'h1,32'h1,32'h1};
    Vs2_i                    = {32'h1,32'h1,32'h1,32'h1};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd1;
    opcode_i                 = 7'd1;
    funct3_i                 = 3'd1;
    funct6_i                 = 6'd1;
    valid_i                  = 1;
    #10;
    SEW_i                    = 3'b010;
    valid1_i                 = 1;
    valid2_i                 = 1;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h2,32'h2,32'h2,32'h2};
    Vs2_i                    = {32'h2,32'h2,32'h2,32'h2};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd2;
    opcode_i                 = 7'd2;
    funct3_i                 = 3'd2;
    funct6_i                 = 6'd2;
    valid_i                  = 1;
    #10;
    SEW_i                    = 3'b010;
    valid1_i                 = 1;
    valid2_i                 = 1;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h3,32'h3,32'h3,32'h3};
    Vs2_i                    = {32'h3,32'h3,32'h3,32'h3};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd3;
    opcode_i                 = 7'd3;
    funct3_i                 = 3'd3;
    funct6_i                 = 6'd3;
    valid_i                  = 1;
    #10;
    SEW_i                    = 3'b010;
    valid1_i                 = 1;
    valid2_i                 = 1;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h4,32'h4,32'h4,32'h4};
    Vs2_i                    = {32'h4,32'h4,32'h4,32'h4};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd4;
    opcode_i                 = 7'd4;
    funct3_i                 = 3'd4;
    funct6_i                 = 6'd4;
    valid_i                  = 1;
    #10



    //////////TEST CASE 2: multiple SEW=32 instructions wara ba3d CHAINING ALWAYS READY///////////
    SEW_i                    = 3'b010;
    valid1_i                 = 0;
    valid2_i                 = 1;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h1,32'h1,32'h1,32'h1};
    Vs2_i                    = {32'h1,32'h1,32'h1,32'h1};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd1;
    opcode_i                 = 7'd1;
    funct3_i                 = 3'd1;
    funct6_i                 = 6'd1;
    valid_i                  = 1;
    #10;
    SEW_i                    = 3'b010;
    valid1_i                 = 1;
    valid2_i                 = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h2,32'h2,32'h2,32'h2};
    Vs2_i                    = {32'h2,32'h2,32'h2,32'h2};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd2;
    opcode_i                 = 7'd2;
    funct3_i                 = 3'd2;
    funct6_i                 = 6'd2;
    valid_i                  = 1;
    #10;
    SEW_i                    = 3'b010;
    valid1_i                 = 0;
    valid2_i                 = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h3,32'h3,32'h3,32'h3};
    Vs2_i                    = {32'h3,32'h3,32'h3,32'h3};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd3;
    opcode_i                 = 7'd3;
    funct3_i                 = 3'd3;
    funct6_i                 = 6'd3;
    valid_i                  = 1;
    #10;


    //////////TEST CASE 3: multiple SEW=32 instructions wara ba3d CHAINING NOT ALWAYS READY (NO CONSECUTIVE INSTRUCTIONS)///////////
    SEW_i                    = 3'b010;
    valid1_i                 = 0;
    valid2_i                 = 1;
    chain_ready_1_i          = 0;
    chain_ready_2_i          = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h1,32'h1,32'h1,32'h1};
    Vs2_i                    = {32'h1,32'h1,32'h1,32'h1};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd1;
    opcode_i                 = 7'd1;
    funct3_i                 = 3'd1;
    funct6_i                 = 6'd1;
    valid_i                  = 1;
    #10;
    valid_i                  = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    #10

    SEW_i                    = 3'b010;
    valid1_i                 = 1;
    valid2_i                 = 0;
    chain_ready_1_i          = 0;
    chain_ready_2_i          = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h2,32'h2,32'h2,32'h2};
    Vs2_i                    = {32'h2,32'h2,32'h2,32'h2};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd2;
    opcode_i                 = 7'd2;
    funct3_i                 = 3'd2;
    funct6_i                 = 6'd2;
    valid_i                  = 1;
    #10;
    valid_i                  = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    #10

    SEW_i                    = 3'b010;
    valid1_i                 = 0;
    valid2_i                 = 0;
    chain_ready_1_i          = 0;
    chain_ready_2_i          = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h3,32'h3,32'h3,32'h3};
    Vs2_i                    = {32'h3,32'h3,32'h3,32'h3};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd3;
    opcode_i                 = 7'd3;
    funct3_i                 = 3'd3;
    funct6_i                 = 6'd3;
    valid_i                  = 1;
    #10;
    valid_i                  = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    #10



    //////////TEST CASE 4: multiple SEW=32 instructions wara ba3d CHAINING NOT ALWAYS READY (CONSECUTIVE INSTRUCTIONS)///////////
    SEW_i                    = 3'b010;
    valid1_i                 = 0;
    valid2_i                 = 1;
    chain_ready_1_i          = 0;
    chain_ready_2_i          = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h1,32'h1,32'h1,32'h1};
    Vs2_i                    = {32'h1,32'h1,32'h1,32'h1};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd1;
    opcode_i                 = 7'd1;
    funct3_i                 = 3'd1;
    funct6_i                 = 6'd1;
    valid_i                  = 1;
    #10;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;

  if (full) begin
      valid_i=0;
      #10;
      chain_ready_1_i          = 0;
      chain_ready_2_i          = 0;
    end else begin
      #20
      chain_ready_1_i          = 0;
      chain_ready_2_i          = 0;
    end



    SEW_i                    = 3'b010;
    valid1_i                 = 1;
    valid2_i                 = 0;    
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h2,32'h2,32'h2,32'h2};
    Vs2_i                    = {32'h2,32'h2,32'h2,32'h2};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd2;
    opcode_i                 = 7'd2;
    funct3_i                 = 3'd2;
    funct6_i                 = 6'd2;
    valid_i                  = 1;
    #10;
  
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    if (full) begin
      valid_i=0;
      #10;
      chain_ready_1_i          = 0;
      chain_ready_2_i          = 0;
    end else begin
      #10
      chain_ready_1_i          = 0;
      chain_ready_2_i          = 0;
    end

    SEW_i                    = 3'b010;
    valid1_i                 = 0;
    valid2_i                 = 0;
    chain_ready_1_i          = 0;
    chain_ready_2_i          = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {32'h3,32'h3,32'h3,32'h3};
    Vs2_i                    = {32'h3,32'h3,32'h3,32'h3};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd3;
    opcode_i                 = 7'd3;
    funct3_i                 = 3'd3;
    funct6_i                 = 6'd3;
    valid_i                  = 1;
    #10;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;

    if (full) begin
      valid_i=0;
      #10;
      chain_ready_1_i          = 0;
      chain_ready_2_i          = 0;
    end else begin
      #10
      chain_ready_1_i          = 0;
      chain_ready_2_i          = 0;
    end



    //////////TEST CASE 5: multiple SEW=16 instructions wara ba3d///////////
    SEW_i                    = 3'b001;
    valid1_i                 = 1;
    valid2_i                 = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1};
    Vs2_i                    = {16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd1;
    opcode_i                 = 7'd1;
    funct3_i                 = 3'd1;
    funct6_i                 = 6'd1;
    valid_i                  = 1;
    #10
    SEW_i                    = 3'b001;
    valid1_i                 = 1;
    valid2_i                 = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2};
    Vs2_i                    = {16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd2;
    opcode_i                 = 7'd2;
    funct3_i                 = 3'd2;
    funct6_i                 = 6'd2;
    valid_i                  = 1;
    #10
    SEW_i                    = 3'b001;
    valid1_i                 = 1;
    valid2_i                 = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3};
    Vs2_i                    = {16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd3;
    opcode_i                 = 7'd3;
    funct3_i                 = 3'd3;
    funct6_i                 = 6'd3;
    valid_i                  = 1;
    #20
    SEW_i                    = 3'b001;
    valid1_i                 = 1;
    valid2_i                 = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h4,16'h4,16'h4,16'h4,16'h4,16'h4,16'h4,16'h4};
    Vs2_i                    = {16'h4,16'h4,16'h4,16'h4,16'h4,16'h4,16'h4,16'h4};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd4;
    opcode_i                 = 7'd4;
    funct3_i                 = 3'd4;
    funct6_i                 = 6'd4;
    valid_i                  = 1;
    #10

    #20



    chain1_i = {16'h11,16'h11,16'h11,16'h11,16'h11,16'h11,16'h11,16'h11};
    chain2_i = {16'h12,16'h12,16'h12,16'h12,16'h12,16'h12,16'h12,16'h12};

    //////////TEST CASE 6: multiple SEW=16 instructions wara ba3d CHAINING ALWAYS READY///////////
    SEW_i                    = 3'b001;
    valid1_i                 = 0;
    valid2_i                 = 1;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1};
    Vs2_i                    = {16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd1;
    opcode_i                 = 7'd1;
    funct3_i                 = 3'd1;
    funct6_i                 = 6'd1;
    valid_i                  = 1;
    #20
    SEW_i                    = 3'b001;
    valid1_i                 = 1;
    valid2_i                 = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2};
    Vs2_i                    = {16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd2;
    opcode_i                 = 7'd2;
    funct3_i                 = 3'd2;
    funct6_i                 = 6'd2;
    valid_i                  = 1;
    #20
    SEW_i                    = 3'b001;
    valid1_i                 = 0;
    valid2_i                 = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3};
    Vs2_i                    = {16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd3;
    opcode_i                 = 7'd3;
    funct3_i                 = 3'd3;
    funct6_i                 = 6'd3;
    valid_i                  = 1;
    #20



        //////////TEST CASE 7: multiple SEW=16 instructions wara ba3d CHAINING NOT ALWAYS READY (NO CONSECUTIVE INSTRUCTIONS)///////////
    SEW_i                    = 3'b001;
    valid1_i                 = 0;
    valid2_i                 = 1;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1};
    Vs2_i                    = {16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd1;
    opcode_i                 = 7'd1;
    funct3_i                 = 3'd1;
    funct6_i                 = 6'd1;
    valid_i                  = 1;
    #10
    valid_i                  = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    #10
    SEW_i                    = 3'b001;
    valid1_i                 = 1;
    valid2_i                 = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2};
    Vs2_i                    = {16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd2;
    opcode_i                 = 7'd2;
    funct3_i                 = 3'd2;
    funct6_i                 = 6'd2;
    valid_i                  = 1;
    #10
    valid_i                  = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    #10
    SEW_i                    = 3'b001;
    valid1_i                 = 0;
    valid2_i                 = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3};
    Vs2_i                    = {16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd3;
    opcode_i                 = 7'd3;
    funct3_i                 = 3'd3;
    funct6_i                 = 6'd3;
    valid_i                  = 1;
    #10
    valid_i                  = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    #10



            //////////TEST CASE 8: multiple SEW=16 instructions wara ba3d CHAINING NOT ALWAYS READY (ready after one cycle) (CONSECUTIVE INSTRUCTIONS)///////////
    SEW_i                    = 3'b001;
    valid1_i                 = 0;
    valid2_i                 = 1;
    chain_ready_1_i          = 0;
    chain_ready_2_i          = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1};
    Vs2_i                    = {16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1,16'h1};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd1;
    opcode_i                 = 7'd1;
    funct3_i                 = 3'd1;
    funct6_i                 = 6'd1;
    valid_i                  = 1;
    #10
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    if (full) begin
      valid_i=0;
      #10;
      chain_ready_1_i          = 0;
      chain_ready_2_i          = 0;
    end
    SEW_i                    = 3'b001;
    valid1_i                 = 1;
    valid2_i                 = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2};
    Vs2_i                    = {16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2,16'h2};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd2;
    opcode_i                 = 7'd2;
    funct3_i                 = 3'd2;
    funct6_i                 = 6'd2;
    valid_i                  = 1;
    #10
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    if (full) begin
      valid_i=0;
      #10;
      chain_ready_1_i          = 0;
      chain_ready_2_i          = 0;
    end
    valid_i                  = 0;
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    #10
    SEW_i                    = 3'b001;
    valid1_i                 = 0;
    valid2_i                 = 0;
    reservation_station_en_i = 3'd1;
    Vs1_i                    = {16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3};
    Vs2_i                    = {16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3,16'h3};
    mask_i                   = {128{1'b1}};
    ID_i                     = 5'd3;
    opcode_i                 = 7'd3;
    funct3_i                 = 3'd3;
    funct6_i                 = 6'd3;
    valid_i                  = 1;
    #10
    chain_ready_1_i          = 1;
    chain_ready_2_i          = 1;
    if (full) begin
      valid_i=0;
      #10;
      chain_ready_1_i          = 0;
      chain_ready_2_i          = 0;
    end

    #20
    $stop;

  end
endmodule
