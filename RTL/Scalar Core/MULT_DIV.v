module MULT_DIV(
    input clk,rst, //rst comes from funct 7& opcode from top module
    input wire signed [31:0] Op1, Op2,
    input wire [2:0] funct3,
    output reg signed [31:0] MULT_DIV_OUT,
    output reg mult_div_stall
);
  
  reg [2:0] cs,ns;
  wire mult_rst,div_rst;
  wire mult_done;
  reg div_done;
  assign mult_rst= (funct3<=3'b011 && !rst)? 0:1;
  assign div_rst= (funct3>3'b011 && !rst)? 0:1;


//////////////MULTIPLICATION///////////////
    localparam IDLE=2'b00,
               S1=2'b01,
               S2=2'b10;

    reg [63:0] Op1_unsigned,Op2_unsigned;            
    reg signed [63:0] multiplicand,multiplier;
    reg [63:0] unsigned_result,result,mult_result;

//STATE TRANSITION
always @(posedge clk or posedge mult_rst) begin
        if (mult_rst) begin
            cs<=0;
        end else begin
            cs<=ns;
        end
    end

//REMOVING ALL SIGNS
    always @(*) begin
        case (funct3)
            3'b000,3'b001,3'b100,3'b110: begin 
        if (Op1[31]) begin //ALL SIGNED OPERATIONS
            Op1_unsigned=(~Op1+1);
            multiplicand={32'b0, Op1_unsigned[31:0]};
        end else begin
            Op1_unsigned=Op1;
            multiplicand={32'b0, Op1_unsigned[31:0]};
        end

        if (Op2[31]) begin
            Op2_unsigned=(~Op2+1);
            multiplier={32'b0, Op2_unsigned[31:0]};
        end else begin
            Op2_unsigned=Op2;
            multiplier={32'b0, Op2_unsigned[31:0]};
        end
        end

        3'b010: begin if (Op1[31]) begin //MULHSU OPERATIONS
            Op1_unsigned=(~Op1+1);
            multiplicand={32'b0, Op1_unsigned[31:0]};
        end else begin
            Op1_unsigned=Op1;
            multiplicand={32'b0, Op1_unsigned[31:0]};
        end
            Op2_unsigned=Op2;
            multiplier={32'b0, Op2_unsigned[31:0]};
        end

        3'b011,3'b101,3'b111: begin // ALL UNSIGNED OPERATIONS
            Op1_unsigned={32'b0, Op1[31:0]};
            Op2_unsigned={32'b0, Op2[31:0]};
            multiplicand={32'b0, Op1_unsigned[31:0]};
            multiplier={32'b0, Op2_unsigned[31:0]};
        end
            default : begin 
                    multiplicand=0;
                      multiplier=0;
                  end
        endcase
    end



reg [5:0] i;
assign mult_done=(i<=33)? 0:1;
reg [31:0] QM; //multiplier
reg [63:0] B; //multiplicand


always@(posedge clk or posedge mult_rst) begin
    if (mult_rst || mult_done) begin
        unsigned_result<=0;
        i<=0;
    end else begin
        if (i==1) begin
            if (multiplier[0]) begin
                unsigned_result<=unsigned_result+multiplicand;
            end
            B<=multiplicand<<1;
            QM<=multiplier>>1;
        end else begin
            if (QM[0]) begin
                unsigned_result<=unsigned_result+B;
            end
            B<=B<<1;
            QM<=QM>>1;
        end
    i<=i+1;
    end
end

//HANDLING SIGNS 
always @(*) begin
result=0;
mult_result=0;
        case (funct3)
            3'b000: begin if (Op1[31]^Op2[31]) begin ////////MUL (SIGNED)
                result=-unsigned_result;
                mult_result=result[31:0];
            end else begin
                mult_result=unsigned_result[31:0];
             end
         end

            3'b001: begin if (Op1[31]^Op2[31]) begin ////////MULH (SIGNED)
                result=-unsigned_result;
                mult_result=result[63:32];
            end else begin
                mult_result=unsigned_result[63:32];
             end
         end

            3'b010: begin if (Op1[31]) begin /////// MULHSU (OP1 signed OP2 not signed)
                result=-unsigned_result;
                mult_result=result[63:32];
            end else begin
                mult_result=unsigned_result[63:32];
             end
         end

         3'b011: mult_result = unsigned_result[63:32];///////// MULHU UNSIGNED

         default: begin if (Op1[31]^Op2[31]) begin ////////MUL (SIGNED)
                result=-unsigned_result;
                mult_result=result[31:0];
            end else begin
                mult_result=unsigned_result[31:0];
             end
         end
        endcase
        
    end


//////////////DIVISION///////////////
    reg [32:0] Acc, Shift_Acc, New_Acc;
    reg [31:0] Q, Shift_Q, Divisor;
    reg [31:0] div_result;
    reg [31:0] remainder;
    reg  [5:0] count;
    reg busy;

    wire [31:0] Op1_div,Op2_div;
    assign Op1_div=Op1_unsigned[31:0];
    assign Op2_div=Op2_unsigned[31:0];


always @(posedge clk or posedge div_rst) begin
    if (div_rst) begin
        busy<= 1'b0;
        count<= 6'h0;
        Divisor<= 32'h0;
        div_done<=0;
    end else begin

        if (!busy || div_done) begin
            busy<=1;
            div_done<=0;
            Divisor<= Op2_div;
        end else if (count==6'd33) begin
            busy<= 0;
            div_done<=1;
        end
        
        if (busy) begin
            count <= count + 1;
        end else begin 
            count <= 0;
        end

    end
end

///ADDITION / SUBTRACTION LOGIC
always @(*)begin
        if(count==32) begin
            if (!Acc[32]) begin
                New_Acc= Acc-{1'b0,Divisor};
            end else begin
                New_Acc= Acc+{1'b0,Divisor};
            end
        end else begin
            if (!Acc[32]) begin
                New_Acc= Shift_Acc-{1'b0,Divisor};
            end else begin
                New_Acc= Shift_Acc+{1'b0,Divisor};
            end
        end
    end
    
//AQ shifting
always @(*)begin
        if(busy)
            {Shift_Acc, Shift_Q} <= {Acc, Q} << 1;
        else
            {Shift_Acc, Shift_Q} <= {33'h0, 32'h0};
    end

//non restoring algorithm
    always @(posedge clk or posedge div_rst)begin
        if(div_rst) begin
            {Acc, Q} <= {33'h0, 32'h0};

        end else if(count==0) begin /////////////////check
            {Acc, Q} <= {33'h0, Op1_div};
        end

        else if(count==6'd32) begin
            {Acc, Q} <= (Acc[32])? {New_Acc,Q}:{Acc, Q};
        end

        else if(busy) begin
            {Acc, Q} <= {New_Acc, Shift_Q[31:1], !(New_Acc[32])};

        end else begin
            {Acc, Q} <= {Acc, Q};
        end
    end

//////////remainder////////
always @(*) begin
    case (funct3)
        3'b110: begin 
            if (Acc[32]) begin
                remainder = Acc[31:0] + Divisor;
            end else begin
                remainder = Acc[31:0];
            end

            if (Op1[31]) begin
                remainder = -remainder;
            end
        end

        3'b111: begin 
            if (Acc[32]) begin
                remainder = Acc[31:0] + Divisor;
            end else begin
                remainder = Acc[31:0];
            end
        end

        default : remainder=0;
    endcase
end
///////HANDLING SIGNS////////
always @(*) begin
    if (Op2_div==0) begin
        div_result=32'hffffffff;
    end else begin
    case (funct3)
        3'b100,3'b110: begin
            if (Op1[31]^Op2[31]) begin
                div_result=-Q;
            end else begin
                div_result=Q;
            end 
        end
        default : div_result=Q;
    endcase
    end
end
    
        

always @(*) begin
    case (funct3)
        3'b000,3'b001,3'b010,3'b011: begin 
            MULT_DIV_OUT=mult_result;
            if (mult_rst) begin
                mult_div_stall=0;
            end else if (!mult_done) begin
                mult_div_stall=1;
            end else begin
             mult_div_stall=0;
            end
        end
        3'b100,3'b101: begin 
            MULT_DIV_OUT=div_result;
            if (div_rst) begin
                mult_div_stall=0;
            end else if (!div_done) begin
                mult_div_stall=1;
            end else begin
             mult_div_stall=0;
            end
        end
        3'b110,3'b111: begin 
            MULT_DIV_OUT=remainder;
            if (div_rst) begin
                mult_div_stall=0;
            end else if (!div_done) begin
                mult_div_stall=1;
            end else begin
             mult_div_stall=0;
            end
        end
    endcase
end


endmodule

