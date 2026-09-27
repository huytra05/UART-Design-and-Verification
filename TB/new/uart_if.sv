`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2026 09:59:16 PM
// Design Name: 
// Module Name: uart_if
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

interface uart_if(input logic clk_i);
    logic rx_i;
    logic rst_i;
    logic tx_o;
    
    logic rx_done;
    logic frame_error_o;
    
    logic rx_empty;
    logic tx_full;
    logic en_transfer;
    
    modport DUT(
        input clk_i,
        input rx_i,
        input rst_i,
        output tx_o,
        output rx_done,
        output frame_error_o
    );
    modport DRV(
        input clk_i,
        output rst_i,
        output rx_i
    );
    
    modport MON(
        input clk_i,
        input tx_o,
        input rst_i,
        input rx_i,
        input rx_done,
        input frame_error_o
    );
    // assertion 
    always @(rst_i or rx_i) begin
        if(rst_i) begin
            assert(rx_i == 1'b1)
            else $error("reset hoat dong ma rx_i khong len muc high");
        end
    end
    
    property p_frame_error_to_rx_done;
        @(posedge clk_i)
        frame_error_o |=> !rx_done;
    endproperty
    
    assert property(p_frame_error_to_rx_done)
    else $error("frame_error_o = 1 nhung tx_done van = 1 [FAILED]");
    
    always @(en_transfer or rx_empty or tx_full) begin
        assert #0(en_transfer == (!rx_empty && !tx_full))
        else $error(
            "[SVA] en_transfer sai: rx_empty=%b tx_full=%b en_transfer=%b",
            rx_empty,
            tx_full,
            en_transfer
        );
    end
    
    
endinterface

