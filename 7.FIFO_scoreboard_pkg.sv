package FIFO_scoreboard_pkg;
	import FIFO_seq_item_pkg::*;
	import FIFO_shared_pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	class fifo_scoreboard extends uvm_scoreboard;
		`uvm_component_utils(fifo_scoreboard)

		uvm_analysis_port #(fifo_seq_item) sb_export;
		uvm_tlm_analysis_fifo #(fifo_seq_item) sb_fifo_port;
		fifo_seq_item item;

	 // Declare variables to hold ref_model values
        logic [FIFO_WIDTH-1:0] data_out_ref;
        static int correct_count =0;
		static int wrong_count =0;
		parameter FIFO_WIDTH = 16;
		logic wr_ack_ref, overflow_ref;
		logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;
		static integer error_count=0 , right_count=0 , size ;
		logic [FIFO_WIDTH-1:0] data_mem [$] ;
		bit next_write,next_read;

        // Error and correct counts
		
		function new(string name = "fifo_scoreboard", uvm_component parent = null);
			super.new(name, parent);
		endfunction 


		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sb_export = new("sb_export", this);
			sb_fifo_port = new("sb_fifo_port", this);

		endfunction


		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			sb_export.connect(sb_fifo_port.analysis_export);
			
		endfunction

	 // check the FIFO output against the reference model
		task run_phase (uvm_phase phase);
			super.run_phase(phase);
			forever begin 
				sb_fifo_port.get(item);
				check_data();

			end

		endtask 

		
	 //------------------Golden model------------------

	 	//implement the reference model using a queue

		task check_data ();
            reference_model();
            if (!item.rst_n) begin
                if (item.wr_ack!=wr_ack_ref || item.overflow!=overflow_ref || item.full != full_ref || item.empty != empty_ref || item.almostfull != almostfull_ref || item.almostempty != almostempty_ref) begin
                error_count=error_count+1;
                $display("error at reset");
                if (item.wr_ack!=wr_ack_ref) begin
                $display("wr_ack=%0b , wr_ack_ref=%0b at %0t",item.wr_ack,wr_ack_ref,$time);    
                end
                if (item.overflow!=overflow_ref) begin
                $display("overflow=%0b , overflow_ref=%0b at %0t",item.overflow,overflow_ref,$time);    
                end
                if (item.full!=full_ref) begin
                $display("full=%0b , full_ref=%0b at %0t",item.full,full_ref,$time);    
                end
                if (item.empty!=empty_ref) begin
                $display("empty=%0b , empty_ref=%0b at %0t",item.empty,empty_ref,$time);    
                end
                if (item.almostfull!=almostfull_ref) begin
                $display("full=%0b , full=%0b at %0t",item.full,full_ref,$time);    
                end
                if (item.almostempty!=almostempty_ref) begin
                $display("almostempty=%0b , almostempty_ref=%0b at %0t",item.almostempty,almostempty_ref,$time);    
                end
            end
            else begin
                right_count = right_count+1;
            end
            end
            else begin
                if (item.wr_ack!=wr_ack_ref || item.overflow!=overflow_ref || item.data_out!=data_out_ref || item.full != full_ref || item.empty != empty_ref || item.almostfull != almostfull_ref || item.almostempty != almostempty_ref) begin
                error_count=error_count+1;
                $display("error at no reset");
                if (item.wr_ack!=wr_ack_ref) begin
                $display("wr_ack=%0b , wr_ack_ref=%0b , size=%0d at %0t",item.wr_ack,wr_ack_ref,data_mem.size(),$time);    
                end
                if (item.overflow!=overflow_ref) begin
                $display("overflow=%0b , overflow_ref=%0b at %0t",item.overflow,overflow_ref,$time);    
                end
                if (item.data_out!=data_out_ref) begin
                $display("dataout=%0d , dataout_ref=%0d, size=%0d at %0t",item.data_out,data_out_ref,data_mem.size(),$time);    
                end
                if (item.full!=full_ref) begin
                $display("full=%0b , full_ref=%0b at %0t",item.full,full_ref,$time);    
                end
                if (item.empty!=empty_ref) begin
                $display("empty=%0b , empty_ref=%0b , size=%0d at %0t",item.empty,empty_ref,data_mem.size(),$time);    
                end
                if (item.almostfull!=almostfull_ref) begin
                $display("almostfull=%0b , almostfull_ref=%0b at %0t",item.almostfull,almostfull_ref,$time);    
                end
                if (item.almostempty!=almostempty_ref) begin
                $display("almostempty=%0b , almostempty_ref=%0b , size=%0d at %0t",item.almostempty,almostempty_ref,data_mem.size(),$time);    
                end
            end
            else begin
                right_count = right_count+1;
            end
            end
        endtask

        task reference_model();
        if (!item.rst_n) begin
            full_ref=0;
            almostfull_ref=0;
            empty_ref=1;
            almostempty_ref=0;
            overflow_ref=0;
            underflow_ref=0;
            data_mem.delete();
            wr_ack_ref=0;
            next_read=0;
            next_write=0;
        end
        else
        begin
            size=data_mem.size();
            // read
            if (item.rd_en && size>0) begin
                data_out_ref=data_mem.pop_front();
            end

             if (item.wr_en && size<8) begin
                data_mem.push_back(item.data_in);
                wr_ack_ref=1;
            end
            else
            begin
                wr_ack_ref=0;
            end
            if(item.wr_en&&next_write)
            begin
                overflow_ref=1;
            end
            else begin
                overflow_ref=0;
            end
            if(item.rd_en&&next_read)
            begin
                underflow_ref=1;
            end
            else begin
                underflow_ref=0;
            end
            if (data_mem.size==7) begin
                almostfull_ref=1;
            end
            else begin
                almostfull_ref=0;
            end
            if (data_mem.size==8) begin
                full_ref=1;
                next_write=1;
            end
            else begin
                full_ref=0;
                next_write=0;
            end
            if (data_mem.size==0) begin
                empty_ref=1;
                next_read=1;
            end
            else begin
                empty_ref=0;
                next_read=0;
            end
            if (data_mem.size==1) begin
                almostempty_ref=1;
            end
            else begin
                almostempty_ref=0;
            end
        end   
        endtask


	 //-----------------------reporting----------------------------
		function void report_phase(uvm_phase phase);
			super.report_phase(phase);
			`uvm_info("report_phase", $sformatf("Total Successful transaction: %0d",right_count), UVM_MEDIUM);
			`uvm_info("report_phase", $sformatf("Total Failed transaction: %0d",error_count), UVM_MEDIUM);
		endfunction

	endclass

endpackage