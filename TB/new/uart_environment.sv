`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2026 10:32:18 AM
// Design Name: 
// Module Name: uart_environment
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


class uart_environment;
    uart_generator gen;
    uart_driver drv;
    uart_monitor mon;
    uart_scoreboard scb;
    uart_coverage cov;
    
    mailbox #(uart_transaction) gen2scb;
    mailbox #(uart_transaction) gen2drv;
    mailbox #(uart_transaction) mon2scb;
    mailbox #(uart_transaction) gen2cov_mbx;
    
    virtual uart_if vif;
    
    function new(virtual uart_if vif);
        this.vif = vif;
        
        gen2scb = new();
        gen2drv = new();
        mon2scb = new();
        gen2cov_mbx = new();
        
        gen = new(gen2drv,gen2scb,3000,gen2cov_mbx);
        drv = new(gen2drv ,vif);
        mon = new(mon2scb,vif);
        scb = new(mon2scb,gen2scb);
        cov = new(gen2cov_mbx);
    endfunction
    
    task run();
        $display("==================================================");
        $display("[Environment] BAT DAU CHAY HE THONG TESTBENCH");
        $display("==================================================");
        drv.reset_dut();
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
            cov.run();
        join_any
        $display("[Environment] Generator đa truyen xong data. Dang cho hoan tat goi cuoi...");
        wait(scb.exp_data_queue.size() == 0 && scb.exp_err_queue.size() == 0);
        #1000;  
        scb.report();
        cov.display_cov();
        $display("Ket thuc mo phong");
        $finish;
    endtask
     
endclass
