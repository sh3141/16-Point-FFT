`include "Environment.sv"
module tb();
	
	Environment env;
	fft_interface intf();
	fft_block dut(.clk(intf.clk),
				  .rst_n(intf.rst_n),
				  .stall(intf.stall),
				  .x_r(intf.x_r),
				  .x_i(intf.x_i),
				  .valid_out(intf.valid_out),
				  .X_r(intf.X_r),
				  .X_i(intf.X_i)
	);
	
	//vcd file creation
	initial begin
		$dumpfile("fft_tb.vcd");
		$dumpvars;
	end
	
	//clk generation
	initial begin
		intf.clk = 1'b1;
	end
	always #5 intf.clk = ~intf.clk;
	
	//run testbenches
	initial begin
		env = new();
		env.env_intf = intf;
		env.run();
	end
endmodule