`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2026 12:24:10 PM
// Design Name: 
// Module Name: uart_generator
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

class uart_generator;
    mailbox #(uart_transaction) gen2drv;
    mailbox #(uart_transaction) gen2scb;
    mailbox #(uart_transaction) gen2cov;
    event ended;
    int test_count;
    
    function new(mailbox #(uart_transaction) gen2drv,mailbox #(uart_transaction) gen2scb,int test_count= 100,mailbox #(uart_transaction) gen2cov);
        this.gen2drv = gen2drv;
        this.gen2scb = gen2scb;
        this.test_count = test_count;
        this.gen2cov = gen2cov;
    endfunction
    
    task run();
        uart_transaction req;
        for(int i = 0 ; i < test_count;i++) begin
            req = new();
            if(!req.randomize()) begin
                $fatal("[Generator] Randomization failed at transaction %0d", i);
            end
            // giám sát log
            $display("------------------");
            req.display($sformatf("Generator - Pkt %0d",i));
            gen2drv.put(req.copy());
            gen2scb.put(req.copy());
            gen2cov.put(req.copy());
        end
        // generator đã tạo xong và gửi hết transaction vào mailbox
        -> ended;
    endtask
endclass
