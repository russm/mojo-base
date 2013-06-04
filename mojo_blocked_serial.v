module mojo_serial_block_in #(
    parameter BLOCK_BYTES = 1
)(
  input clk,
  input rst,
  input [7:0] rx_data,
  input new_rx_data,
  output [(BLOCK_BYTES*8)-1:0] rx_block,
  output new_rx_block
);

parameter BLOCK_BITS = BLOCK_BYTES*8;
parameter COUNTER_BITS = $clog2(BLOCK_BYTES)+1;
parameter COUNTER_TOP_BIT = COUNTER_BITS-1;
 
reg [BLOCK_BITS-1:0] rx_block_q;
wire [BLOCK_BITS-1:0] rx_block_d;
reg [COUNTER_TOP_BIT:0] rx_remaining_q = BLOCK_BYTES-1;
wire [COUNTER_TOP_BIT:0] rx_remaining_d;

assign rx_block = rx_block_q;
assign rx_block_d = {rx_block_q[BLOCK_BITS-1-8:0], rx_data[7:0]};
assign rx_remaining_d = rx_remaining_q - 1'b1;

assign new_rx_block = rx_remaining_q[COUNTER_TOP_BIT];

always @(posedge clk) begin
  if (rst) begin
    rx_remaining_q <= BLOCK_BYTES-1;
  end else if (new_rx_data) begin
    rx_block_q <= rx_block_d;
    rx_remaining_q <= rx_remaining_d;
  end else if (rx_remaining_q[COUNTER_TOP_BIT]) begin
    rx_remaining_q <= BLOCK_BYTES-1;
  end
end
 
endmodule



module mojo_serial_block_out #(
    parameter BLOCK_BYTES = 1
)(
  input clk,
  input rst,
  input tx_busy,
  output [7:0] tx_data,
  output new_tx_data,
  input [(BLOCK_BYTES*8)-1:0] tx_block,
  input new_tx_block,
  output tx_block_busy
);

parameter BLOCK_BITS = BLOCK_BYTES*8;
parameter COUNTER_BITS = $clog2(BLOCK_BYTES)+1;
parameter COUNTER_TOP_BIT = COUNTER_BITS-1;
 
reg [BLOCK_BITS-1:0] tx_block_q;
wire [BLOCK_BITS-1:0] tx_block_d;
reg [COUNTER_TOP_BIT:0] tx_remaining_q = {COUNTER_BITS{1'b1}};
wire [COUNTER_TOP_BIT:0] tx_remaining_d;

assign tx_block_busy = !tx_remaining_q[COUNTER_TOP_BIT];

assign tx_data = tx_block_q[7:0];
assign tx_block_d = {tx_block_q[BLOCK_BITS-1-8:0], tx_block_q[BLOCK_BITS-1:BLOCK_BITS-8]};
assign tx_remaining_d = tx_remaining_q - 1'b1;

reg new_tx_data_q;
assign new_tx_data = new_tx_data_q;

always @(posedge clk) begin
  if (rst) begin
    tx_remaining_q <= {COUNTER_BITS{1'b1}};
  end else if (new_tx_block && !tx_block_busy) begin
    tx_block_q <= tx_block;
    tx_remaining_q <= BLOCK_BYTES-1;
  end else if (tx_block_busy && !tx_busy) begin
    tx_block_q <= tx_block_d;
    tx_remaining_q <= tx_remaining_d;
  end
  new_tx_data_q <= tx_block_busy && !tx_busy;
end

endmodule
