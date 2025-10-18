package FIFO_test_pkg;
	import FIFO_config_pkg::*;
	import FIFO_env_pkg::*;
	import reset_sequences_pkg::*;
	import write_sequences_pkg::*;
	import FIFO_shared_pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	class fifo_test extends uvm_test;
		`uvm_component_utils(fifo_test)

		fifo_env env;
		virtual fifo_if fifo_test_vif;
		fifo_config_obj fifo_config_obj_test;
		fifo_write_seq wr_seq;
		fifo_reset_seq reset_seq;
		fifo_read_seq  rd_seq;
		fifo_write_read_seq rd_wr_seq;


		function new(string name = "fifo_test", uvm_component parent =null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			env = fifo_env::type_id::create("env",this);
			fifo_config_obj_test = fifo_config_obj::type_id::create("fifo_config_obj_test");
			reset_seq = fifo_reset_seq::type_id::create("reset_seq",this);
			wr_seq = fifo_write_seq::type_id::create("wr_seq",this);
			rd_seq = fifo_read_seq::type_id::create("rd_seq",this);
			rd_wr_seq = fifo_write_read_seq::type_id::create("rd_wr_seq",this);


			if (!uvm_config_db#(virtual FIFO_if)::get(this, "", "fifo_if",fifo_config_obj_test.fifo_config_vif ))

			`uvm_fatal("build_phase","Test - unable to get the virtual interface of fifo from the uvm_config_db")

			uvm_config_db#(fifo_config_obj)::set(this, "*", "CFG", fifo_config_obj_test);

		endfunction


		task run_phase(uvm_phase phase);
			super.run_phase(phase);

			phase.raise_objection(this);

			// --- 1:: reset TEST 1
			`uvm_info("run_phase","Reset Asserted", UVM_MEDIUM)
			reset_seq.start(env.agt.sqr);
			 
			`uvm_info("run_phase","Reset Deasserted", UVM_MEDIUM)

			//---2:: write TEST 2
			`uvm_info("run_phase","Stimulus Generation write sequence 2 Started", UVM_MEDIUM)
			wr_seq.start(env.agt.sqr);
			 
			`uvm_info("run_phase","Stimulus Generation write sequence 2 Ended", UVM_MEDIUM)

			//---3:: read TEST 3
			`uvm_info("run_phase","Stimulus Generation read sequence 3 Started", UVM_MEDIUM)
			rd_seq.start(env.agt.sqr);
			 
			`uvm_info("run_phase","Stimulus Generation read sequence 3 Ended", UVM_MEDIUM)

			//---4:: read TEST 4
			`uvm_info("run_phase","Stimulus Generation read after write sequence 4 Started", UVM_MEDIUM)
			rd_wr_seq.start(env.agt.sqr);
			 
			`uvm_info("run_phase","Stimulus Generation read after write sequence 4 Ended", UVM_MEDIUM)

			//---5:: reset TEST 5
			`uvm_info("run_phase","final :: Reset Asserted", UVM_MEDIUM)
			reset_seq.start(env.agt.sqr);
			 
			`uvm_info("run_phase","final :: Reset Deasserted", UVM_MEDIUM)

			phase.drop_objection(this);
			
		endtask

	endclass 
endpackage
