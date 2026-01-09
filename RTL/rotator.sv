//rotator carries complex multiplication with a twiddle factor of unit magnitude 
//parameters are set such that F_prod_r_1 == F_prod_r_2 and F_prod_i_1 == F_prod_i_2
module rotator #(
	parameter DATA_WIDTH, //bit width of data
	
	parameter F_in_r, //fractional bit width of real part of input data
	parameter F_in_i, //fractional bit width of imaginary part of input data
	
	parameter F_w_r, //fractional bit width of real part of the twiddle factor
	parameter F_w_i, //fractional bit width of the imaginary part of the twiddle factor
	
	parameter F_r, //fractional bit width of the real part of the result
	parameter F_i //fractional bit width of the imaginary part of the result 
)(
	input wire signed [DATA_WIDTH - 1:0] ip_r, //real part of input
	input wire signed [DATA_WIDTH - 1:0] ip_i,  //imaginary part of input
	input wire signed [DATA_WIDTH - 1:0] w_r, //real part of twiddle factor
	input wire signed [DATA_WIDTH - 1:0] w_i, //imaginary part of twiddle factor
	
	output wire signed [DATA_WIDTH - 1:0] out_r, //real part of output
	output wire signed [DATA_WIDTH - 1:0] out_i //imaginary part of output 
	
);
	wire signed [2*DATA_WIDTH:0] prod_r_1; //stores ip_r*w_r
	
	wire signed [2*DATA_WIDTH:0] prod_r_2; //stores ip_i*w_i
	
	wire signed [2*DATA_WIDTH:0] prod_i_1; //stores ip_i*w_r
	
	wire signed [2*DATA_WIDTH:0] prod_i_2; //stores ip_r*w_i
	
	////computing real part: 
	localparam F_prod_r_1 = F_in_r + F_w_r; //fractional bits of prod_r_1
	localparam F_prod_r_2 = F_in_i + F_w_i; //fractional bits of prod_r_2
	
	localparam F_out_r = (F_prod_r_1 < F_prod_r_2)? F_prod_r_1: F_prod_r_2;
	//MAX and MIN valus:
	localparam signed [2*DATA_WIDTH:0] MAX_VAL = $signed((1<<<(DATA_WIDTH-1))-1);
	localparam signed [2*DATA_WIDTH:0] MIN_VAL = -$signed((1<<<(DATA_WIDTH-1)));
	//rounding prod_r_1
	assign prod_r_1 = $signed(ip_r)*$signed(w_r);
	/*wire round_prod_r_1 = (F_prod_r_1 > F_out_r) ? prod_r_1[F_prod_r_1 - F_out_r - 1] : 1'b0;
	wire signed [2*DATA_WIDTH : 0] inc_prod_r_1 = (round_prod_r_1) ? $signed(1) : $signed(0);
	wire signed [2*DATA_WIDTH:0] prod_r_1_shifted = prod_r_1>>>(F_prod_r_1 - F_out_r);	
	wire signed [2*DATA_WIDTH:0] prod_r_1_t = sat_add(prod_r_1_shifted, inc_prod_r_1,MAX_VAL,MIN_VAL,1'b0);
	*/
	
	//rounding prod_r_2
	assign prod_r_2 = $signed(ip_i)*$signed(w_i);
	/*wire round_prod_r_2 = (F_prod_r_2 > F_out_r) ? prod_r_2[F_prod_r_2 - F_out_r - 1] : 1'b0;
	wire signed [2*DATA_WIDTH : 0] inc_prod_r_2 = (round_prod_r_2) ? $signed(1) : $signed(0);
	wire signed [2*DATA_WIDTH:0] prod_r_2_shifted = prod_r_2>>>(F_prod_r_2 - F_out_r);	
	wire signed [2*DATA_WIDTH:0] prod_r_2_t = sat_add(prod_r_2_shifted, inc_prod_r_2,MAX_VAL,MIN_VAL,1'b0);
	*/

	//// compute prod_r_1 - prod_r_2
	wire signed [2*DATA_WIDTH:0] res_r = prod_r_1 - prod_r_2; 
	wire round_res_r = (F_out_r > F_r)? res_r[F_out_r - F_r - 1] : 1'b0;
	wire signed [2*DATA_WIDTH:0] inc_res_r = (round_res_r)? $signed(1) : $signed(0);
	wire signed [2*DATA_WIDTH:0] res_r_shifted = (F_out_r > F_r) ? (res_r>>>(F_out_r - F_r)) : res_r<<<(F_r - F_out_r) ;
	wire signed [2*DATA_WIDTH:0] res_r_t = sat_add(res_r_shifted,inc_res_r,MAX_VAL,MIN_VAL,1'b0 );
	assign out_r = res_r_t[DATA_WIDTH - 1:0];
	
	//computing imaginary part
	localparam F_prod_i_1 = F_in_r + F_w_i; //fractional bits of prod_i_1
	localparam F_prod_i_2 = F_in_i + F_w_r; //fractional bits of prod_i_2
	
	localparam F_out_i = (F_prod_i_1 < F_prod_i_2)? F_prod_i_1: F_prod_i_2;
	
	//rounding prod_i_1
	assign prod_i_1 = $signed(ip_r)*$signed(w_i);
	//wire round_prod_i_1 = (F_prod_i_1 > F_out_i) ? prod_i_1[F_prod_i_1 - F_out_i - 1] : 1'b0;
	//wire signed [2*DATA_WIDTH : 0] inc_prod_i_1 = (round_prod_i_1) ? $signed(1) : $signed(0);
	//wire signed [2*DATA_WIDTH:0] prod_i_1_shifted = prod_i_1>>>(F_prod_i_1 - F_out_i);
	//wire signed [2*DATA_WIDTH:0] prod_i_1_t = sat_add(prod_i_1_shifted, inc_prod_i_1,MAX_VAL,MIN_VAL,1'b0);
	
	//rounding prod_i_2
	assign prod_i_2 = $signed(ip_i)*$signed(w_r);	
	//wire round_prod_i_2 = (F_prod_i_2 > F_out_i) ? prod_i_2[F_prod_i_2 - F_out_i - 1] : 1'b0;
	//wire signed [2*DATA_WIDTH : 0] inc_prod_i_2 = (round_prod_i_2) ? $signed(1) : $signed(0);
	//wire signed [2*DATA_WIDTH:0] prod_i_2_shifted = prod_i_2>>>(F_prod_i_2 - F_out_i);
	//wire signed [2*DATA_WIDTH:0] prod_i_2_t = sat_add(prod_i_2_shifted, inc_prod_i_2,MAX_VAL,MIN_VAL,1'b0);
	
	// compute prod_i_1 + prod_i_2
	wire signed [2*DATA_WIDTH:0] res_i = prod_i_1 + prod_i_2; 
	wire round_res_i = (F_out_i > F_i)? res_i[F_out_i - F_i - 1] : 1'b0;
	wire signed [2*DATA_WIDTH:0] inc_res_i = (round_res_i)? $signed(1) : $signed(0);
	wire signed [2*DATA_WIDTH:0] res_i_shifted = (F_out_i > F_i) ? (res_i>>>(F_out_i - F_i)) : res_i<<<(F_i - F_out_i) ;
	wire signed [2*DATA_WIDTH:0] res_i_t = sat_add(res_i_shifted,inc_res_i,MAX_VAL,MIN_VAL,1'b0 );
	assign out_i = res_i_t[DATA_WIDTH - 1:0];
	
	
	/// addition with saturation 
	function signed [2*DATA_WIDTH:0] sat_add;
		input signed [2*DATA_WIDTH:0] val_1;
		input signed [2*DATA_WIDTH:0] val_2;
		input signed [2*DATA_WIDTH:0] max_val;
		input signed [2*DATA_WIDTH:0] min_val;
		input ip_op; //0 indicates addition , 1 indicates subtraction
		
		logic signed [2*DATA_WIDTH:0] add_res;
		begin
			//pragma coverage off
			if(ip_op) begin
				add_res = val_1 - val_2;
			end
			else begin
				add_res = val_1 + val_2;	
			end
			sat_add = add_res;
			if(add_res < min_val ) begin //clip to minimum value
				sat_add = min_val;
			end
			else if(add_res > max_val) begin //clip to max value
				sat_add = max_val;
			end
			else begin
				sat_add = add_res;
			end
			//pragma coverage on
		end
		
	endfunction
	
endmodule 