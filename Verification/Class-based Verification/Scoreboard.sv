import transaction::*;
class Scoreboard;
	parameter int DATA_WIDTH = 12;
	logic [DATA_WIDTH - 1:0] expected_r;
	logic [DATA_WIDTH - 1:0] expected_i;
	Transaction trans;
	mailbox mb;
	int tests_passed = 0;
	int tests_failed = 0;
	string fname_out_r = "D:/ADI_Internship/FFT/fft_test/expected_fixed_i.txt";
	string fname_out_i = "D:/ADI_Internship/FFT/fft_test/expected_fixed_i.txt";
	int out_r_id;
	int out_i_id;
	int out_r_read;
	int out_i_read;
	function new(); //scoreboard constructor
		mb = new();
		trans = new();
		out_r_id = $fopen(fname_out_r,"r");
		out_i_id = $fopen(fname_out_i,"r");
		if(out_r_id == 0 || out_i_id == 0) begin
			$display("Error could not read input files!");
			$stop;
		end
	endfunction
	
	task automatic run_scoreboard();
		forever begin
			mb.get(trans);
			if(trans.valid_out) begin
				out_r_read = $fscanf(out_r_id,"%h\n",expected_r);
				out_i_read = $fscanf(out_i_id,"%h\n",expected_i);
			end
			else begin
				expected_r = 0;
				expected_i = 0;
			end
			if(trans.X_r != expected_r || trans.X_i != expected_i) begin
				tests_failed = tests_failed + 1;
				$display("incorrect value, expected: %0h + (%0h)i , found: %0h + (%0h)i",expected_r, expected_i, trans.X_r, trans.X_i);
			end 
			else begin
				tests_passed = tests_passed + 1;
			end
		end
	endtask

endclass