module twiddle_lookup#(
	parameter DATA_WIDTH, //bit width of data 
	parameter N //half of the No of stages in the FFT 
)
(
	input wire [N-1:0] sel, //used to select certain twiddle factor for the complex multiplication
	
	output wire [DATA_WIDTH-1:0] W_r_1, //real part of the twiddle factor to the first stages
	output wire [DATA_WIDTH-1:0] W_i_1, //imaginary part of the twiddle factor to the first stage 
	
	output wire [DATA_WIDTH-1:0] W_r_2, //imaginary part of the twiddle factor to the second stage 
	output wire [DATA_WIDTH-1:0] W_i_2 //imaginary part of the twiddle factor to the second stage 
	
);
	localparam signed [DATA_WIDTH-1:0] W_r [(2**N)-1:0] = '{
		12'shC4E, 
		12'shD2C,
		12'shE78,
		12'sh000, 
		12'sh188,
		12'sh2D4, 
		12'sh3B2, 
		12'sh400
		  
	}; //real part of twiddle factor array 
	localparam signed [DATA_WIDTH-1:0] W_i [(2**N)-1:0] = '{
		12'shE78, 
		12'shD2C, 
		12'shC4E, 
		12'shC00,
		12'shC4E,
		12'shD2C, 
		12'shE78, 
		12'sh000
		 
	}; //imaginary part of twiddle factor array 
	
	
	assign W_r_1 = W_r[sel];
	assign W_i_1 = W_i[sel];
	
	assign W_r_2 = W_r[{sel[N-2:0],{1'b0}}];
	assign W_i_2 = W_i[{sel[N-2:0],{1'b0}}];
endmodule