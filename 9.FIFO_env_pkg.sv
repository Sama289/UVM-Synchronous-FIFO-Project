package FIFO_env_pkg;
	import FIFO_driver_pkg::*;
	import uvm_pkg::* ;
	import FIFO_scoreboard_pkg::*;
	import FIFO_coverage_pkg::*;
	import FIFO_agent_pkg::*;
	import FIFO_shared_pkg::*;
	`include "uvm_macros.svh"

	class fifo_env extends uvm_env;
		`uvm_component_utils(fifo_env)
		 	
		fifo_scoreboard sb;
		fifo_coverage cov;
		fifo_agent agt;

		function new (string name = "fifo_env",uvm_component parent = null );
		 		super.new(name, parent);
		endfunction 

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			agt = fifo_agent::type_id::create("agt",this); 
			sb  = fifo_scoreboard::type_id::create("sb",this);
			cov = fifo_coverage::type_id::create("cov",this);
		endfunction 

		function void connect_phase(uvm_phase phase);
		 agt.agt_port.connect(sb.sb_export);
		 agt.agt_port.connect(cov.cov_export);
		endfunction

 	endclass 
endpackage 
