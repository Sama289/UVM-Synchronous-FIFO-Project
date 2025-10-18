import FIFO_test_pkg:: *;
import uvm_pkg::* ;
import FIFO_shared_pkg ::*;

`include "uvm_macros.svh"

module FIFO_TOP ();

	bit clk;

	//--------clock generation-------------
	initial begin 
	    clk = 0 ;
	    forever begin
	    	#10;
			clk = ~ clk;
	    end 
	end
 
	//--------instantiating interface-------------
	FIFO_if fifo_if (clk); // instantiate the interface

	//------------- DUT instantiation -------------
	FIFO DUT (fifo_if);    // Pass the instantiated interface to DUT
	bind FIFO fifo_sva fifo_sva_inst (fifo_if);


	//------------- Test running--------------------
    initial begin
        uvm_config_db #(virtual FIFO_if)::set(null, "uvm_test_top", "fifo_if", fifo_if);
        run_test("fifo_test");
    end

endmodule 




