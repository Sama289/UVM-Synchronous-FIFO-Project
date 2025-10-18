package write_sequences_pkg;
	import FIFO_shared_pkg::*;
	import my_sequencer_pkg::*;
	import FIFO_seq_item_pkg::*;
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"

 // ----------------Sequence 1 : RST ---------------------------

	class fifo_write_seq extends uvm_sequence #(fifo_seq_item);
		`uvm_object_utils(fifo_write_seq)
		fifo_seq_item seq_item_wr;

		function new(string name = "fifo_write_seq");
			super.new(name);

		endfunction

		task body;
			`uvm_info("body","02 :: fifo_write_seq is started", UVM_MEDIUM);
			repeat(FIFO_WIDTH)begin
                `uvm_info("body","02 :: fifo_write_seq is started", UVM_MEDIUM);
				seq_item_wr = fifo_seq_item::type_id::create("seq_item_wr");
				start_item(seq_item_wr);

					assert(seq_item_wr.randomize());
					seq_item_wr.wr_en = 1;
					seq_item_wr.rd_en = 0;
					seq_item_wr.rst_n = 1;

				finish_item(seq_item_wr);

			end
			`uvm_info("body","02 :: fifo_write_seq is ENDED", UVM_MEDIUM);

		endtask : body

	endclass : fifo_write_seq
    endpackage