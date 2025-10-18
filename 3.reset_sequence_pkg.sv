package reset_sequences_pkg;
	import FIFO_shared_pkg::*;
	import my_sequencer_pkg::*;
	import FIFO_seq_item_pkg::*;
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"

 // ----------------Sequence 1 : RST ---------------------------

	class fifo_reset_seq extends uvm_sequence #(fifo_seq_item);
		`uvm_object_utils(fifo_reset_seq)
		fifo_seq_item seq_item;

		function new(string name = "fifo_reset_seq");
			super.new(name);

		endfunction

		task body;
			seq_item = fifo_seq_item::type_id::create("seq_item");
			start_item(seq_item);

				seq_item.rst_n    = 0; // activate the active low rst_n
				seq_item.data_in  = 0; // to reset the whole data_in bus (of size FIFO_WIDTH)
			 	seq_item.wr_en    = 0; 
			 	seq_item.rd_en    = 0;
			 	
			finish_item(seq_item);

		endtask : body
	endclass : fifo_reset_seq

 // ----------------Sequence 2 : write_only ---------------------------




 // ----------------Sequence 3 : Read_only ---------------------------

 	class fifo_read_seq extends uvm_sequence #(fifo_seq_item);
		`uvm_object_utils(fifo_read_seq)
		fifo_seq_item seq_item_rd;

		function new(string name = "fifo_read_seq");
			super.new(name);

		endfunction


		task body;
			`uvm_info("body","03 :: fifo_read_seq is started", UVM_MEDIUM);
			repeat(FIFO_WIDTH)begin
				seq_item_rd = fifo_seq_item::type_id::create("seq_item_rd");
				start_item(seq_item_rd);

					assert(seq_item_rd.randomize());
					seq_item_rd.rd_en = 1;
					seq_item_rd.wr_en = 0;
					seq_item_rd.rst_n = 1;

				finish_item(seq_item_rd);
			end
			`uvm_info("body","03 :: fifo_read_seq is ENDED", UVM_MEDIUM);

		endtask : body
		
	endclass : fifo_read_seq

 // ----------------Sequence 4 : write_read_sequence ---------------------------

 	 	class fifo_write_read_seq extends uvm_sequence #(fifo_seq_item);
		`uvm_object_utils(fifo_write_read_seq)
		fifo_seq_item seq_item_wr_rd;

		function new(string name = "fifo_write_read_seq");
			super.new(name);

		endfunction

		task body;
			`uvm_info("body","04 :: fifo_write_read_seq is started", UVM_MEDIUM);
			repeat(10000)begin
				seq_item_wr_rd = fifo_seq_item::type_id::create("seq_item_wr_rd");
				start_item(seq_item_wr_rd);
					assert(seq_item_wr_rd.randomize());
				finish_item(seq_item_wr_rd);
			end
			`uvm_info("body","04 :: fifo_write_read_seq is ENDED", UVM_MEDIUM);

		endtask : body
		
	endclass : fifo_write_read_seq


endpackage 