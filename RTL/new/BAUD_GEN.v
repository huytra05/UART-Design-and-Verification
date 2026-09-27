`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2026 12:24:25 PM
// Design Name: 
// Module Name: BAUD_GEN
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


module BAUD_GEN
#(parameter CLK_FREQ = 100000000, // Tần số clk của hệ thống
  parameter BAUD_RATE = 115200 // tần số buad trên đường truyền mong muốn
)
(
input clk,
input rst,
output s_tick
);
// Tính toán hằng số chia tần
localparam integer DIVISOR = CLK_FREQ / (16 * BAUD_RATE);
localparam integer MAX_COUNT = DIVISOR - 1;

localparam integer COUNT_WIDTH = $clog2(DIVISOR);

reg [COUNT_WIDTH - 1: 0] count_reg;
reg s_tick_reg;
assign s_tick = s_tick_reg;

always @(posedge clk or posedge rst) begin
if(rst) begin
count_reg <= 0;
s_tick_reg <= 0;
end
else begin
if(count_reg == MAX_COUNT) begin
count_reg <= 0;
s_tick_reg <= 1;
end
else begin
count_reg <= count_reg + 1;
s_tick_reg <= 0;
end
end
end
endmodule
