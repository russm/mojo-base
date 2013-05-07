module serial_loop (
  input wire [7:0] rx_data,
  input wire new_rx_data,
  output wire [7:0] tx_data,
  output wire new_tx_data
);

assign tx_data = rx_data;
assign new_tx_data = new_rx_data;

endmodule
