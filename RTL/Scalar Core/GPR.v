module GPR (Address1,Address2,Address3,WD_A3,WR_EN,RD1,RD2,clk,reset); 

input [4:0] Address1,Address2,Address3;
input clk,reset,WR_EN;
input [31:0] WD_A3;
output reg [31:0] RD1,RD2;

integer i;
reg [31:0] register [0:31];

always@(posedge clk or posedge reset )begin
	if(reset) begin
		for (i = 0; i < 32; i = i + 1) begin
                register[i] <= 32'b0;
        end
	end
else if(WR_EN) begin
	if (Address3!=0) begin
		register[Address3] <= WD_A3;
	end
end else begin	
end
end

always @(negedge clk or posedge reset) begin
	if (reset) begin
	RD1 <= 0;	//Rs data = 0
	RD2 <= 0;	//Rt data = 0	
	end else begin
	RD1 <= register[Address1];  //Rs data 
	RD2 <= register[Address2];
	end
end
endmodule