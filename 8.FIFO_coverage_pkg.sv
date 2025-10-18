package FIFO_coverage_pkg;
	import FIFO_seq_item_pkg::*;
	import FIFO_shared_pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	class fifo_coverage extends uvm_component;
	    `uvm_component_utils(fifo_coverage)

	    uvm_analysis_export #(fifo_seq_item) cov_export;
	    uvm_tlm_analysis_fifo #(fifo_seq_item) cov_fifo;
	    fifo_seq_item seq_item_cov;

	  //-------------------Coverage group---------------------------

	    covergroup cvr_gp();
			wr_en_cp      :	coverpoint seq_item_cov.wr_en;
			rd_en_cp      :	coverpoint seq_item_cov.rd_en;
			wr_ack_cp     :	coverpoint seq_item_cov.wr_ack;
			overflow_cp   :	coverpoint seq_item_cov.overflow;
			full_cp	      :	coverpoint seq_item_cov.full;
			empty_cp      :	coverpoint seq_item_cov.empty;
			almostfull_cp :	coverpoint seq_item_cov.almostfull;
			almostempty_cp: coverpoint seq_item_cov.almostempty;
			underflow_cp  :	coverpoint seq_item_cov.underflow;


			ack_cross: cross wr_en_cp, rd_en_cp, wr_ack_cp{
				ignore_bins case_011_bin = binsof(wr_en_cp) intersect {0} && binsof(wr_ack_cp) intersect {1};
				//should exclude case of wr_en_cp = 0 rd_en_cp = 1, wr_ack_cp = 1 for coverage "how could be the wr_ack=1, while wr_en not enabled!"
				ignore_bins case_001_bin = binsof(wr_en_cp) intersect {0} && binsof(rd_en_cp) intersect {0}  && binsof(wr_ack_cp) intersect {1};
				//should exclude case of wr_en_cp = 0 rd_en_cp = 0, wr_ack_cp = 1 for coverage "how could be the wr_ack = 1, while nethier wr_en nor read is enabled!"
			}
			full_cross : cross wr_en_cp, rd_en_cp, full_cp{
				ignore_bins read_full_bin = binsof(rd_en_cp) intersect {1} && binsof(full_cp) intersect {1};
				// As the full flag main function is when write enable on we check on if the fifo if full or not 
				// as it indicates that the FIFO is full. Write requests are ignored when the FIFO is full
				// initiating a write when the FIFO is full is not destructive to the contents of the FIFO


			}
			almostfull_cross  : cross wr_en_cp, rd_en_cp, almostfull_cp;
			empty_cross       : cross wr_en_cp, rd_en_cp, empty_cp;
			almostempty_cross : cross wr_en_cp, rd_en_cp, almostempty_cp;
			overflow_cross    : cross wr_en_cp, rd_en_cp, overflow_cp{
				ignore_bins write_with_overflow_bin = binsof(wr_en_cp) intersect {0} && binsof(overflow_cp) intersect {1};
				// As the overflow flag main function is when write enable on indicates that a write request (wr_en) was rejected
				// because the FIFO is full. Overflowing the FIFO is not destructive to the contents of the FIFO
			}
			underflow_cross   : cross wr_en_cp, rd_en_cp, underflow_cp{
				ignore_bins rd0und1 = binsof(rd_en_cp) intersect {0} && binsof(underflow_cp) intersect {1};
				// As the Underflow flag main function is Indicates that the read request(rd_en) was rejected 
				//because the FIFO is empty. Under flowing the FIFO is not destructive to the FIFO
			}

		endgroup 


		//Constructor
	    function new(string name = "fifo_coverage", uvm_component parent = null);
        	super.new(name,parent);
        	cvr_gp = new();
    	endfunction


    	//build
	    function void build_phase(uvm_phase phase);
	        super.build_phase(phase);
	        cov_export = new("cov_export",this);
	        cov_fifo = new("cov_fifo",this);
		endfunction


	    //connect
	    function void connect_phase(uvm_phase phase);
	        super.connect_phase(phase);
	        cov_export.connect(cov_fifo.analysis_export);
	    endfunction


	    //run
	    task run_phase(uvm_phase phase);
	        super.run_phase(phase);
	            forever begin
        			cov_fifo.get(seq_item_cov);
        			cvr_gp.sample();
        end
	    endtask


	endclass 

endpackage