import FIFO_shared_pkg::*;

module fifo_sva(FIFO_if.DUT fifo_if);

    logic [FIFO_WIDTH-1:0] data_in;
    logic clk, rst_n, wr_en, rd_en;
    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack, overflow;
    logic full, empty, almostfull, almostempty, underflow;
    localparam max_fifo_addr = $clog2(FIFO_DEPTH);

    assign clk         = fifo_if.clk;
    assign data_in     = fifo_if.data_in;
    assign rst_n       = fifo_if.rst_n;
    assign wr_en       = fifo_if.wr_en;
    assign rd_en       = fifo_if.rd_en;
    assign data_out    = fifo_if.data_out;
    assign wr_ack      = fifo_if.wr_ack;
    assign overflow    = fifo_if.overflow;
    assign full        = fifo_if.full;
    assign empty       = fifo_if.empty;
    assign almostfull  = fifo_if.almostfull;
    assign almostempty = fifo_if.almostempty;
    assign underflow   = fifo_if.underflow;

 //------------------------------------------------------------ASSERTIONS---------------------------------------------------------------
 
  `ifdef SIM

	// Assertions for Combinational Outputs
		always_comb begin
			if (DUT.count == 0) begin
				EMPTY_assertion : assert (empty && !full && !almostempty && !almostfull) else $display("EMPTY_assertion fail :( ");
				EMPTY_cover     : cover  (empty && !full && !almostempty && !almostfull)      $display("EMPTY_assertion Pass :D");
			end
			if (DUT.count == 1) begin
				ALMOSTEMPTY_assertion : assert (!empty && !full && almostempty && !almostfull) else $display("ALMOSTFULL_assertion fail :( ");
				ALMOSTEMPTY_cover     : cover  (!empty && !full && almostempty && !almostfull)      $display("ALMOSTFULL_assertion Pass :D");
			end
			if (DUT.count == FIFO_DEPTH-1) begin
				ALMOSTFULL_assertion : assert (!empty && !full && !almostempty && almostfull) else $display("ALMOSTFULL_assertion fail :( ");
				ALMOSTFULL_cover     : cover  (!empty && !full && !almostempty && almostfull)      $display("ALMOSTEMPTY_assertion Pass:D ");
			end
			if (DUT.count == FIFO_DEPTH) begin
				FULL_assertion : assert (!empty && full && !almostempty && !almostfull) else $display("FULL_assertion fail :( ");
				FULL_cover     : cover  (!empty && full && !almostempty && !almostfull)      $display("FULL_assertion Pass :D");
			end
		end

	// Assertions for Overflow and Underflow
		property OVERFLOW_FIFO;
			@(posedge clk) disable iff (!rst_n) (full & wr_en) |=> (overflow);
		endproperty

		property UNDERFLOW_FIFO;
			@(posedge clk) disable iff (!rst_n) (empty && rd_en) |=> (underflow);
		endproperty

	// Assertions for wr_ack
		property WR_ACK_HIGH;
			@(posedge clk) disable iff (!rst_n) (wr_en && (DUT.count < FIFO_DEPTH) && !full) |=> (wr_ack);
		endproperty

		property WR_ACK_LOW;
			@(posedge clk) disable iff (!rst_n) (wr_en && full) |=> (!wr_ack);
		endproperty

	// Assertions for The Counter
		property COUNT_0;
			@(posedge clk) (!rst_n) |=> (DUT.count == 0);
		endproperty

		property COUNT_INC_10;
			@(posedge clk) disable iff (!rst_n) (({wr_en, rd_en} == 2'b10) && !full) |=> (DUT.count == $past(DUT.count) + 1);
		endproperty

		property COUNT_INC_01;
			@(posedge clk) disable iff (!rst_n) (({wr_en, rd_en} == 2'b01) && !empty) |=> (DUT.count == $past(DUT.count) - 1);
		endproperty

		property COUNT_INC_11_WR;
			@(posedge clk) disable iff (!rst_n) (({wr_en, rd_en} == 2'b11) && empty) |=> (DUT.count == $past(DUT.count) + 1);
		endproperty

		property COUNT_INC_11_RD;
			@(posedge clk) disable iff (!rst_n) (({wr_en, rd_en} == 2'b11) && full) |=> (DUT.count == $past(DUT.count) - 1);
		endproperty

		property COUNT_LAT;
			@(posedge clk) disable iff (!rst_n) ((({wr_en, rd_en} == 2'b01) && empty) || (({wr_en, rd_en} == 2'b10) && full)) |=> (DUT.count == $past(DUT.count));
		endproperty

	// Assertions for Pointers
		property PTR_RST;
			@(posedge clk) (!rst_n) |=> (~DUT.rd_ptr && ~DUT.wr_ptr);
		endproperty

		property RD_PTR;
			@(posedge clk) disable iff (!rst_n) (rd_en && (DUT.count != 0)) |=> (DUT.rd_ptr == ($past(DUT.rd_ptr) + 1) % FIFO_DEPTH);
		endproperty

		property WR_PTR;
			@(posedge clk) disable iff (!rst_n) (wr_en && (DUT.count < FIFO_DEPTH)) |=> (DUT.wr_ptr == ($past(DUT.wr_ptr) + 1) % FIFO_DEPTH);
		endproperty

	// Assert Properties
		OVERFLOW_assertion          : assert property (OVERFLOW_FIFO)    else $display("OVERFLOW_assertion");
		UNDERFLOW_assertion         : assert property (UNDERFLOW_FIFO)   else $display("UNDERFLOW_assertion");
		WR_ACK_HIGH_assertion       : assert property (WR_ACK_HIGH)      else $display("WR_ACK_HIGH_assertion");
		WR_ACK_LOW_assertion        : assert property (WR_ACK_LOW)       else $display("WR_ACK_LOW_assertion");
		COUNTER_0_assertion         : assert property (COUNT_0)          else $display("COUNTER_0_assertion");
		COUNTER_INC_10_assertion    : assert property (COUNT_INC_10)     else $display("COUNTER_INC_WR_assertion fail");
		COUNTER_INC_01_assertion    : assert property (COUNT_INC_01)     else $display("COUNTER_INC_WR_assertion fail");
		COUNTER_INC_11_WR_assertion : assert property (COUNT_INC_11_WR)  else $display("COUNTER_INC_WR_assertion fail");
		COUNTER_INC_11_RD_assertion : assert property (COUNT_INC_11_RD)  else $display("COUNTER_INC_WR_assertion fail");
		COUNTER_LAT_assertion       : assert property (COUNT_LAT)        else $display("COUNTER_LAT_assertion fail");
		PTR_RST_assertion           : assert property (PTR_RST)          else $display("PTR_RST_asssertion fail");
		RD_PTR_assertion            : assert property (RD_PTR)           else $display("RD_PTR_asssertion fail");
		WR_PTR_assertion            : assert property (WR_PTR)           else $display("WR_PTR_asssertion fail");

	// Cover Properties
		OVERFLOW_cover          : cover property (OVERFLOW_FIFO)    $display("OVERFLOW_assertion");
		UNDERFLOW_cover         : cover property (UNDERFLOW_FIFO)   $display("UNDERFLOW_assertion");
		WR_ACK_HIGH_cover       : cover property (WR_ACK_HIGH)      $display("WR_ACK_HIGH_assertion");
		WR_ACK_LOW_cover        : cover property (WR_ACK_LOW)       $display("WR_ACK_LOW_assertion");
		COUNTER_0_cover         : cover property (COUNT_0)          $display("COUNTER_0_assertion");
		COUNTER_INC_10_cover    : cover property (COUNT_INC_10)     $display("COUNTER_INC_WR_assertion Pass");
		COUNTER_INC_01_cover    : cover property (COUNT_INC_01)     $display("COUNTER_INC_WR_assertion Pass");
		COUNTER_INC_11_WR_cover : cover property (COUNT_INC_11_WR)  $display("COUNTER_INC_WR_assertion Pass");
		COUNTER_INC_11_RD_cover : cover property (COUNT_INC_11_RD)  $display("COUNTER_INC_WR_assertion Pass");
		COUNTER_LAT_cover       : cover property (COUNT_LAT)        $display("COUNTER_LAT_assertion Pass");
		PTR_RST_cover           : cover property (PTR_RST)          $display("PTR_RST_asssertion pass");
		RD_PTR_cover            : cover property (RD_PTR)           $display("RD_PTR_asssertion pass");
		WR_PTR_cover            : cover property (WR_PTR)           $display("WR_PTR_asssertion pass");

 `endif

endmodule
