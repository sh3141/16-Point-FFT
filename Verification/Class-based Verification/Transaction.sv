package transaction;
	class Transaction;
		parameter int DATA_WIDTH = 12;
		logic clk;
		logic rst_n;
		logic stall;
		
		logic signed [DATA_WIDTH - 1:0] x_r;
		logic signed [DATA_WIDTH - 1:0] x_i;
		
		logic valid_out;
		logic signed [DATA_WIDTH - 1:0] X_r;
		logic signed [DATA_WIDTH - 1:0] X_i;
			
		integer test_id; //test case
			
		function new();
		endfunction
	endclass
endpackage