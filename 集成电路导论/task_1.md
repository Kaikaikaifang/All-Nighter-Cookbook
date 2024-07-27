> 实验一(难度C-75)：8bit异步复位、同步预置、带进位输出的同步计数器
> - 分别设计出异步复位、同步预置和使能计数状态，并通过 `ModelSim` 做出对应的波形

# 关键词

1. 8bit：这表示计数器是一个8位计数器，可以表示0到255的整数。
2. 异步复位：这表示计数器具有一个复位功能，当复位信号被激活时，计数器的输出立即被设置为0，而不考虑时钟信号。
3. 同步预置：这是计数器的一个特性，允许在时钟信号的上升沿将计数器的输出设置为某个预定义的值。
4. 带进位输出：这表示计数器在达到其最大值后会产生一个进位信号，这个信号可以用来触发其他设备或计数器。

# Verilog

```verilog
module sync_counter_with_carry(
    input clk,                // 时钟信号
    input reset,              // 异步复位信号
    input preset,             // 同步预置信号
    input [7:0] preset_value, // 同步预置值
    output reg [7:0] count,   // 计数器输出
    output reg carry          // 进位输出信号
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        // 异步复位：计数器值设为0
        count <= 8'b0;
        carry <= 1'b0;
    end else begin
        if (preset) begin
            // 同步预置：在时钟上升沿设置计数器为预置值
            count <= preset_value;
            carry <= 1'b0;
        end else begin
            // 正常计数操作
            if (count == 8'hFF) begin
                // 如果计数器达到最大值255，输出进位信号，并重置计数器
                count <= 8'b0;
                carry <= 1'b1;
            end else begin
                // 否则计数器正常增加
                count <= count + 1'b1;
                carry <= 1'b0;
            end
        end
    end
end

endmodule
```