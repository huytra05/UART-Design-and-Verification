`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2026 10:24:35 PM
// Design Name: 
// Module Name: uart_transaction
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

class uart_transaction;
    rand bit [7:0] data;
    
    rand bit frame_error;
    rand bit glitch_start;
    
    rand int idle_delay;
    
    constraint c_data_patterns{
        data dist{
            8'h00 := 10,
            8'hFF := 10,
            8'hA5 := 10,
            8'h5A := 10,
            [8'h01:8'hFE] :/ 60
        };
    }
    
    constraint c_error{
        frame_error dist{0:=90,1:=10};
        glitch_start dist{0:=90,1:=10};
    }
    constraint c_idle_delay{
        idle_delay dist{
            0 := 30,
            [1:10] :/ 50,
            [11:30] :/ 20
        };
    }
    
    function void display(string name = "uart_transaction");
        $display("[%s] Data: %h | Idle wait: %0d baud | Frame_Err: %b | Glitch: %b", 
                  name, data, idle_delay, frame_error, glitch_start);
    endfunction
    
    function uart_transaction copy();
        uart_transaction temp = new();
        temp.data = this.data;
        temp.frame_error = this.frame_error;
        temp.glitch_start = this.glitch_start;
        temp.idle_delay = this.idle_delay;
        return temp;
    endfunction
    
    
endclass


