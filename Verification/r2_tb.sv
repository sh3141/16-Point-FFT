`timescale 1ns/1ps

module r2_tb();
	//input signals 
	localparam DATA_WIDTH = 12;
	
	logic signed [DATA_WIDTH-1:0] in1_r_tb; //real part of the first input 
	logic signed [DATA_WIDTH-1:0] in1_i_tb; //imaginary part of the first input 	
	logic signed [DATA_WIDTH-1:0] in2_r_tb; //real part of the second input 
	logic signed [DATA_WIDTH-1:0] in2_i_tb; //imaginary part of the second input 
	
	//output signals
	wire signed [DATA_WIDTH-1:0] out_add_r_tb; //real part of the result of addition
	wire signed [DATA_WIDTH-1:0] out_add_i_tb; //imaginary part of the result of addition
	wire signed [DATA_WIDTH-1:0] out_sub_r_tb; //real part of the result of subtraction
	wire signed [DATA_WIDTH-1:0] out_sub_i_tb;
		
	//dut instantiation 
	localparam STAGE = 3;
	R2 #(.DATA_WIDTH(DATA_WIDTH), .F_in1_r(DATA_WIDTH - 2 - STAGE), .F_in1_i(DATA_WIDTH - 2 - STAGE), .F_in2_r(DATA_WIDTH - 2 - STAGE), .F_in2_i(DATA_WIDTH - 2 - STAGE),
		 .F_a_r(DATA_WIDTH - 3 - STAGE), .F_a_i(DATA_WIDTH - 3 - STAGE), .F_s_r(DATA_WIDTH - 3 - STAGE), .F_s_i(DATA_WIDTH - 3 - STAGE) ) dut(.in1_r(in1_r_tb), .in1_i(in1_i_tb), .in2_r(in2_r_tb), .in2_i(in2_i_tb),  
		.out_add_r(out_add_r_tb), .out_add_i(out_add_i_tb), .out_sub_r(out_sub_r_tb), .out_sub_i(out_sub_i_tb));
	
	//stimulus
	localparam TEST_CASES = 100;
	localparam DELAY = 10;
	logic signed [DATA_WIDTH-1:0] exp_a_r; 
	logic signed [DATA_WIDTH-1:0] exp_a_i;
	logic signed [DATA_WIDTH-1:0] exp_s_r; 
	logic signed [DATA_WIDTH-1:0] exp_s_i; 
	
	localparam UNIT_TESTS_NO = 10;
	localparam NO_TESTS = 30 + UNIT_TESTS_NO;
	logic signed [DATA_WIDTH - 1 : 0] ip1_r_mem [0 : 16*NO_TESTS - 1]; 
	logic signed [DATA_WIDTH - 1 : 0] ip1_i_mem [0 : 16*NO_TESTS - 1]; 
	logic signed [DATA_WIDTH - 1 : 0] ip2_r_mem [0 : 16*NO_TESTS - 1]; 
	logic signed [DATA_WIDTH - 1 : 0] ip2_i_mem [0 : 16*NO_TESTS - 1]; 
	
	logic signed [DATA_WIDTH - 1 : 0] out_a_r_mem [0: 16*NO_TESTS - 1]; 
	logic signed [DATA_WIDTH - 1 : 0] out_a_i_mem [0: 16*NO_TESTS - 1];  
	logic signed [DATA_WIDTH - 1 : 0] out_s_r_mem [0: 16*NO_TESTS - 1]; 
	logic signed [DATA_WIDTH - 1 : 0] out_s_i_mem [0: 16*NO_TESTS - 1];  
	
	initial begin
		$readmemb("inputs1_r.txt",ip1_r_mem);
		$readmemb("inputs1_i.txt",ip1_i_mem);
		$readmemb("inputs2_r.txt",ip2_r_mem);
		$readmemb("inputs2_i.txt",ip2_i_mem);
		
		$readmemb("out_a_r.txt",out_a_r_mem);
		$readmemb("out_a_i.txt",out_a_i_mem);
		$readmemb("out_s_r.txt",out_s_r_mem);
		$readmemb("out_s_i.txt",out_s_i_mem);
	end
	integer tests_passed;
	integer tests_failed;
	initial begin
		tests_passed = 0;
		tests_failed = 0;
		for(int i=0;i<NO_TESTS*16; i++) begin
			in1_r_tb = ip1_r_mem[i];
			in1_i_tb = ip1_i_mem[i];
			in2_r_tb = ip2_r_mem[i];
			in2_i_tb = ip2_i_mem[i];
			#(DELAY);
			if(out_add_r_tb != out_a_r_mem[i] || out_add_i_tb != out_a_i_mem[i] || out_sub_r_tb != out_s_r_mem[i] || out_sub_i_tb != out_s_i_mem[i] ) begin
				tests_failed = tests_failed + 1;
				$display("for in1 =  %0h + (%0h)i , in2 = %0h + (%0h)i",in1_r_tb,in1_i_tb,in2_r_tb,in2_i_tb);
				$display("expected + :  %0h + (%0h)i , -:%0h + (%0h)i, found + :  %0h + (%0h)i , -:%0h + (%0h)i",out_a_r_mem[i],out_a_i_mem[i],out_s_r_mem[i],out_s_i_mem[i],
							out_add_r_tb,out_add_i_tb,out_sub_r_tb,out_sub_i_tb); 
			end
			else begin
				tests_passed = tests_passed + 1;
			end
		end
		$display("tests passed = %0d, tests failed = %0d",tests_passed, tests_failed);
		
		$stop;
	end
	
endmodule 