import transaction::*;
class Monitor;
	virtual fft_interface monitor_intf;
	mailbox mb;
	Transaction trans;
	function new();
		mb = new();
		trans = new();
	endfunction
	
	task automatic monitor_sample();
		@(posedge monitor_intf.clk);
		forever begin
			trans = new();
			@(posedge monitor_intf.clk);
			#3; 
			trans.x_r = monitor_intf.x_r;
			trans.x_i = monitor_intf.x_i;
			trans.stall = monitor_intf.stall;
			trans.rst_n = monitor_intf.rst_n;
			
			trans.valid_out = monitor_intf.valid_out;
			trans.X_r = monitor_intf.X_r;
			trans.X_i = monitor_intf.X_i;
			mb.put(trans);
		end
	endtask
endclass