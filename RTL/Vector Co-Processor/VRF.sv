module vector_regfile #(
  parameter VLEN      = 128,   // maximum vector register width in bits
  parameter LGREGS    = 5,     // log2(number of vector registers) = 5 ⇒ 32 regs
  parameter NREGS     = 32
)(
  input clk,
  input rst,

  // ----- WRITE PORT -----
  input                    wen,
  input  [LGREGS-1:0]      waddr,
  input  [VLEN-1:0]        wdata,

  // ----- READ PORT 0 (vs1) -----

  input  [LGREGS-1:0]      raddr0,
  output [VLEN-1:0]        rdata0,

  // ----- READ PORT 1 (vs2) -----
  input  [LGREGS-1:0]      raddr1,
  output [VLEN-1:0]        rdata1,

  // ----- READ PORT 2 (mask / v0) -----
  // Vector‐mask always comes from v0 by the spec, but we still expose a full port
  output [VLEN-1:0]        rdata2
);

  reg [VLEN-1:0] regs [0:NREGS-1];
  reg [5:0] i;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      i=0;
      for (i = 0; i < NREGS; i=i+1) begin
        regs[i] <= 0;
         // regs[i] <= {26'd0,i,26'd0,i,26'd0,i,26'd0,i};//32
        //  regs[i] <= {10'd0,i,10'd0,i,10'd0,i,10'd0,i,10'd0,i,10'd0,i,10'd0,i,10'd0,i}; //16
      end  
        regs[1] <= {8'd2,8'd4,8'd6,8'd8,8'd10,8'd12,8'd14,8'd16,8'd18,8'd20,8'd22,8'd24,8'd26,8'd28,8'd30,8'd32};
        regs[2] <= {8'd2,8'd4,8'd6,8'd8,8'd10,8'd12,8'd14,8'd16,8'd18,8'd20,8'd22,8'd24,8'd26,8'd28,8'd30,8'd32};
    end else if (wen) begin
      regs[waddr] <= wdata;
    end
  end

  assign rdata0 =  regs[raddr0];
  assign rdata1 =  regs[raddr1];
  assign rdata2 =  regs[0];

endmodule