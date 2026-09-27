`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 02:34:52 PM
// Design Name: 
// Module Name: uart_scoreboard
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

class uart_scoreboard;
    mailbox #(uart_transaction) mon2scb;
    mailbox #(uart_transaction) gen2scb;
    
    // TÁCH 2 HÀNG ĐỢI ĐỘC LẬP (Không bao giờ kẹt)
    uart_transaction exp_data_queue[$];
    uart_transaction exp_err_queue[$];
    
    int passed_cnt = 0;
    int failed_cnt = 0;
    
    function new(mailbox #(uart_transaction) mon2scb,mailbox #(uart_transaction) gen2scb);
        this.mon2scb = mon2scb;
        this.gen2scb = gen2scb;
    endfunction
    
    task run();
        $display("[Scoreboard] RTL da fix. Khoi chay kien truc Dual-Queue O(1) sieu toc...");
        fork
            // LUỒNG 1
            forever begin
                uart_transaction exp_tr;
                gen2scb.get(exp_tr);
                
                if(exp_tr.frame_error == 1) begin
                    exp_tr.data = 8'h00; 
                    exp_err_queue.push_back(exp_tr);
                end else begin
                    exp_data_queue.push_back(exp_tr);
                end
            end
            
            // LUỒNG 2
            forever begin
                uart_transaction exp_tr;
                uart_transaction act_tr;
                
                mon2scb.get(act_tr);
                
                if (act_tr.frame_error == 1) begin
                    if (exp_err_queue.size() > 0) begin
                        exp_tr = exp_err_queue.pop_front();
                        compare_data(exp_tr, act_tr);
                    end else begin
                        $error("[Scoreboard] FATAL: DUT bao loi khung ao (khong co trong kich ban)!");
                        failed_cnt++;
                    end
                end 
                else begin
                    if (exp_data_queue.size() > 0) begin
                        exp_tr = exp_data_queue.pop_front();
                        compare_data(exp_tr, act_tr);
                    end else begin
                        $error("[Scoreboard] FATAL: DUT xuat data %h nhung khong co kich ban!", act_tr.data);
                        failed_cnt++;
                    end
                end
            end
        join_none
    endtask
    
    function void compare_data(uart_transaction exp_tr,uart_transaction act_tr);
        bit error_flag = 0;
        // xử lý khung lỗi
        if(exp_tr.frame_error == 1) begin
            if(act_tr.frame_error == 1) begin
                $display("[Scoreboard] PASSED (Frame_Err): RX bat loi chuan. Khong xuat data hop le (%h).", exp_tr.data);
            end
            else begin
                $error("[Scoreboard] FAILED (Frame_Err): DUT khong bao co loi khung!");
                error_flag = 1;
            end
        end
        else begin
            if(act_tr.frame_error == 1) begin
                $error("[Scoreboard] FAILED: khung truyen binh thuong nhung dut lai bao Frame Error!");
                error_flag = 1;
            end
            else begin
                if(exp_tr.data == act_tr.data) begin
                    if(exp_tr.glitch_start) begin
                        $display("[Scoreboard] PASSED (Glitch): loc nhieu thanh cong. Data thu duoc: %h", act_tr.data);
                    end
                    else begin
                        $display("[Scoreboard] PASSED (Normal): Truyen nhan tot. Data thu duoc: %h", act_tr.data);
                    end
                end
                else begin
                    $error("[Scoreboard] FAILED (Data): Ky vong: %h | Thuc te: %h | Test Glitch: %b",exp_tr.data, act_tr.data, exp_tr.glitch_start);
                    error_flag = 1;
                end
            end
        end
        // cập nhập điểm
        if (error_flag) failed_cnt++;
        else passed_cnt++;
    endfunction
    
    function void report();
        $display("----------------------------------------");
        $display("         BAO CAO MO PHONH UART          ");
        $display("----------------------------------------");
        $display(" Goi tin PASSED : %0d", passed_cnt);
        $display(" Goi tin FAILED : %0d", failed_cnt);
        $display("----------------------------------------");
    endfunction
    
endclass