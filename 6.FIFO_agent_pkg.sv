package FIFO_agent_pkg;
	import my_sequencer_pkg::*;
	import FIFO_monitor_pkg::*;
	import FIFO_driver_pkg::*;
	import FIFO_config_pkg::*;
	import FIFO_seq_item_pkg::*;
	

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	class fifo_agent extends uvm_agent;
		`uvm_component_utils(fifo_agent)

		MySequencer sqr;
		fifo_driver drv;
		fifo_monitor mon;
		fifo_config_obj cfg;
		uvm_analysis_port #(fifo_seq_item) agt_port;

		function new(string name = "fifo_agent", uvm_component parent = null);
			super.new(name, parent);
		endfunction 


		function void build_phase(uvm_phase phase);
			sqr = MySequencer::type_id::create("sqr", this);
			mon = fifo_monitor::type_id::create("mon", this);
			drv = fifo_driver::type_id::create("drv", this);

			agt_port = new("agt_port", this);

			if (! uvm_config_db#(fifo_config_obj)::get(this, "", "CFG", cfg) )begin
				`uvm_fatal("build_phase", "Agent- Unable to get Configuration object :( ")
			end
		endfunction


		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			drv.fifo_vif   = cfg.fifo_config_vif;
			mon.if_vif_mon = cfg.fifo_config_vif;

			drv.seq_item_port.connect(sqr.seq_item_export);
			mon.mon_port.connect(agt_port);
			
		endfunction 


	endclass : fifo_agent
	
			
	

endpackage : FIFO_agent_pkg