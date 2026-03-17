module instruction_queue(
	input clk,rst,valid_i,busy_i,
	input [31:0] instruction_i,
	output reg [31:0] instruction_o,
	output reg valid_o
);

reg [31:0] instr_queue [0:31];
integer i;
reg [4:0] head,tail;

wire cnfg_instr;
assign cnfg_instr = instr_queue[head][6:0]==7'b1010111 && instr_queue[head][14:12] == 3'b111;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		for (i = 0; i < 32; i++) begin
			instr_queue[i] <= 32'd0;
		end
		tail<=0;
		head<=0;
	//	instruction_o <= 0;
	//	valid_o <= 0;
	end else begin
		if (valid_i) begin
			instr_queue[tail] <= instruction_i;
			if (tail==30) begin
				tail <= 0;
			end else begin
				tail <= tail + 1;
			end
		end

			if ((!busy_i && head!=tail) || cnfg_instr ) begin //if configuration matwa2afsh 3ady 3ashan mesh hated5ol el pipe
				if (head==30) begin
					head <= 0;
				end else begin
					head <= head+1'b1;
				end
			end
	end
end

always @(*) begin
	instruction_o = instr_queue[head];
	if (!busy_i && head!=tail || cnfg_instr) begin //if configuration matwa2afsh 3ady 3ashan mesh hated5ol el pipe
			valid_o = 1;
		end else if (head == tail && busy_i && instruction_o != instr_queue[head]) begin // last one is if the instruction already came out
			valid_o = 1;
		end else begin
			valid_o = 0;
		end
end

endmodule