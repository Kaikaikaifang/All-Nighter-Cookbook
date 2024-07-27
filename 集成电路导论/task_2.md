> 实验二(难度 B-85)：深度为1024、数据位宽为 8bit 的同步 FIFO
> - 设计出同步 FIFO 的写数据操作、读数据操作以及 FIFO 满和 FIFO 空的状态指示信号
> - 设计出写 FIFO、读 FIFO 和边读边写三种操作模式，并通过 ModelSim 做出对应的波形
# 概念

1. 同步 FIFO
	数据读取和写入使用相同的时钟频率
2. 类比循环队列理解

# 实现方案

根据 Full 与 Empty 状态的判断方式的不同，有以下几种实现形式：

## 方案1：留空

1. 指针声明
```verilog
reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
```

2. 空状态
```verilog
assign empty = (w_ptr == r_ptr);
```

3. 满状态
```verilog
assign full = ((w_ptr + 1'b1) == r_ptr);
```

## 方案2：进位

1. 指针声明

```verilog
parameter PTR_WIDTH = $clog2(DEPTH); 
reg [PTR_WIDTH:0] w_ptr, r_ptr;
```

> 指针位宽预留 1 位，目的是检查状态

```verilog
assign warp_around = (w_ptr[PTR_WIDTH] ^ r_ptr[PTR_WIDTH]);
```

2. 空状态

```verilog
assign empty = w_ptr == r_ptr;
```

3. 满状态

```verilog
assign full = (warp_around & (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]));
```

方案3：计数

1. 参数声明

```verilog
reg [$clog2(DEPTH):0] count;
```

2. 计数

```verilog
case({w_en,r_en})
2'b00, 2'b11: count <= count;
2'b01: count <= count - 1'b1;
2'b10: count <= count + 1'b1;
endcase
```

3. 空状态

```verilog
assign empty = (count == 0);
```

4. 满状态

```verilog
assign full = (count == DEPTH);
```

# Resource

- [Sync Fifo](https://vlsiverify.com/verilog/verilog-codes/synchronous-fifo/) 