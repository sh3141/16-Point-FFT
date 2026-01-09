`timescale 1ns/1ps

module rot_tb();
	//input signals 
	localparam DATA_WIDTH = 12;
	
	logic signed [DATA_WIDTH-1:0] ip_r_tb; //real part of the first input 
	logic signed [DATA_WIDTH-1:0] ip_i_tb; //imaginary part of the first input 	
	logic signed [DATA_WIDTH-1:0] w_r_tb; //real part of the second input 
	logic signed [DATA_WIDTH-1:0] w_i_tb; //imaginary part of the second input 
	
	//output signals
	wire signed [DATA_WIDTH-1:0] out_r_tb; 
	wire signed [DATA_WIDTH-1:0] out_i_tb; 

		
	//dut instantiation 
	localparam STAGE = 1;
	rotator #(.DATA_WIDTH(DATA_WIDTH), .F_in_r(DATA_WIDTH - STAGE - 2 ), .F_in_i(DATA_WIDTH - STAGE - 2), 
		.F_w_r(DATA_WIDTH - 2), .F_w_i(DATA_WIDTH - 2),.F_r(DATA_WIDTH - STAGE - 2), .F_i(DATA_WIDTH - STAGE - 2))  dut(.ip_r(ip_r_tb), .ip_i(ip_i_tb), .w_r(w_r_tb), .w_i(w_i_tb), .out_r(out_r_tb), .out_i(out_i_tb));
	
	//stimulus
	localparam TEST_CASES = 100;
	localparam DELAY = 10;
	
	localparam UNIT_TESTS_NO = 10;
	localparam NO_TESTS = 90 + UNIT_TESTS_NO;
	logic signed [DATA_WIDTH - 1 : 0] ip_r_mem [0 : NO_TESTS - 1]; 
	logic signed [DATA_WIDTH - 1 : 0] ip_i_mem [0 : NO_TESTS - 1]; 
	logic signed [DATA_WIDTH - 1 : 0] w_r_mem [0 : NO_TESTS - 1]; 
	logic signed [DATA_WIDTH - 1 : 0] w_i_mem [0 : NO_TESTS - 1]; 
	
	logic signed [DATA_WIDTH - 1 : 0] out_r_mem [0: NO_TESTS - 1]; 
	logic signed [DATA_WIDTH - 1 : 0] out_i_mem [0: NO_TESTS - 1];  
	
	initial begin
		$dumpfile("rot.vcd");
		$dumpvars;
		$readmemb("inp_r.txt",ip_r_mem);
		$readmemb("inp_i.txt",ip_i_mem);
		$readmemb("w_r.txt",w_r_mem);
		$readmemb("w_i.txt",w_i_mem);
		
		$readmemb("out_r.txt",out_r_mem);
		$readmemb("out_i.txt",out_i_mem);

	end
	integer tests_passed;
	integer tests_failed;
	initial begin
		tests_passed = 0;
		tests_failed = 0;
		for(int i=0;i<NO_TESTS; i++) begin
			ip_r_tb = ip_r_mem[i];
			ip_i_tb = ip_i_mem[i];
			w_r_tb = w_r_mem[i];
			w_i_tb = w_i_mem[i];
			#(DELAY);
			if(out_r_tb != out_r_mem[i] || out_i_tb != out_i_mem[i] ) begin
				tests_failed = tests_failed + 1;
				$display("for in =  %0h + (%0h)i , w = %0h + (%0h)i",ip_r_tb,ip_i_tb,w_r_tb,w_i_tb);
				$display("expected :  %0h + (%0h)i , found :  %0h + (%0h)i",out_r_mem[i],out_i_mem[i],out_r_tb,out_i_tb); 
			end
			else begin
				tests_passed = tests_passed + 1;
			end
		end
		$display("tests passed = %0d, tests failed = %0d",tests_passed, tests_failed);
		
		$stop;
	end
	
endmodule 