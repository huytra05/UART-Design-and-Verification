`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2026 02:29:22 PM
// Design Name: 
// Module Name: tb_top
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


module tb_top;
    logic clk_i;
    
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end
    
    uart_if vif(clk_i);
    UART_TOP dut(
    .clk_i(clk_i),
    .rst_i(vif.rst_i),
    .rx_i(vif.rx_i),
    .tx_o(vif.tx_o)
    );
    
    assign vif.rx_done = dut.rx_done_wire;
    assign vif.frame_error_o = dut.frame_error_o;
    
    assign vif.rx_empty = dut.rx_empty_wire;
    assign vif.tx_full = dut.tx_full_wire;
    assign vif.en_transfer = dut.en_transfer;
    
    uart_environment env;
    
    initial begin
        vif.rst_i = 1;
        #50;
        vif.rst_i = 0;

        #10;
        env = new(vif);
        env.run();
        #455_730_000;
        $display("==================================================");
        $display("[TB_TOP] MÔ PHỎNG KẾT THÚC THÀNH CÔNG TẠI %0t", $time);
        $display("==================================================");
        $finish;
    end
    
endmodule
