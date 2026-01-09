//Radix 2 butterfly 

module R2#(
	parameter int DATA_WIDTH, //bit width of data 
	parameter int F_in1_r, //fractional bits of real part of first input 
	parameter int F_in1_i, //fractional bits of imaginary part of first input
	parameter int F_in2_r, //fractional bits of real part of second input
	parameter int F_in2_i, //fractional bits of imaginary part of second input 
	
	parameter int F_a_r, //fractional bits of real part of addition 
	parameter int F_a_i, //fractional bits of imaginary part of addition
	parameter int F_s_r, //fractional bits of real part of subtraction
	parameter int F_s_i //fractional bits of imaginary part of subtraction
)(
	input wire signed  [DATA_WIDTH-1:0] in1_r, //real part of the first input 
	input wire signed [DATA_WIDTH-1:0] in1_i, //imaginary part of the first input 
	
	input wire signed [DATA_WIDTH-1:0] in2_r, //real part of the second input 
	input wire signed [DATA_WIDTH-1:0] in2_i, //imaginary part of the second input 
	
	output wire signed [DATA_WIDTH-1:0] out_add_r, //real part of the result of addition
	output wire signed [DATA_WIDTH-1:0] out_add_i, //imaginary part of the result of addition
	
	output wire signed [DATA_WIDTH-1:0] out_sub_r, //real part of the result of subtraction
	output wire signed [DATA_WIDTH-1:0] out_sub_i //imaginary part of the result of subtraction 
	
);
	///////// rounding real part ////////////////
	//pragma coverage off
	wire round_bit_in1_r = (F_in1_r > F_in2_r)? in1_r[F_in1_r - F_in2_r - 1] : 1'b0;
	wire signed [DATA_WIDTH:0] inc_in1_r = (round_bit_in1_r)? 1: 0;
	wire signed  [DATA_WIDTH-1:0] in1_r_e = (F_in1_r > F_in2_r)? (in1_r>>>(F_in1_r - F_in2_r)): in1_r;
	wire signed [DATA_WIDTH:0] in1_r_t = {{in1_r_e[DATA_WIDTH-1]},in1_r_e};
	wire signed [DATA_WIDTH:0] in1_r_temp = sat_add(in1_r_t, inc_in1_r,1'b0);
	
	wire round_bit_in2_r = (F_in2_r > F_in1_r)? in2_r[F_in2_r - F_in1_r - 1] : 1'b0;
	wire signed [DATA_WIDTH:0] inc_in2_r = (round_bit_in2_r)? 1: 0;
	wire signed  [DATA_WIDTH-1:0] in2_r_e = (F_in2_r > F_in1_r)? (in2_r>>>(F_in2_r - F_in1_r)): in2_r;
	wire signed [DATA_WIDTH:0] in2_r_t = {{in2_r_e[DATA_WIDTH-1]},in2_r_e};
	wire signed [DATA_WIDTH:0] in2_r_temp = sat_add(in2_r_t, inc_in2_r,1'b0);
	
	localparam NEW_F_R = (F_in1_r > F_in2_r)?F_in2_r:F_in1_r;
	
	///////// rounding imaginary part ////////////////
	wire round_bit_in1_i = (F_in1_i > F_in2_i)? in1_i[F_in1_i - F_in2_i - 1] : 1'b0;
	wire signed [DATA_WIDTH:0] inc_in1_i = (round_bit_in1_i)? 1: 0;
	wire signed [DATA_WIDTH-1:0] in1_i_e = (F_in1_i > F_in2_i)? (in1_i>>>(F_in1_i - F_in2_i)): in1_i;
	wire signed [DATA_WIDTH:0] in1_i_t = {{in1_i_e[DATA_WIDTH-1]},in1_i_e};
	wire signed [DATA_WIDTH:0] in1_i_temp = sat_add(in1_i_t, inc_in1_i,1'b0);
	
	wire round_bit_in2_i = (F_in2_i > F_in1_i)? in2_i[F_in2_i - F_in1_i - 1] : 1'b0;
	wire signed [DATA_WIDTH:0] inc_in2_i = (round_bit_in2_i)? 1: 0;
	wire signed [DATA_WIDTH-1:0] in2_i_e = (F_in2_i > F_in1_i)? (in2_i>>>(F_in2_i - F_in1_i)): in2_i;
	wire signed [DATA_WIDTH:0] in2_i_t = {{in2_i_e[DATA_WIDTH-1]},in2_i_e};
	wire signed [DATA_WIDTH:0] in2_i_temp = sat_add(in2_i_t, inc_in2_i,1'b0);
	
	localparam NEW_F_I = (F_in1_i > F_in2_i)?F_in2_i:F_in1_i;
	//pragma coverage on
	////////// butterfly addition real part /////////////////////
	wire signed [DATA_WIDTH:0] res_add_r = in1_r_temp + in2_r_temp;
	wire round_bit_a_r = (NEW_F_R > (F_a_r))? res_add_r[NEW_F_R- F_a_r - 1] : 1'b0;
	wire signed [DATA_WIDTH:0] inc_a_r = (round_bit_a_r)? 1: 0;
	wire signed [DATA_WIDTH:0] out_add_r_tmp = (NEW_F_R > F_a_r)? ( (res_add_r>>>(NEW_F_R - F_a_r))) : (res_add_r<<<(F_a_r-NEW_F_R));
	wire signed [DATA_WIDTH:0] res_add_r_rounded = sat_add(out_add_r_tmp, inc_a_r,1'b0);
	assign out_add_r = res_add_r_rounded[DATA_WIDTH - 1 :0];
	
	////////// butterfly addition imaginary part /////////////////////
	wire signed [DATA_WIDTH:0] res_add_i = in1_i_temp + in2_i_temp;	
	wire round_bit_a_i = (NEW_F_I > (F_a_i))? res_add_i[NEW_F_I- F_a_i - 1] : 1'b0;
	wire signed [DATA_WIDTH:0] inc_a_i = (round_bit_a_i)? 1: 0;
	wire signed [DATA_WIDTH:0] out_add_i_tmp = (NEW_F_I > F_a_i)? ( (res_add_i>>>(NEW_F_I - F_a_i))) : (res_add_i<<<(F_a_i-NEW_F_I));
	wire signed [DATA_WIDTH:0] res_add_i_rounded = sat_add(out_add_i_tmp, inc_a_i,1'b0);
	assign out_add_i = res_add_i_rounded[DATA_WIDTH - 1 :0];
	
	////////// butterfly subtraction real part //////////////////
	wire signed [DATA_WIDTH:0] res_sub_r = in1_r_temp - in2_r_temp;
	wire round_bit_s_r = (NEW_F_R > (F_s_r))? res_sub_r[NEW_F_R- F_s_r - 1] : 1'b0;
	wire signed [DATA_WIDTH:0] inc_s_r = (round_bit_s_r)? 1: 0;
	wire signed [DATA_WIDTH:0] out_sub_r_tmp = (NEW_F_R > F_s_r)? ( (res_sub_r>>>(NEW_F_R - F_s_r)) ) : (res_sub_r<<<(F_s_r-NEW_F_R));
	wire signed [DATA_WIDTH:0] res_sub_r_rounded = sat_add(out_sub_r_tmp,inc_s_r,1'b0);
	assign out_sub_r = res_sub_r_rounded[DATA_WIDTH - 1 :0];
	
	////////// butterfly subtraction imaginary part //////////////////
	wire signed [DATA_WIDTH:0] res_sub_i = in1_i_temp - in2_i_temp;
	wire round_bit_s_i = (NEW_F_I > (F_s_i))? res_sub_i[NEW_F_I- F_s_i - 1] : 1'b0;
	wire signed [DATA_WIDTH:0] inc_s_i = (round_bit_s_i)? 1: 0;
	wire signed [DATA_WIDTH:0] out_sub_i_tmp = (NEW_F_I > F_s_i)? ( (res_sub_i>>>(NEW_F_I - F_s_i)) ) : (res_sub_i<<<(F_s_i-NEW_F_I));
	wire signed [DATA_WIDTH:0] res_sub_i_rounded = sat_add(out_sub_i_tmp,inc_s_i,1'b0);
	assign out_sub_i = res_sub_i_rounded[DATA_WIDTH - 1:0];
	
	
	/// addition with saturation 
	function signed [DATA_WIDTH:0] sat_add;
		input signed [DATA_WIDTH:0] val_1;
		input signed [DATA_WIDTH:0] val_2;
		input ip_op; //0 indicates addition , 1 indicates subtraction
		
		logic signed [DATA_WIDTH:0] add_res;
		begin
			//pragma coverage off
			if(ip_op) begin
				add_res = val_1 - val_2;
			end
			else begin
				add_res = val_1 + val_2;	
			end
			//pragma coverage on
			sat_add = add_res;
			//pragma coverage off
			if(add_res[DATA_WIDTH] && (!add_res[DATA_WIDTH-1])) begin //clip to minimum value
				sat_add = {1'b1,1'b1, {(DATA_WIDTH-2){1'b0}}};
			end
			else if((!add_res[DATA_WIDTH]) && (add_res[DATA_WIDTH-1])) begin //clip to max value
				sat_add = {1'b0,1'b0, {(DATA_WIDTH-2){1'b1}}};
			end
			else begin
				sat_add = add_res;
			end
			//pragma coverage on
		end
		
	endfunction
endmodule