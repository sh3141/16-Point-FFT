import transaction::*;
class Driver;
	event received;
	Transaction trans;
	virtual fft_interface driver_intf;
	mailbox mb;
	
	function new();
		mb = new();
		trans = new();
	endfunction
	
	task automatic drive_stimulus();
		forever begin
			@(negedge driver_intf.clk) ;
			recieve();
			driver_intf.x_r = trans.x_r;
			driver_intf.x_i = trans.x_r;
			driver_intf.rst_n = trans.rst_n;
			driver_intf.stall = trans.stall;
		end
	endtask;
	
	task automatic recieve();
		mb.get(trans); 
		->received; //signals to generator that driver received transaction
	endtask

endclass
