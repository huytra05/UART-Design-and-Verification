`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2026 09:49:03 AM
// Design Name: 
// Module Name: UART_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_TOP(
input rx_i,
input clk_i,
input rst_i,
output tx_o
    );
    //dây kết nối khối baud_gen
    wire s_tick_wire;
    //Dây kết nối tới UART_RX
    wire rx_done_wire;
    wire [7:0] rx_data_wire;
    //dây kết nối FIFO_RX
    wire rx_empty_wire;
    wire rx_full_wire;
    wire [7:0] data_bw_fifo;
    //dây kết nối UART_TX
    wire tx_done_wire ;   
    //dây kết nối FIFO_TX
    wire tx_full_wire;
    wire tx_empty_wire;
    wire [7:0] tx_data_wire;
    //dây dùng cho các gate logic
    wire rx_valid;
    wire tx_valid;
    wire tx_start_wire;
    wire en_transfer;
    wire frame_error_o;
    
    //logic kết nối
    assign rx_valid = ~rx_empty_wire;
    assign tx_valid = ~tx_full_wire;
    assign en_transfer = rx_valid & tx_valid;
    
    //logic kết nối UART_TX
    assign tx_start_wire = ~tx_empty_wire;
    //khối baud_gen
    BAUD_GEN u_baud_gen(
    .clk(clk_i),
    .rst(rst_i),
    .s_tick(s_tick_wire)
    );
    //khối uart_rx
    UART_RX u_uart_rx(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rx_i(rx_i),
    .s_tick_i(s_tick_wire),
    .rx_done_o(rx_done_wire),
    .data_o(rx_data_wire),
    .frame_error_o(frame_error_o)
    );
    //khối FIFO_rx
    FIFO_SYNCH fifo_rx(
    .clk(clk_i),
    .rst_i(rst_i),
    .wr(rx_done_wire),
    .data_in(rx_data_wire),
    .rd(en_transfer),
    .full(rx_full_wire),
    .empty(rx_empty_wire),
    .data_out(data_bw_fifo)
    );
    //khối fifo_tx
    FIFO_SYNCH fifo_tx(
    .clk(clk_i),
    .rst_i(rst_i),
    .wr(en_transfer),
    .data_in(data_bw_fifo),
    .rd(tx_done_wire),
    .full(tx_full_wire),
    .empty(tx_empty_wire),
    .data_out(tx_data_wire)
    );
    
    UART_TX uart_tx(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(tx_data_wire),
    .tx_start_i(tx_start_wire),
    .s_tick_i(s_tick_wire),
    .tx_done_o(tx_done_wire),
    .tx_o(tx_o)
    );
endmodule
