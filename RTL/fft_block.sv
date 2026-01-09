//16 point DIF implementation of FFT

//latency = 15 clock cycles 
module fft_block#(
	parameter int DATA_WIDTH = 12, //width of data 
	parameter int F_ip_r = 10, //fractional bits of real part of input 
	parameter int F_ip_i = 10 //fractional bits of imaginary part of input 
)(
	input wire clk, //clock signal
	input wire rst_n, //active low reset
	input wire stall, //freeze fft pipeline
	
	input wire [DATA_WIDTH - 1:0] x_r, //real part of input
	input wire [DATA_WIDTH - 1:0] x_i, //imaginary part of input 
	
	output logic valid_out, //indicate output of FFT is valid. 
	output logic [DATA_WIDTH - 1:0] X_r, //real part of output
	output logic [DATA_WIDTH - 1:0] X_i //imaginary part of output 
);
	// fractional bits for each stage butterfly 
	//twiddle factors 
	localparam F_w_r = DATA_WIDTH - 2;
	localparam F_w_i = DATA_WIDTH - 2; 
	//stage 0:
	localparam F_a_r_0 = DATA_WIDTH - 3;
	localparam F_a_i_0 = DATA_WIDTH - 3;
	localparam F_s_r_0 = DATA_WIDTH - 3;
	localparam F_s_i_0 = DATA_WIDTH - 3;
	
	//stage 1:
	localparam F_rot_r_1 = DATA_WIDTH - 3;
	localparam F_rot_i_1 = DATA_WIDTH - 3;
	
	localparam F_s_r_1 = DATA_WIDTH - 4;
	localparam F_s_i_1 = DATA_WIDTH - 4;
	
	//stage 2:
	localparam F_rot_r_2 = DATA_WIDTH - 4;
	localparam F_rot_i_2 = DATA_WIDTH - 4;
	localparam F_s_r_2 =  DATA_WIDTH - 5;
	localparam F_s_i_2 = DATA_WIDTH - 5;
	
	//stage 3:
	localparam F_rot_r_3 = DATA_WIDTH - 5;
	localparam F_rot_i_3 = DATA_WIDTH - 5;
	
	localparam F_a_r_3 = DATA_WIDTH - 6;
	localparam F_a_i_3 = DATA_WIDTH - 6;
	localparam F_s_r_3 = DATA_WIDTH - 6;
	localparam F_s_i_3 = DATA_WIDTH - 6;
	
	////// control signals ////////////////
	logic [3:0] counter;
	wire valid_in;
	wire sel_1; //controls muxes in stage 1
	wire sel_2; //controls muxes in stage 2
	wire sel_3; //controls muxes in stage 3
	logic stall_q; //indicates if current cycle pipeline is frozen
	always_ff@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			counter <= 0;
			stall_q <= 0;
		end
		else if(!stall) begin
			counter <= counter + 4'b1;
			stall_q <= 0;
		end
		else begin
			stall_q <= 1;
		end
	end
	assign valid_in = (rst_n)&&(!counter[3]);
	assign sel_1 = counter[2];
	assign sel_2 = counter[1];
	assign sel_3 = counter[0];
	////////// twiddle factors //////////////
	wire [DATA_WIDTH - 1:0] W_r_1; //real part of twiddle factor for stage 1 
	wire [DATA_WIDTH - 1:0] W_i_1; //imaginary part of twiddle factor for stage 1 
	wire [DATA_WIDTH - 1:0] W_r_2; //real part of twiddle factor for stage 2 
	wire [DATA_WIDTH - 1:0] W_i_2; //imaginary part of twiddle factor for stage 2
	
	twiddle_lookup #(.DATA_WIDTH(DATA_WIDTH), .N(3)) twid_table(.sel(counter[2:0]), .W_r_1(W_r_1), .W_i_1(W_i_1), .W_r_2(W_r_2), .W_i_2(W_i_2) );
	
	////////// stage 0 /////////////////////
	wire [DATA_WIDTH - 1:0] x_r_delayed_8;
	wire [DATA_WIDTH - 1:0] x_i_delayed_8;
	
	wire valid_out_0; 
	
	buffer #(.DATA_WIDTH(DATA_WIDTH), .M(8)) buf_8(.clk(clk), .rst_n(rst_n), .stall(stall), .in_data_r(x_r), .in_data_i(x_i), 
	.valid_in(valid_in), .valid_out(valid_out_0), .out_data_r(x_r_delayed_8), .out_data_i(x_i_delayed_8) );
	
	wire [DATA_WIDTH - 1:0] x_e0_r ;
	wire [DATA_WIDTH - 1:0] x_e0_i ;
	wire [DATA_WIDTH - 1:0] x_o0_r ;
	wire [DATA_WIDTH - 1:0] x_o0_i ;
	
	R2 #(.DATA_WIDTH(DATA_WIDTH), .F_in1_r(F_ip_r), .F_in1_i(F_ip_i), .F_in2_r(F_ip_r), .F_in2_i(F_ip_i), .F_a_r(F_rot_r_1), .F_a_i(F_rot_i_1), .F_s_r(F_s_r_0),.F_s_i(F_s_i_0) ) 
		r2_0(.in1_r(x_r_delayed_8),.in1_i(x_i_delayed_8), .in2_r(x_r), .in2_i(x_i), .out_add_r(x_e0_r), .out_add_i(x_e0_i), .out_sub_r(x_o0_r), .out_sub_i(x_o0_i) ); 
	
	////////// stage 1 /////////////////////
	wire [DATA_WIDTH - 1:0] rot_xo0_r;
	wire [DATA_WIDTH - 1:0] rot_xo0_i;
	rotator #(.DATA_WIDTH(DATA_WIDTH), .F_in_r(F_s_r_0), .F_in_i(F_s_i_0), .F_w_r(F_w_r), .F_w_i(F_w_i) ,
			  .F_r(F_rot_r_1) , .F_i(F_rot_i_1) ) rot_1(.ip_r(x_o0_r), .ip_i(x_o0_i), .w_r(W_r_1), .w_i(W_i_1), .out_r(rot_xo0_r), .out_i(rot_xo0_i));
	
	wire [DATA_WIDTH - 1:0] rot_xo0_r_delayed_4;
	wire [DATA_WIDTH - 1:0] rot_xo0_i_delayed_4;
	wire valid_out_1_1; 
	
	buffer #(.DATA_WIDTH(DATA_WIDTH), .M(4)) buf_4_1(.clk(clk), .rst_n(rst_n), .stall(stall), .in_data_r(rot_xo0_r), .in_data_i(rot_xo0_i), 
			 .valid_in(valid_out_0), .valid_out(valid_out_1_1), .out_data_r(rot_xo0_r_delayed_4), .out_data_i(rot_xo0_i_delayed_4) );
	
	
	wire [DATA_WIDTH - 1:0] x_1_r0;
	wire [DATA_WIDTH - 1:0] x_1_i0;
	
	c_mux_2_1#(.DATA_WIDTH(DATA_WIDTH)) mux_1_0(.sel(sel_1), .in0_r(x_e0_r), .in0_i(x_e0_i), .in1_r(rot_xo0_r_delayed_4),  .in1_i(rot_xo0_i_delayed_4), .out_r(x_1_r0), .out_i(x_1_i0) );
	
	wire [DATA_WIDTH - 1:0] x_1_r1;
	wire [DATA_WIDTH - 1:0] x_1_i1;
	
	c_mux_2_1#(.DATA_WIDTH(DATA_WIDTH)) mux_1_1(.sel(sel_1), .in0_r(rot_xo0_r_delayed_4), .in0_i(rot_xo0_i_delayed_4), .in1_r(x_e0_r), .in1_i(x_e0_i), .out_r(x_1_r1), .out_i(x_1_i1));
	
	wire [DATA_WIDTH - 1:0] x_1_r0_delayed_4;
	wire [DATA_WIDTH - 1:0] x_1_i0_delayed_4;
	wire valid_out_1_0; 
	
	buffer #(.DATA_WIDTH(DATA_WIDTH), .M(4)) buf_4_0(.clk(clk), .rst_n(rst_n), .stall(stall), .in_data_r(x_1_r0), .in_data_i(x_1_i0), 
	         .valid_in(valid_out_0), .valid_out(valid_out_1_0), .out_data_r(x_1_r0_delayed_4), .out_data_i(x_1_i0_delayed_4) );
	
	wire [DATA_WIDTH - 1:0] x_e1_r;
	wire [DATA_WIDTH - 1:0] x_e1_i;
	wire [DATA_WIDTH - 1:0] x_o1_r;
	wire [DATA_WIDTH - 1:0] x_o1_i;
	
	
	R2 #(.DATA_WIDTH(DATA_WIDTH), .F_in1_r(F_rot_r_1), .F_in1_i(F_rot_i_1), .F_in2_r(F_rot_r_1), .F_in2_i(F_rot_i_1), .F_a_r(F_rot_r_2), .F_a_i(F_rot_i_2), .F_s_r(F_s_r_1),.F_s_i(F_s_i_1) ) 
		r2_1(.in1_r(x_1_r0_delayed_4),.in1_i(x_1_i0_delayed_4), .in2_r(x_1_r1), .in2_i(x_1_i1), .out_add_r(x_e1_r), .out_add_i(x_e1_i), .out_sub_r(x_o1_r), .out_sub_i(x_o1_i) ); 
	
	////////// stage 2 /////////////////////
	wire [DATA_WIDTH - 1:0] rot_xo1_r;
	wire [DATA_WIDTH - 1:0] rot_xo1_i;
	rotator #(.DATA_WIDTH(DATA_WIDTH), .F_in_r(F_s_r_1), .F_in_i(F_s_i_1), .F_w_r(F_w_r), .F_w_i(F_w_i) ,
			  .F_r(F_rot_r_2) , .F_i(F_rot_i_2) ) rot_2(.ip_r(x_o1_r), .ip_i(x_o1_i), .w_r(W_r_2), .w_i(W_i_2), .out_r(rot_xo1_r), .out_i(rot_xo1_i));
	
	wire [DATA_WIDTH - 1:0] rot_xo1_r_delayed_2;
	wire [DATA_WIDTH - 1:0] rot_xo1_i_delayed_2;
	wire valid_out_2_1; 
	
	buffer #(.DATA_WIDTH(DATA_WIDTH), .M(2)) buf_2_1(.clk(clk), .rst_n(rst_n), .stall(stall), .in_data_r(rot_xo1_r), .in_data_i(rot_xo1_i), 
	         .valid_in(valid_out_1_0), .valid_out(valid_out_2_1), .out_data_r(rot_xo1_r_delayed_2), .out_data_i(rot_xo1_i_delayed_2) );
	
	wire [DATA_WIDTH - 1:0] x_2_r0;
	wire [DATA_WIDTH - 1:0] x_2_i0;
	
	c_mux_2_1#(.DATA_WIDTH(DATA_WIDTH)) mux_2_0(.sel(sel_2), .in0_r(x_e1_r), .in0_i(x_e1_i), .in1_r(rot_xo1_r_delayed_2),  .in1_i(rot_xo1_i_delayed_2), .out_r(x_2_r0), .out_i(x_2_i0) );
	
	wire [DATA_WIDTH - 1:0] x_2_r1;
	wire [DATA_WIDTH - 1:0] x_2_i1;
	
	c_mux_2_1#(.DATA_WIDTH(DATA_WIDTH)) mux_2_1(.sel(sel_2), .in0_r(rot_xo1_r_delayed_2), .in0_i(rot_xo1_i_delayed_2), .in1_r(x_e1_r), .in1_i(x_e1_i), .out_r(x_2_r1), .out_i(x_2_i1));
	
	wire [DATA_WIDTH - 1:0] x_2_r0_delayed_2;
	wire [DATA_WIDTH - 1:0] x_2_i0_delayed_2;
	wire valid_out_2_0; 
	
	buffer #(.DATA_WIDTH(DATA_WIDTH), .M(2)) buf_2_0(.clk(clk), .rst_n(rst_n), .stall(stall), .in_data_r(x_2_r0), .in_data_i(x_2_i0), 
			 .valid_in(valid_out_1_0), .valid_out(valid_out_2_0), .out_data_r(x_2_r0_delayed_2), .out_data_i(x_2_i0_delayed_2) );
			 
	wire [DATA_WIDTH - 1:0] x_e2_r;
	wire [DATA_WIDTH - 1:0] x_e2_i;
	wire [DATA_WIDTH - 1:0] x_o2_r;
	wire [DATA_WIDTH - 1:0] x_o2_i;
	
	
	R2 #(.DATA_WIDTH(DATA_WIDTH), .F_in1_r(F_rot_r_2), .F_in1_i(F_rot_i_2), .F_in2_r(F_rot_r_2), .F_in2_i(F_rot_i_2), .F_a_r(F_rot_r_3), .F_a_i(F_rot_i_3), .F_s_r(F_s_r_2),.F_s_i(F_s_i_2) ) 
		r2_2(.in1_r(x_2_r0_delayed_2),.in1_i(x_2_i0_delayed_2), .in2_r(x_2_r1), .in2_i(x_2_i1), .out_add_r(x_e2_r), .out_add_i(x_e2_i), .out_sub_r(x_o2_r), .out_sub_i(x_o2_i) ); 
	
	////////// stage 3 /////////////////////
	wire [DATA_WIDTH - 1:0] rot_xo2_r;
	wire [DATA_WIDTH - 1:0] rot_xo2_i;
	trivial_rotator #(.DATA_WIDTH(DATA_WIDTH)) t_rot_3( .ip_r(x_o2_r), .ip_im(x_o2_i), .flip(sel_3), .out_r(rot_xo2_r), .out_i(rot_xo2_i) );
	
	wire [DATA_WIDTH - 1:0] rot_xo2_r_delayed_1;
	wire [DATA_WIDTH - 1:0] rot_xo2_i_delayed_1;
	wire valid_out_3_1; 
	
	buffer #(.DATA_WIDTH(DATA_WIDTH), .M(1)) buf_1_1(.clk(clk), .rst_n(rst_n), .stall(stall), .in_data_r(rot_xo2_r), .in_data_i(rot_xo2_i), 
	         .valid_in(valid_out_2_0), .valid_out(valid_out_3_1), .out_data_r(rot_xo2_r_delayed_1), .out_data_i(rot_xo2_i_delayed_1) );
	
	wire [DATA_WIDTH - 1:0] x_3_r0;
	wire [DATA_WIDTH - 1:0] x_3_i0;
	c_mux_2_1#(.DATA_WIDTH(DATA_WIDTH)) mux_3_0(.sel(sel_3), .in0_r(x_e2_r), .in0_i(x_e2_i), .in1_r(rot_xo2_r_delayed_1),  .in1_i(rot_xo2_i_delayed_1), .out_r(x_3_r0), .out_i(x_3_i0) );
	
	wire [DATA_WIDTH - 1:0] x_3_r1;
	wire [DATA_WIDTH - 1:0] x_3_i1;
	c_mux_2_1#(.DATA_WIDTH(DATA_WIDTH)) mux_3_1(.sel(sel_3), .in0_r(rot_xo2_r_delayed_1), .in0_i(rot_xo2_i_delayed_1), .in1_r(x_e2_r), .in1_i(x_e2_i), .out_r(x_3_r1), .out_i(x_3_i1));
			 
	wire [DATA_WIDTH - 1:0] x_3_r0_delayed_1;
	wire [DATA_WIDTH - 1:0] x_3_i0_delayed_1;
	wire valid_out_3_0; 
	
	buffer #(.DATA_WIDTH(DATA_WIDTH), .M(1)) buf_1_0(.clk(clk), .rst_n(rst_n), .stall(stall), .in_data_r(x_3_r0), .in_data_i(x_3_i0), 
			 .valid_in(valid_out_2_0), .valid_out(valid_out_3_0), .out_data_r(x_3_r0_delayed_1), .out_data_i(x_3_i0_delayed_1) );
			 
	wire [DATA_WIDTH - 1:0] x_e3_r;
	wire [DATA_WIDTH - 1:0] x_e3_i;
	wire [DATA_WIDTH - 1:0] x_o3_r;
	wire [DATA_WIDTH - 1:0] x_o3_i;
	
	
	R2 #(.DATA_WIDTH(DATA_WIDTH), .F_in1_r(F_rot_r_3), .F_in1_i(F_rot_i_3), .F_in2_r(F_rot_r_3), .F_in2_i(F_rot_i_3), .F_a_r(F_a_r_3), .F_a_i(F_a_i_3), .F_s_r(F_s_r_3),.F_s_i(F_s_i_3) ) 
		r2_3(.in1_r(x_3_r0_delayed_1),.in1_i(x_3_i0_delayed_1), .in2_r(x_3_r1), .in2_i(x_3_i1), .out_add_r(x_e3_r), .out_add_i(x_e3_i), .out_sub_r(x_o3_r), .out_sub_i(x_o3_i) ); 
	
	////////// stage 4 /////////////////////
	
	//serialise output 
	wire valid_out_4;
	wire [DATA_WIDTH - 1:0] x_o3_r_delayed_8;
	wire [DATA_WIDTH - 1:0] x_o3_i_delayed_8;
	
	buffer #(.DATA_WIDTH(DATA_WIDTH), .M(8)) buf_8_out(.clk(clk), .rst_n(rst_n), .stall(stall), .in_data_r(x_o3_r), .in_data_i(x_o3_i), 
			 .valid_in(valid_out_3_0), .valid_out(valid_out_4), .out_data_r(x_o3_r_delayed_8), .out_data_i(x_o3_i_delayed_8) );
	
	c_mux_2_1#(.DATA_WIDTH(DATA_WIDTH)) mux_out(.sel(valid_out_3_0), .in0_r(x_o3_r_delayed_8), .in0_i(x_o3_i_delayed_8), .in1_r(x_e3_r), .in1_i(x_e3_i), .out_r(X_r), .out_i(X_i));
	assign valid_out = (!stall_q) & (valid_out_3_0 | valid_out_4); 
endmodule 
