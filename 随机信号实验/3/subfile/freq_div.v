module freq_div (
    input  wire clk,
    output reg  out2,
    output reg  out8,
    output reg  out16,
    output reg  out256
);

  reg [6:0] count;

  always @(posedge clk) begin
    count <= count + 1;
    // 由于时钟上升沿的特性，只需反转电平即可完成二分频
    out2  <= ~out2;
    // 由于上升沿的特性，只需计数 N/2，即可完成 N 分频
    if (count[1:0] == 2'b11) begin  // 0, 1, 2, 3
      out8 <= ~out8;
    end
    if (count[2:0] == 3'b111) begin
      out16 <= ~out16;
    end
    if (count == 7'b1111111) begin
      out256 <= ~out256;
    end
  end

endmodule
