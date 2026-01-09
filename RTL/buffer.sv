//shift register of parametrised size 

module buffer#(
	parameter DATA_WIDTH = 12, //length of data in buffer
	parameter M = 8 //depth of buffer, how many registers it contains
	
)(
	input wire clk, //clock signal 
	input wire rst_n, //active low asynchronous reset
	input wire stall, //freezes pipeline
	
	input wire signed [DATA_WIDTH-1:0] in_data_r, //real part of input data
	input wire signed [DATA_WIDTH-1:0] in_data_i, //imaginary part of input data
	input wire valid_in, //indicate if data input to buffer is valid 
	
	output wire valid_out, //indicate if output data from buffer is valid
	output wire signed [DATA_WIDTH-1:0] out_data_r, //real part of output data
	output wire signed [DATA_WIDTH-1:0] out_data_i //imaginary part of output data
);

	typedef struct packed {
		logic signed [DATA_WIDTH-1:0] data_r;
		logic signed [DATA_WIDTH-1:0] data_i;
		logic valid;
	} buffer_values_t;

	buffer_values_t q[0:M-1];


	always_ff@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			for(int i = 0;i<M;i=i+1) begin
				q[i] <= '{
					data_r:0,
					data_i:0, 
					valid:0
				};
				
			end
			
		end
		else if(!stall) begin
			q[0] <= '{
					data_r:in_data_r,
					data_i:in_data_i, 
					valid:valid_in
				};
			for(int i = 1;i<M;i=i+1) begin
				q[i] <= q[i-1];
			end
		end
	end
	assign valid_out = q[M-1].valid;
	assign out_data_r = q[M-1].data_r;
	assign out_data_i = q[M-1].data_i;
endmodule 