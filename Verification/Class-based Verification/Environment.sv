
`include "Generator.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "Scoreboard.sv"


class Environment;
	Generator g;
	Driver d;
	Monitor m;
	Scoreboard s;
	virtual fft_interface env_intf;

	function new();
		g = new();
		d = new();
		m = new();
		s = new();
	endfunction
	
	task run();
		d.driver_intf = env_intf;
		m.monitor_intf = env_intf;
		d.mb = g.mb;
		d.received = g.received;
		s.mb = m.mb;
		$display("Running back to back tests on FFT block ..." );
		fork
			s.run_scoreboard();
			m.monitor_sample();
			d.drive_stimulus();
			g.gen_stimulus();	
		join_any
		$fclose(g.in_r_id);
		$fclose(g.in_i_id);
		// wait 15 extra cycles for scoreboard to read all remaining outputs
		repeat(15) begin
			@(negedge env_intf.clk);
		end
		$fclose(s.out_r_id);
		$fclose(s.out_i_id);
		$display("TESTS PASSED = %0d",s.tests_passed );
		$display("TESTS FAILED = %0d",s.tests_failed );
		$stop;
	endtask

endclass