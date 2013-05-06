module serial_loop (
  input [7:0] rx_data,
  input new_rx_data,
  output [7:0] tx_data,
  output new_tx_data
);

assign tx_data = rx_data;
assign new_tx_data = new_rx_data;

endmodule
