package FIFO_config_pkg;
	import uvm_pkg::* ;
	`include "uvm_macros.svh"
		
	//configuration object to hold the virtual interface from the test to the driver
	class fifo_config_obj extends uvm_object;
		`uvm_object_utils(fifo_config_obj)

		virtual FIFO_if fifo_config_vif; //Inside this UVM object, we declare a virtual interface named fifo_config_vif.

		function new(string name = "fifo_config_obj");
			super.new(name);
		endfunction 

	endclass
endpackage