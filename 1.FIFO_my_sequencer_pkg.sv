package my_sequencer_pkg;
	import FIFO_seq_item_pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

class MySequencer extends uvm_sequencer #(fifo_seq_item);
	`uvm_component_utils(MySequencer);

	function new(string name = "MySequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction

endclass 

endpackage 