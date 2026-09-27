`timescale 1ns / 1ps

module FIFO_SYNCH#(
    parameter DATA_WIDTH = 8, // ĐỘ RỘNG DỮ LIỆU
    parameter ADDR_WIDTH = 4  // ĐỘ SÂU FIFO
)(
    input clk,
    input rst_i,

    input wr,
    input [DATA_WIDTH-1 : 0] data_in,
    input rd,

    output full,
    output empty,
    output [DATA_WIDTH - 1 : 0] data_out
);
    localparam DEPTH = 1 << ADDR_WIDTH; // TÍNH TOÁN ĐỘ SÂU CỦA RAM, 16 THANH GHI
    
    // KHAI BÁO BỘ NHỚ
    reg [DATA_WIDTH - 1 : 0] ram[0 : DEPTH - 1];
    reg [ADDR_WIDTH - 1 : 0] wr_ptr , rd_ptr;
    reg full_reg , empty_reg ;
    wire rd_en , wr_en;
    wire [ADDR_WIDTH - 1 : 0] next_rdptr , next_wrptr;
    
    assign next_rdptr = rd_ptr + 1'b1;
    assign next_wrptr = wr_ptr + 1'b1;
    
    // --------------------------------------------------------
    // ĐIỂM THAY ĐỔI: Chuyển sang FWFT (First-Word-Fall-Through)
    // Đọc trực tiếp từ bộ nhớ bằng con trỏ đọc hiện tại.
    // Dữ liệu sẽ luôn sẵn sàng ở ngõ ra mà không cần chờ xung rd.
    assign data_out = ram[rd_ptr];
    // --------------------------------------------------------
    
    assign full = full_reg;
    assign empty = empty_reg;
    assign rd_en = rd && !empty;
    assign wr_en = wr && !full;
    
    always @(posedge clk or posedge rst_i) begin
         if(rst_i) begin
             full_reg <= 0;
             empty_reg <= 1;
             wr_ptr <= 0;
             rd_ptr <= 0;
         end
         else begin
             if(rd_en) begin
                 // Đã loại bỏ phép gán data_tmp ở đây
                 rd_ptr <= (rd_ptr == DEPTH - 1) ? 0 : next_rdptr;
             end
             
             if(wr_en) begin
                 ram[wr_ptr] <= data_in;
                 wr_ptr <= (wr_ptr == DEPTH - 1) ? 0 : next_wrptr;
             end
             
             // CẬP NHẬT CỜ
             if(rd_en && !wr_en) begin // chỉ đọc
                 full_reg <= 0;
                 if(next_rdptr == wr_ptr)
                     empty_reg <= 1;
             end
             if(!rd_en && wr_en) begin // chỉ ghi
                 empty_reg <= 0;
                 if(next_wrptr == rd_ptr) 
                     full_reg <= 1;
             end
         end
    end     
endmodule