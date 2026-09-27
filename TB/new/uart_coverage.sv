`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2026 12:39:00 PM
// Design Name: 
// Module Name: uart_coverage
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


class uart_coverage;
    mailbox #(uart_transaction) gen2cov_mbx;
    uart_transaction tr;
    
    covergroup uart_cg;
        cp_data: coverpoint tr.data {
            bins data_00 = {8'h00};
            bins data_FF = {8'hFF};
            bins data_mid[4] = {[8'h01 : 8'hFE]};
        }
        cp_frame_error: coverpoint tr.frame_error{
            bins no_error = {1'b0};
            bins has_error = {1'b1};
        }
        cp_glitch: coverpoint tr.glitch_start{
            bins no_glitch = {1'b0};
            bins has_glitch = {1'b1};
        }
        
        cross_data_error: cross cp_data , cp_frame_error;
        cross_err_glitch: cross cp_frame_error, cp_glitch;
    endgroup
    function new(mailbox #(uart_transaction) mbx);
        this.gen2cov_mbx = mbx;
        uart_cg = new();
    endfunction
    
    task run();
        $display("[Coverage] Bắt đầu thu thập độ phủ...");
        forever begin
            gen2cov_mbx.get(tr);
            uart_cg.sample();
        end
    endtask
    function void display_cov();
        real cov_score;
        cov_score = uart_cg.get_inst_coverage();
        $display("==================================================");
        $display("[COVERAGE REPORT] Tỷ lệ bao phủ (Coverage): %0.2f %%", cov_score);
        $display("==================================================");
    endfunction
    
endclass
