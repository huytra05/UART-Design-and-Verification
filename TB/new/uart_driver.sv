`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2026 04:13:16 PM
// Design Name: 
// Module Name: uart_driver
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

class uart_driver;
    mailbox #(uart_transaction) gen2drv;
    virtual uart_if.DRV vif;
    int baud_period =8680;
    
    function new(mailbox #(uart_transaction) gen2drv,virtual uart_if.DRV vif);
        this.gen2drv = gen2drv;
        this.vif = vif;
    endfunction
    task reset_dut();
        $display("[Driver] Bat dau reset phan cung...");
        vif.rx_i <= 1;
        vif.rst_i <= 1;
        repeat(5) @(posedge vif.clk_i);
        vif.rst_i <= 0;
        $display("[Driver] Hoan tat reset phan cung.");
    endtask
    
    task run();
        forever begin
            uart_transaction req;
            gen2drv.get(req);
            // chờ khoảng idle_delay
            if(req.idle_delay > 0) begin
                vif.rx_i <= 1;
                #(req.idle_delay * baud_period);
            end
            // glitch_start
            if(req.glitch_start) begin
                vif.rx_i <= 0;
                #(baud_period/4);
                vif.rx_i <= 1;
                #(baud_period/2);
            end
            
            vif.rx_i <= 0;
            #(baud_period);
            for(int i = 0 ; i < 8 ; i++) begin
                vif.rx_i <= req.data[i];
                #(baud_period);
            end
            
            if(req.frame_error) begin
                vif.rx_i <= 0;
                #(baud_period);
                vif.rx_i <= 1;
                #(baud_period);
            end
            else begin
                vif.rx_i <= 1;
                #(baud_period);
            end
            req.display("Driver");
        end
    endtask
endclass
