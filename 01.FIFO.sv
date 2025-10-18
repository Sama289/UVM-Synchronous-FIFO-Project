////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_if.DUT fifo_if);

	parameter FIFO_WIDTH = 16;
	parameter FIFO_DEPTH = 8;
	/*
	input [FIFO_WIDTH-1:0] data_in;
	input clk, rst_n, wr_en, rd_en;
	output reg [FIFO_WIDTH-1:0] data_out;
	output reg wr_ack, overflow;
	output reg full, empty, almostfull, almostempty, underflow;
	*/
	logic [fifo_if.FIFO_WIDTH-1:0] data_in;
	logic clk, rst_n, wr_en, rd_en;
	logic [fifo_if.FIFO_WIDTH-1:0] data_out;
	logic wr_ack, overflow;
	logic full, empty, almostfull, almostempty, underflow;
	 

	assign clk     = fifo_if.clk;
	assign data_in = fifo_if.data_in;
	assign rst_n   = fifo_if.rst_n;
	assign wr_en   = fifo_if.wr_en;
	assign rd_en   = fifo_if.rd_en;
	assign fifo_if.data_out = data_out;
	assign fifo_if.wr_ack = wr_ack;
	assign fifo_if.overflow = overflow;
	assign fifo_if.full = full;
	assign fifo_if.empty = empty; 
	assign fifo_if.almostfull = almostfull;
	assign fifo_if.almostempty = almostempty;
	assign fifo_if.underflow = underflow;
	//------------wires-----------------------------
 
	localparam max_fifo_addr = $clog2(FIFO_DEPTH);

	reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

	reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
	reg [max_fifo_addr:0] count;

  //------------------Write Operation-------------------------

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			wr_ptr <= 0;

			//-----> Bug 4 & 5: I added those lines for overflow & wr_ack bec reset resets all the signals related to write operation :D		
			overflow <= 0;  
			wr_ack <= 0;

		end
		else if (wr_en && count < FIFO_DEPTH) begin
			mem[wr_ptr] <= data_in;
			wr_ack <= 1;
			wr_ptr <= wr_ptr + 1;
			overflow <= 0;
		end
		else begin 
			wr_ack <= 0; 
			if (full & wr_en)
				overflow <= 1;
			else
				overflow <= 0;
		end
	end

 //------------------Read Operation-------------------------

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			rd_ptr <= 0;
			underflow <=0;   //------> Bug 2: i added this line because reset resets underflow
		end
		else if (rd_en && count != 0) begin
			data_out <= mem[rd_ptr];
			rd_ptr <= rd_ptr + 1;
			underflow <= 0;
		end
		else begin //----------> Bug 3 : this else branch i added to handle the underflow signal in a sequential manner (so i use non-blocking)
			if (empty && rd_en) begin	
			  underflow <= 1;

	        end
	        else     
		  	  underflow <= 0;

		end

	end


 //------------------Counter -------------------------

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count <= 0;
		end
		else begin
			if	( ({wr_en, rd_en} == 2'b10) && !full) 
				count <= count + 1;
			else if ( ({wr_en, rd_en} == 2'b01) && !empty)
				count <= count - 1;

			//----------> Bug 6 : this else branch i added to handle the counter incremenation If a read and write enables were high and the FIFO was empty
			else if ( ({wr_en, rd_en} == 2'b11) &&  empty)
				count <= count + 1;

			//----------> Bug 7 : this else branch i added to handle the counter decrementation If a read and write enables were high and the the FIFO was full.
			else if ( ({wr_en, rd_en} == 2'b11) &&  full)
				count <= count - 1;

		end
	end

	assign full = (count == FIFO_DEPTH)? 1 : 0;
	assign empty = (count == 0)? 1 : 0;

	///----------> Bug 1: underflow should be sequential //---should removed--> assign underflow = (empty && rd_en)? 1 : 0; 
	assign almostfull = (count == FIFO_DEPTH-1)? 1 : 0; // Bug 8 : fifo depth -2 --> fifo depth -1 
	assign almostempty = (count == 1)? 1 : 0;

 //-----------------------------------------------------------Assertions for DUT------------------------------------------------------


// just in case y3ny
endmodule