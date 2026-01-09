`define DATA_WIDTH 12 
interface fft_interface;
	
	logic clk;
	logic rst_n;
	logic stall;
	
	logic signed [`DATA_WIDTH - 1:0] x_r;
	logic signed [`DATA_WIDTH - 1:0] x_i;
	
	logic valid_out;
	logic signed [`DATA_WIDTH - 1:0] X_r;
	logic signed [`DATA_WIDTH - 1:0] X_i;
		
    modport dut (
        input clk, rst_n,stall,x_r,x_i,
        output valid_out, X_r, X_i
    );
endinterface