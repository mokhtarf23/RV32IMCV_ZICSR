module vector_regfile #(
  parameter VLEN = 128,   // maximum vector register width in bits
  parameter LGREGS = 5,     // log2(number of vector registers) = 5 ⇒ 32 regs
  parameter NREGS = 32
)(
  input clk,
  input rst,

  input  wen,
  input  [LGREGS-1:0]  waddr,
  input  [VLEN-1:0]  wdata,


  input  [LGREGS-1:0] raddr0,
  output [VLEN-1:0]  rdata0,

  input  [LGREGS-1:0] raddr1,
  output [VLEN-1:0] rdata1,

  output [VLEN-1:0] rdata2
);

  reg [VLEN-1:0] regs [0:NREGS-1];
  reg [5:0] i;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      i=0;
      for (i = 0; i < NREGS; i=i+1) begin
        regs[i] <= 0;
      end  
    end else if (wen) begin
      regs[waddr] <= wdata;
    end
  end

  assign rdata0 =  regs[raddr0];
  assign rdata1 =  regs[raddr1];
  assign rdata2 =  regs[0];

endmodule
