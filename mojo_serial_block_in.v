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
