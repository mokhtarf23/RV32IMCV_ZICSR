module RISCV_TB();

reg IRQ,clk,reset;
reg [31:0] Interrupt_Info;
reg m_software_interrupt;
reg m_external_interrupt;
reg m_timer_interrupt;

reg [31:0] sig_start [0:0];
integer sig_dump;
integer j;
reg [31:0] word;

RISCV CORE (
	.m_software_interrupt(m_software_interrupt),
	.m_external_interrupt(m_external_interrupt),
	.m_timer_interrupt(m_timer_interrupt),
	.clk           (clk),
	.reset         (reset)
	);


initial begin
	clk=1;
	forever begin
		#5 clk=~clk;
	end
end

initial begin
	reset=1;
	m_software_interrupt=0;
	m_timer_interrupt=0;
	m_external_interrupt=0;
	#10;
	reset=0;
	#1;
	$readmemh("/home/mokhtar/Desktop/Verilog/sig_start.txt",sig_start);
	$display("/home/mokhtar/Desktop/Verilog/sig_start=%h",sig_start[0]);
	for (integer i = 0; i < 2097151; i++) begin
		CORE.WB.Data_Memory.mem[i]=CORE.IF.memory.mem[i];
	end
	#400000;

///////////////SIGNATURE DUMPING//////////////////////////////
	sig_dump = $fopen("/home/mokhtar/Desktop/Verilog/DUT-CORE.signature", "w");
    if (sig_dump == 0) begin
      $display("Error: Could not open file for writing");
      $finish;
    end

  dump_loop: begin 
  	  for (j = sig_start[0]-4; j <= sig_start[0]+8000; j = j + 4) begin
      word = { CORE.WB.Data_Memory.mem[j+3], CORE.WB.Data_Memory.mem[j+2], CORE.WB.Data_Memory.mem[j+1], CORE.WB.Data_Memory.mem[j] };
      if (^word===1'bx) begin
      	disable dump_loop;
      end
      $fdisplay(sig_dump, "%08h", word);
    end
  end

    $fclose(sig_dump);
	$stop;
end

initial begin 
$readmemh("/home/mokhtar/Desktop/Verilog/code.hex",CORE.IF.memory.mem);
end 

endmodule