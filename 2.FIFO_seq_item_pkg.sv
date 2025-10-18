package FIFO_seq_item_pkg;
	import FIFO_shared_pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	class fifo_seq_item extends uvm_sequence_item;
		`uvm_object_utils(fifo_seq_item)

		parameter FIFO_WIDTH = 16;
		parameter FIFO_DEPTH = 8;

		//Define items and add rand modifiers
			bit clk;
			
			rand logic [FIFO_WIDTH-1:0] data_in;
			rand logic  rst_n, wr_en, rd_en;
			logic [FIFO_WIDTH-1:0] data_out;
			logic wr_ack, overflow;
			logic full, empty, almostfull, almostempty, underflow;

		//constructor
			function new(string name = "fifo_seq_item");
				super.new(name);
			endfunction : new


		//functions convert to string --> Both inputs and Outputs
			function string convert2string();
				return $sformatf("%s :: data_in = %0b, rst_n = %0b, wr_en = %0b, rd_en = %0b, data_out = %0b, wr_ack = %0b, overflow = %0b, full = %0b, empty = %0b, almostfull = %0b, almostempty = %0b, underflow = %0b",
					super.convert2string(), data_in, rst_n , wr_en , rd_en , data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow);

			endfunction

		//Add convert2string_stimulus function --> for Inputs Only
        function string convert2string_stimulus();
            return $sformatf("data_in = %0b, rst_n = %0b, wr_en = %0b, rd_en = %0b ",
      			data_in, rst_n , wr_en , rd_en );

        endfunction


		//---------------------------CONSTRAINS----------------------------
			int RD_EN_ON_DIST = 30;
			int WR_EN_ON_DIST = 70;


			constraint rst_c {
				rst_n dist {0 := 10, 1 := 90};
			}

			constraint wr_en_c {
				wr_en dist {1 := WR_EN_ON_DIST, 0 := 100-WR_EN_ON_DIST};
			}

			constraint rd_en_c {
				rd_en dist {1 := RD_EN_ON_DIST, 0 := 100-RD_EN_ON_DIST};
			}

	endclass : fifo_seq_item


endpackage : FIFO_seq_item_pkg