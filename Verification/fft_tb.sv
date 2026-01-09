`timescale 1ns/1ps

module fft_tb();
	//input signals 
	localparam DATA_WIDTH = 12;
	localparam F_ip_r = 10;
	localparam F_ip_i = 10;
	localparam N = 16; //no of points in FFT 
	
	logic clk_tb; //clock signal
	logic rst_n_tb; //active low reset
	logic stall_tb; //freeze fft pipeline
	
	logic [DATA_WIDTH - 1:0] x_r_tb; //real part of input
	logic [DATA_WIDTH - 1:0] x_i_tb; //imaginary part of input 
	
	//output signals
	wire valid_out_tb; //indicate output of FFT is valid. 
	wire signed [DATA_WIDTH - 1:0] X_r_tb; //real part of output
	wire signed [DATA_WIDTH - 1:0] X_i_tb;
	
	//input & output values memory 
	localparam UNIT_TESTS_NO = 28;
	localparam NO_TESTS = 500 + UNIT_TESTS_NO;
	logic [DATA_WIDTH - 1 : 0] ip_r_mem [0 : 16*NO_TESTS - 1]; //real part of input
	logic [DATA_WIDTH - 1 : 0] ip_i_mem [0 : 16*NO_TESTS - 1]; //imaginary part of input 
	logic [DATA_WIDTH - 1 : 0] out_fixed_r_mem [0: 16*NO_TESTS - 1]; //real part of output of fixed point MATLAB model
	logic [DATA_WIDTH - 1 : 0] out_fixed_i_mem [0: 16*NO_TESTS - 1];  //imaginary part of output of fixed point MATLAB model
	//logic [DATA_WIDTH - 1 : 0] out_double_r_mem [0: 16*NO_TESTS - 1];  //real part of output of double precision MATLAB model
	//logic [DATA_WIDTH - 1 : 0] out_double_i_mem [0: 16*NO_TESTS - 1]; //imaginary part of output of double precision MATLAB model 
	
	//initialisation
	int seed = 12345;           
	initial begin
		$dumpfile("fft.vcd");
		$dumpvars;	       
		void'($urandom(seed)); 
		rst_n_tb = 1'b0;
		stall_tb = 1'b0;
		x_r_tb = 0;
		x_i_tb = 0;
		$readmemh("inputs_r.txt",ip_r_mem);
		$readmemh("inputs_i.txt",ip_i_mem);
		$readmemh("expected_fixed_r.txt",out_fixed_r_mem);
		$readmemh("expected_fixed_i.txt",out_fixed_i_mem);
		//$readmemh("expected_double_r.txt",out_double_r_mem);
		//$readmemh("expected_double_i.txt",out_double_i_mem);
	end
	
	//clk generation
	localparam CLOCK_PERIOD = 10;
	
	initial begin
		clk_tb = 1'b0;
		forever begin
			#(CLOCK_PERIOD/2) clk_tb = ~clk_tb;
		end
	end
	//dut instantiation 
	fft_block#(.DATA_WIDTH(DATA_WIDTH), .F_ip_r(F_ip_r), .F_ip_i(F_ip_i) ) dut(.clk(clk_tb), .rst_n(rst_n_tb), .stall(stall_tb), .x_r(x_r_tb), 
		.x_i(x_i_tb), .valid_out(valid_out_tb), .X_r(X_r_tb), .X_i(X_i_tb) );
		
	//stimulus
	integer e;
	integer total_tests ;
	integer tests_passed ;
	integer tests_failed;
	integer tests_passed_b2b ;
	integer tests_failed_b2b;
	integer tests_passed_stall;
	integer tests_failed_stall;
	
	integer out_idx;
	integer recieved_frames;
	event monitor_done;
	integer in_idx;
	integer sent_frames;
	
	initial begin
		tests_passed = 0; 
		tests_failed = 0;
		tests_passed_b2b = 0;
		tests_failed_b2b = 0;
		tests_passed_stall = 0;
		tests_failed_stall = 0;
		
		#(2*CLOCK_PERIOD);
		rst_n_tb = 1'b1;
		total_tests = total_tests + 1;
		$display("Test functionality of fft");
		for (int i=0;i<NO_TESTS;i++) begin //test functionality of fft 
			rst_n_tb = 1'b0;
			#CLOCK_PERIOD;
			rst_n_tb = 1'b1;
			$display("start test %0d:",i);
			test_single_output(16*i,e);
			if(e) begin
				$display("test %0d passed",i);
				tests_passed = tests_passed + 1;
			end
			else begin
				$display("test %0d failed",i);
				tests_failed = tests_failed + 1;
			end
		end
		$display("tests passed = %0d, test failed = %0d", tests_passed, tests_failed); 
		$display("Test back to back fft");
		rst_n_tb = 1'b0;
		#CLOCK_PERIOD;
		rst_n_tb = 1'b1;
		test_back_to_back_fft();
		$display("for back to back FFT tests passed = %0d, test failed = %0d", tests_passed_b2b, tests_failed_b2b); 
		rst_n_tb = 1'b0;
		#CLOCK_PERIOD;
		rst_n_tb = 1'b1;
		$display("Test back to back fft with random stalls");
		test_back_to_back_fft_with_stalls();
		$display("for back to back FFT with stalls tests passed = %0d, test failed = %0d", tests_passed_stall, tests_failed_stall); 
		$stop;
	end
	
	task test_single_output(input integer j,output integer e);
		e = 1;
		for(int i = j; i<(N-1+j) ; i++) begin
			x_r_tb = ip_r_mem[i];
			x_i_tb = ip_i_mem[i];
			#(CLOCK_PERIOD);
		end
		x_r_tb = ip_r_mem[N-1+j];
		x_i_tb = ip_i_mem[N-1+j];
		if(!valid_out_tb) begin
			e = 0;
			$display("valid signal should be asserted HIGH and not LOW");
		end
		//fixed point comparison
		#(CLOCK_PERIOD*0.1);
		if(X_r_tb != out_fixed_r_mem[j] || X_i_tb != out_fixed_i_mem[j]) begin
			e = 0;
			$display("incorrect value at sample %0d, expected: %0h + (%0h)i , found: %0h + (%0h)i",0,out_fixed_r_mem[j],out_fixed_i_mem[j],X_r_tb, X_i_tb);
		end 
		
		#(CLOCK_PERIOD);
		for(int i = j+1; i<(N+j) ; i++) begin
			//fixed point comparison
			if(X_r_tb != out_fixed_r_mem[i] || X_i_tb != out_fixed_i_mem[i]) begin
				e = 0;
				$display("incorrect value at sample %0d, expected: %0h + (%0h)i , found: %0h + (%0h)i",i-j,out_fixed_r_mem[i],out_fixed_i_mem[i],X_r_tb, X_i_tb);
			end 
			#(CLOCK_PERIOD);
		end
		#(CLOCK_PERIOD*0.9);
	endtask

	task automatic test_back_to_back_fft();
		for(int i=0;i<NO_TESTS*16;i++) begin
			x_r_tb = ip_r_mem[i];
			x_i_tb = ip_i_mem[i];
			#(CLOCK_PERIOD*0.1);
			if(i < (N-1)) begin
				//pragma coverage off
				if(valid_out_tb) begin
					tests_failed_b2b = tests_failed_b2b + 1;
					$display("valid signal should be asserted LOW and not HIGH");
				end
				else if(X_r_tb != 0 || X_i_tb != 0) begin
					tests_failed_b2b = tests_failed_b2b + 1;
					$display("incorrect value at sample %0d, expected: %0h + (%0h)i , found: %0h + (%0h)i",i,0,0,X_r_tb, X_i_tb);
				end 
				//pragma coverage on
				else begin
					tests_passed_b2b = tests_passed_b2b + 1;
				end
			end
			else begin
				//pragma coverage off
				if(!valid_out_tb) begin
					tests_failed_b2b = tests_failed_b2b + 1;
					$display("valid signal should be asserted HIGH and not LOW");
				end
				else if(X_r_tb != out_fixed_r_mem[i - (N-1)] || X_i_tb != out_fixed_i_mem[i - (N-1)]) begin
					tests_failed_b2b = tests_failed_b2b + 1;
					$display("incorrect value at sample %0d, expected: %0h + (%0h)i , found: %0h + (%0h)i",(i%N),0,0,X_r_tb, X_i_tb);
				end 
				//pragma coverage on
				else begin
					tests_passed_b2b = tests_passed_b2b + 1;
				end
			end
			#(CLOCK_PERIOD*0.9);
		end
		#(CLOCK_PERIOD*0.1);
		for(int i=1;i<16;i++) begin
			#(CLOCK_PERIOD*0.1);
			if(!valid_out_tb) begin
				tests_failed_b2b = tests_failed_b2b + 1;
				$display("valid signal should be asserted HIGH and not LOW");
			end
			else if(X_r_tb != out_fixed_r_mem[NO_TESTS*16 - 1 + i - (N-1)] || X_i_tb != out_fixed_i_mem[NO_TESTS*16 - 1 + i - (N-1)]) begin
				tests_failed_b2b = tests_failed_b2b + 1;
				$display("incorrect value at sample %0d, expected: %0h + (%0h)i , found: %0h + (%0h)i",(i%N),0,0,X_r_tb, X_i_tb);
			end 
			else begin
				tests_passed_b2b = tests_passed_b2b + 1;
			end
			#(CLOCK_PERIOD*0.9);
		end	
	endtask
	int stall_len = $urandom_range(0, 8);
	int guard_count;
	int stall_status;
	int stall_status_prev;
	task automatic test_back_to_back_fft_with_stalls();
		guard_count = 10;
		stall_status = 0;
		stall_status_prev = 0;
		stall_len = 0;
		for(int i=0;i<NO_TESTS*16;) begin
			x_r_tb = ip_r_mem[i];
			x_i_tb = ip_i_mem[i];
			if(guard_count == 10)begin
				stall_len = $urandom_range(0, 8);
				guard_count = 0;
			end	
			else begin
				stall_len = 0;
				stall_tb = 1'b0;
				stall_status = 0;
				guard_count = guard_count + 1;
			end
			
			if(stall_len > 0) begin
				stall_tb = 1'b1;
				stall_len = stall_len - 1;
				stall_status = 1;
				guard_count = 0;
			end
			else begin
				stall_tb = 1'b0;
				stall_status = 0;
			end
			#(CLOCK_PERIOD*0.1);
			if(i < (N-1)) begin
				if(valid_out_tb) begin
					tests_failed_stall = tests_failed_stall + 1;
					$display("valid signal should be asserted LOW and not HIGH");
				end
				else if(X_r_tb != 0 || X_i_tb != 0) begin
					tests_failed_stall = tests_failed_stall + 1;
					$display("incorrect value at sample %0d, expected: %0h + (%0h)i , found: %0h + (%0h)i",i,0,0,X_r_tb, X_i_tb);
				end 
				else begin
					tests_passed_stall = tests_passed_stall + 1;
				end
			end
			else begin
				if(!valid_out_tb && !stall_status_prev) begin
					tests_failed_stall = tests_failed_stall + 1;
					$display("valid signal should be asserted HIGH and not LOW");
				end
				else if(valid_out_tb && stall_status_prev) begin
					tests_failed_stall = tests_failed_stall + 1;
					$display("valid signal should be asserted LOW during stall and not HIGH");
				end
				else if(X_r_tb != out_fixed_r_mem[i - (N-1)] || X_i_tb != out_fixed_i_mem[i - (N-1)]) begin
					tests_failed_stall = tests_failed_stall + 1;
					$display("incorrect value at sample %0d, expected: %0h + (%0h)i , found: %0h + (%0h)i",(i%N),0,0,X_r_tb, X_i_tb);
				end 
				else begin
					tests_passed_stall = tests_passed_stall + 1;
				end
			end
			#(CLOCK_PERIOD*0.9);
			if(!stall_status) begin
				i++;
			end
			stall_status_prev = stall_status;
		end
		for(int i=1;i<16;) begin
			if(guard_count == 10)begin
				stall_len = $urandom_range(0, 8);
				guard_count = 0;
			end	
			else begin
				stall_len = 0;
				stall_tb = 1'b0;
				stall_status = 0;
				guard_count = guard_count + 1;
			end
			
			if(stall_len > 0) begin
				stall_tb = 1'b1;
				stall_len = stall_len - 1;
				stall_status = 1;
				guard_count = 0;
			end
			else begin
				stall_tb = 1'b0;
				stall_status = 0;
			end
			#(CLOCK_PERIOD*0.1);
			if(!valid_out_tb && !stall_status_prev) begin
				tests_failed_stall = tests_failed_stall + 1;
				$display("valid signal should be asserted HIGH and not LOW");
			end
			else if(valid_out_tb && stall_status_prev) begin
				tests_failed_stall = tests_failed_stall + 1;
				$display("valid signal should be asserted LOW during stall and not HIGH");
			end
			else if(X_r_tb != out_fixed_r_mem[NO_TESTS*16 - 1 + i - (N-1)] || X_i_tb != out_fixed_i_mem[NO_TESTS*16 - 1 + i - (N-1)]) begin
				tests_failed_stall = tests_failed_stall + 1;
				$display("incorrect value at sample %0d, expected: %0h + (%0h)i , found: %0h + (%0h)i",(i%N),0,0,X_r_tb, X_i_tb);
			end 
			else begin
				tests_passed_stall = tests_passed_stall + 1;
			end
			#(CLOCK_PERIOD*0.9);
			if(!stall_status) begin
				i++;
			end
			stall_status_prev = stall_status;
		end
		
	endtask
	
	
endmodule 
