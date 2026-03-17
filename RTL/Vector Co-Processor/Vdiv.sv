module Vdiv #(
  parameter DATA_WIDTH = 32,
  parameter EX1_W = 160,
  parameter EX2_W = 96,
  parameter EX3_W = 96,
  parameter EX4_W = 32
)(
  input  logic clk,
  input  logic rst,
  input  logic valid_i,
  input  logic [5:0] opcode,
  input  logic [DATA_WIDTH-1:0] data_a_ex1_i,
  input  logic [DATA_WIDTH-1:0] data_b_ex1_i,
  input  logic [5:0] ID_i,
  input  logic [2:0] SEW_i,
  input  logic [4:0] VD_add_i,

  output logic [EX4_W-1:0] result_div_ex4,
  output logic valid_o,
  output logic [DATA_WIDTH-1:0] remainder_final,
  output logic [DATA_WIDTH-1:0] result_final,
  output logic [DATA_WIDTH-1:0] result,
  output logic [5:0] ID_o,
  output logic [2:0] SEW_o,
  output logic [4:0] VD_add_o
);

  typedef enum logic [1:0] {
    SIGNED_DIV  = 2'b00,
    SIGNED_REM  = 2'b01,
    UNSIGNED_DIV = 2'b10,
    UNSIGNED_REM = 2'b11
  } op_mode_e;


  logic [DATA_WIDTH-1:0] quotient, remainder;
  logic [DATA_WIDTH:0] rem_next;
  logic [DATA_WIDTH-1:0] quot_next;
  logic [DATA_WIDTH-1:0] dividend;
  logic [DATA_WIDTH-1:0] divisor;
  logic dividend_neg, divisor_neg, quot_neg, rem_neg;
  op_mode_e mode;

  logic signed [DATA_WIDTH-1:0] a_s;
  logic signed [DATA_WIDTH-1:0] b_s;

  always_comb begin
    quotient = 0;
    remainder = 0;
    rem_next = 0;
    quot_next = 0;
    dividend = 0;
    divisor = 0;
    dividend_neg = 0;
    divisor_neg = 0;
    quot_neg = 0;
    rem_neg = 0;

    case (opcode)
      6'b100001: mode = SIGNED_DIV;
      6'b100011: mode = SIGNED_REM;
      6'b100000: mode = UNSIGNED_DIV;
      6'b100010: mode = UNSIGNED_REM;
      default:   mode = SIGNED_DIV;
    endcase

    case (mode)
      SIGNED_DIV, SIGNED_REM: begin
        logic signed [DATA_WIDTH-1:0] a_s;
        logic signed [DATA_WIDTH-1:0] b_s;

        a_s = data_a_ex1_i;
        b_s = data_b_ex1_i;

        dividend_neg = (a_s < 0);
        divisor_neg = (b_s < 0);
        quot_neg = dividend_neg ^ divisor_neg;
        rem_neg = dividend_neg;

        dividend = dividend_neg ? -a_s : a_s;
        divisor = divisor_neg ? -b_s : b_s;

        if (b_s == 0) begin
          quot_next = 0;
          rem_next = dividend;
        end else begin
          for (int i = DATA_WIDTH-1; i >= 0; i--) begin
            rem_next = {rem_next[DATA_WIDTH-2:0], dividend[i]};
            if (rem_next >= divisor) begin
              rem_next = rem_next - divisor;
              quot_next[i] = 1;
            end
          end
        end

        quotient = quot_neg ? -quot_next : quot_next;
        remainder = rem_neg ? -rem_next[DATA_WIDTH-1:0] : rem_next[DATA_WIDTH-1:0];
      end

      UNSIGNED_DIV, UNSIGNED_REM: begin
        dividend = data_a_ex1_i;
        divisor = data_b_ex1_i;

        if (divisor == 0) begin
          quot_next = 0;
          rem_next = dividend;
        end else begin
          for (int i = DATA_WIDTH-1; i >= 0; i--) begin
            rem_next = {rem_next[DATA_WIDTH-2:0], dividend[i]};
            if (rem_next >= divisor) begin
              rem_next = rem_next - divisor;
              quot_next[i] = 1;
            end
          end
        end

        quotient = quot_next;
        remainder = rem_next[DATA_WIDTH-1:0];
      end
    endcase
  end

  always@(*) begin
    if (rst) begin
      result_div_ex4 = 0;
      valid_o = 0;
      result_final = 0;
      remainder_final = 0;
      result = 0;
      ID_o = 0;
      SEW_o = 0;
      VD_add_o = 0;
    end else if (valid_i) begin
      result_final = quotient;
      remainder_final = remainder;
      result = (opcode == 6'b100001 || opcode == 6'b100000) ? quotient : remainder;
      valid_o = 1;
      ID_o = ID_i;
      SEW_o = SEW_i;
      VD_add_o = VD_add_i;
    end else begin
      valid_o = 0;
      ID_o = 0;
      VD_add_o = 0;
      SEW_o = 0;
    end
  end

endmodule

