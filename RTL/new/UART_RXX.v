`timescale 1ns / 1ps

module UART_RX(
    input clk_i,
    input rst_i,
    input rx_i,
    input s_tick_i,
    output reg rx_done_o,
    output reg [7:0] data_o,
    output reg frame_error_o
);  
    localparam IDLE      = 3'd0;
    localparam START     = 3'd1;
    localparam DATA      = 3'd2;
    localparam STOP      = 3'd3;
    localparam DONE      = 3'd4;
    localparam WAIT_IDLE = 3'd5; // [FIX 1] Bổ sung trạng thái chờ phục hồi đường dây

    reg [2:0] state;
    
    reg rx_sync1, rx_sync2;
    
    // khối đồng bộ tín hiệu rx
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            rx_sync1 <= 1'd1; 
            rx_sync2 <= 1'd1;
        end
        else begin
            rx_sync1 <= rx_i;
            rx_sync2 <= rx_sync1;
        end
    end
    
    // đếm + lưu giữ liệu vào thanh ghi
    reg [7:0] data_reg;
    reg [2:0] data_cnt;
    reg [3:0] s_tick_cnt;
    
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            state <= IDLE;
            data_reg <= 0;
            rx_done_o <= 0;
            data_o <= 0;
            data_cnt <= 0;
            s_tick_cnt <= 0;
            frame_error_o <= 1'b0;
        end
        else begin
            rx_done_o <= 1'b0;
            
            case(state)
                IDLE: begin
                    frame_error_o <= 1'b0;
                    if(rx_sync2 == 1'b0) begin
                        state <= START;
                        s_tick_cnt <=0;
                    end
                end
                
                START: begin
                    if(s_tick_i) begin
                        if(s_tick_cnt == 4'd7) begin
                            if(rx_sync2 == 1'b0) begin
                                state <= DATA;
                                s_tick_cnt <= 0;
                                data_cnt <= 0;
                            end
                            else begin
                                state <= IDLE;
                            end
                        end
                        else begin
                            s_tick_cnt <= s_tick_cnt + 1;
                        end
                    end
                end
                
                DATA: begin
                    if(s_tick_i) begin
                        if(s_tick_cnt == 4'd15) begin
                            s_tick_cnt <= 0;
                            data_reg <= {rx_sync2 , data_reg[7:1]};
                            if(data_cnt == 3'd7) begin
                                state <= STOP;
                            end
                            else begin
                                data_cnt <= data_cnt + 1;
                            end
                        end
                        else begin
                            s_tick_cnt <= s_tick_cnt + 1;
                        end
                    end
                end
                
                STOP: begin
                    if(s_tick_i) begin
                        if(s_tick_cnt == 4'd15) begin
                            s_tick_cnt <= 0;
                            if(rx_sync2 == 1'b1) begin
                                frame_error_o <= 1'b0;
                            end 
                            else begin
                                frame_error_o <= 1'b1;
                            end
                            state <= DONE;
                        end
                        else begin
                            s_tick_cnt <= s_tick_cnt + 1'b1;
                        end        
                    end
                end
                
                DONE: begin
                    if(frame_error_o == 1'b0) begin
                        data_o <= data_reg;
                        rx_done_o <= 1'b1;
                    end
                    else begin
                        rx_done_o <= 1'b0;
                    end
                    state <= WAIT_IDLE; 
                end
                WAIT_IDLE: begin
                    if(rx_sync2 == 1'b1) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule