`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2026 06:11:33 PM
// Design Name: 
// Module Name: uart_monitor
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


class uart_monitor;
    mailbox #(uart_transaction) mon2scb;
    virtual uart_if.MON vif;
    int baud_period = 8680;
    function new(mailbox #(uart_transaction) mon2scb,virtual uart_if.MON vif );
        this.mon2scb = mon2scb;
        this.vif = vif;
    endfunction
    
    task run();
        $display("[Monitor] Bắt đầu giám sát End-to-End (TX_O và RX Cờ lỗi) ĐỘC LẬP...");
        
        fork
            // ========================================================
            // LUỒNG 1: CHUYÊN BẮT DATA TỪ TX_O (Đã thêm khiên chống nhiễu)
            // ========================================================
            begin: wait_loopback_data
                forever begin
                    uart_transaction tr_data = new();
                    
                    // 1. CHỐT AN TOÀN: Ép Monitor đợi tx_o về trạng thái Rảnh (1) trước khi làm gì tiếp
                    wait(vif.tx_o == 1'b1); 
                    
                    // 2. Chờ sườn xuống (Bit START)
                    @(negedge vif.tx_o);
                    #(baud_period/2);
                    
                    // 3. Xác nhận lại chắc chắn đây là bit START (mức 0), không phải glitch
                    if(vif.tx_o == 1'b0) begin
                        for(int i = 0 ; i < 8 ; i++) begin
                            #(baud_period);
                            tr_data.data[i] = vif.tx_o;
                        end
                        #(baud_period); // Đợi qua bit STOP
                        
                        // 4. Lọc nốt rác: Đảm bảo bit STOP đúng chuẩn là mức 1
                        if (vif.tx_o == 1'b1) begin
                            tr_data.frame_error = 0;
                            $display("[Monitor] Nhan thanh cong data tu tx_o: %h", tr_data.data);
                            mon2scb.put(tr_data);
                        end else begin
                            $display("[Monitor] Canh bao: Bo qua goi tin do tx_o bi treo/nhieu o bit STOP!");
                        end
                    end
                end
            end
            begin: wait_drop_error
                forever begin
                    @(posedge vif.frame_error_o);
                    begin
                        uart_transaction tr_err = new();
                        tr_err.frame_error = 1;
                        tr_err.data = 8'h00;
                        $display("[Monitor] Phat hien co loi khung tu RX, goi tin da bi HUY.");
                        
                        mon2scb.put(tr_err);
                    end
                end
            end
        join_none
    endtask
endclass
