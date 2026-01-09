import transaction::*;

class Generator;
	event received;
	mailbox mb;
	int TEST_CASES = 526*16 ;
	int N = 16; //no of points in FFT
	int RESET_DELAY = 2;
	Transaction trans;
	string fname_ip_r = "D:/ADI_Internship/FFT/fft_test/inputs_r.txt";
	string fname_ip_i = "D:/ADI_Internship/FFT/fft_test/inputs_i.txt";
	int in_r_id;
	int in_i_id;
	int in_r_read;
	int in_i_read;
	function new(); //generator constructor
		mb = new();
		trans = new();
		in_r_id = $fopen(fname_ip_r,"r");
		in_i_id = $fopen(fname_ip_i,"r");
		if(in_r_id == 0 || in_i_id == 0) begin
			$display("Error could not read input files!");
			$stop;
		end
	endfunction
	task automatic gen_stimulus(); //generate input stimiulus for dut
		for(int i=0;i<(TEST_CASES+RESET_DELAY);i++) begin
			trans.stall = 0;
			if(i<RESET_DELAY) begin
				trans.rst_n = 1'b0;
				trans.x_r = 0;
				trans.x_i = 0;	
			end
			else begin
				trans.rst_n = 1'b1;
				in_r_read = $fscanf(in_r_id,"%h\n",trans.x_r);
				in_i_read = $fscanf(in_i_id,"%h\n",trans.x_i);
			end
			trans.test_id = i;
			sending();
		end
	endtask
	
	task automatic sending();
		mb.put(trans);
		@(received) ; //wait for driver to recieve transaction before issuing the second one. 
	endtask
	
endclass