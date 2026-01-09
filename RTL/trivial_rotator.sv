//handles trivial multiplication by 1 and -i by flipping the real and imaginary components of the complex number and multiply the real component by -1

module trivial_rotator #(
	parameter DATA_WIDTH //bit width of data 
) (
	input wire [DATA_WIDTH - 1:0] ip_r, //real part of input
	input wire [DATA_WIDTH - 1:0] ip_im, //imaginary part of input 
	input wire flip, //flip = 1 indicates mulitplication by -i otherwise indicates multiplication by 1
	
	output wire [DATA_WIDTH-1:0] out_r, //real part of output 
	output wire [DATA_WIDTH-1:0] out_i //imaginary part of output 
);
	assign out_r = (flip)? ip_im : ip_r;
	assign out_i = (flip)? ~(ip_r) + 1: ip_im;
endmodule 