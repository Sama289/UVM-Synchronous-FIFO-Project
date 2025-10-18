package FIFO_monitor_pkg;
	import FIFO_seq_item_pkg::*;
	import FIFO_shared_pkg::*;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	class fifo_monitor extends uvm_monitor;
		`uvm_component_utils(fifo_monitor)

		fifo_seq_item rsp_seq_item;
		virtual FIFO_if if_vif_mon;
		uvm_analysis_port #(fifo_seq_item) mon_port;

		function new(string name = "fifo_monitor", uvm_component parent = null);
			super.new(name, parent);

		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			mon_port = new("mon_port", this);

		endfunction


		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				rsp_seq_item = 	fifo_seq_item::type_id::create("rsp_seq_item");
			@(negedge if_vif_mon.clk);

			//inputs
			rsp_seq_item.rst_n   = if_vif_mon.rst_n;
			rsp_seq_item.data_in = if_vif_mon.data_in;
			rsp_seq_item.wr_en   = if_vif_mon.wr_en;
		 	rsp_seq_item.rd_en   = if_vif_mon.rd_en; 
		 	rsp_seq_item.wr_ack  = if_vif_mon.wr_ack;

		 	//inputs
		 	rsp_seq_item.data_out     = if_vif_mon.data_out;
		 	rsp_seq_item.overflow     = if_vif_mon.overflow;
		 	rsp_seq_item.underflow    = if_vif_mon.underflow;
		 	rsp_seq_item.almostfull   = if_vif_mon.almostfull;
		 	rsp_seq_item.almostempty  = if_vif_mon.almostempty;
		 	rsp_seq_item.full         = if_vif_mon.full;
		 	rsp_seq_item.empty        = if_vif_mon.empty;
		 	

		 	mon_port.write(rsp_seq_item);
			end
			
		 	`uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH)

		endtask

	endclass : 	fifo_monitor



endpackage : FIFO_monitor_pkg