// complex 2-1 MUX 

module c_mux_2_1#(
	parameter DATA_WIDTH  //bit width of data 
)(
	input wire sel, //mux selector
	input wire signed [DATA_WIDTH-1:0] in0_r, //real part of first input 
	input wire signed [DATA_WIDTH-1:0] in0_i, //imaginary part of first input 
	
	input wire signed [DATA_WIDTH-1:0] in1_r, //real part of second input 
	input wire signed [DATA_WIDTH-1:0] in1_i, //imaginary part of second input 
	
	output wire signed [DATA_WIDTH-1:0] out_r, //real part of output 
	output wire signed [DATA_WIDTH-1:0] out_i  //imaginary part of output
);

	assign out_r = (sel) ? in1_r : in0_r;
	assign out_i = (sel) ? in1_i : in0_i;
endmodule 