`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2026 10:21:25 AM
// Design Name: 
// Module Name: UART_TX
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


module UART_TX#(parameter N=8)(
input clk_i,
input rst_i,
input [N-1:0] data_i,
input tx_start_i,
input s_tick_i,
output reg tx_done_o,
output reg tx_o
    );
    reg [1:0] state;
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    reg [3:0] s_reg; // bộ đếm số tick
    reg [2:0] n_reg; // bộ đếm số bit
    reg [7:0] b_reg; // thanh ghi dịch dữ liệu
    
    always @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
    state <= IDLE;
    tx_done_o <= 0;
    s_reg <= 0;
    n_reg <= 0;
    b_reg <= 0;
    tx_o <= 1'b1;
    end
    else begin
    tx_done_o <= 1'b0;
    
    case(state)
    IDLE : begin
        tx_o <= 1'b1;
        if(tx_start_i == 1'b1 && tx_done_o == 1'b0) begin 
           state <= START;
           b_reg <= data_i;
           s_reg <= 0;
        end
    end
    START: begin
    tx_o <= 1'b0; 
    if(s_tick_i) begin
       if(s_reg == 4'd15) begin
          state <= DATA;
          s_reg <= 0; 
          n_reg <= 0; 
          end
       else begin
          s_reg <= s_reg + 1'b1;
          end
    end
    end
    DATA: begin
    tx_o <= b_reg[0];
    if(s_tick_i) begin
       if(s_reg == 4'd15) begin
          s_reg <= 0; //reset tick
          b_reg <= b_reg >> 1'b1; 
          if(n_reg == 7) begin
             state <= STOP;
          end
          else begin
          n_reg <= n_reg + 1'b1;
          end
       end
       else begin
           s_reg <= s_reg + 1'b1;
       end
     end
     end
     STOP: begin
     tx_o <= 1'b1; // kéo lên bit stop
     if(s_tick_i) begin
        if(s_reg == 4'd15) begin
           state <= IDLE;
           tx_done_o <= 1'b1;
        end else begin
            s_reg <= s_reg + 1'b1;
            end
        end
     end
     default: state <= IDLE;
     endcase
     end
     end
endmodule
