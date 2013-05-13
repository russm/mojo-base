module mojo_serial_block_out #(
    parameter BLOCK_BYTES = 1
)(
  input clk,
  input rst,
  input tx_busy,
  output [7:0] tx_data,
  output new_tx_data,
  input [(BLOCK_BYTES*8)-1:0] tx_block,
  input new_tx_block
);

parameter BLOCK_BITS = BLOCK_BYTES*8;
parameter COUNTER_BITS = $clog2(BLOCK_BYTES)+1;
parameter COUNTER_TOP_BIT = COUNTER_BITS-1;
 
reg [BLOCK_BITS-1:0] tx_block_q;
wire [BLOCK_BITS-1:0] tx_block_d;
reg [COUNTER_TOP_BIT:0] tx_remaining_q = {COUNTER_BITS{1'b1}};
wire [COUNTER_TOP_BIT:0] tx_remaining_d;

assign tx_data = tx_block_q[7:0];
assign tx_block_d = {tx_block_q[BLOCK_BITS-1-8:0], tx_block_q[BLOCK_BITS-1:BLOCK_BITS-8]};
assign tx_remaining_d = tx_remaining_q - 1'b1;

reg new_tx_data_q;
assign new_tx_data = new_tx_data_q;

always @(posedge clk) begin
  if (rst) begin
    tx_remaining_q <= {COUNTER_BITS{1'b1}};
  end else if (new_tx_block) begin
    tx_block_q <= tx_block;
    tx_remaining_q <= BLOCK_BYTES-1;
  end else if (!tx_remaining_q[COUNTER_TOP_BIT] && !tx_busy) begin
    tx_block_q <= tx_block_d;
    tx_remaining_q <= tx_remaining_d;
  end
  new_tx_data_q <= !tx_remaining_q[COUNTER_TOP_BIT] && !tx_busy;
end

endmodule
