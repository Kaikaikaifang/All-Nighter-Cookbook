module gate (
    input  wire [7:0] data,
    input  wire       gate,
    output wire [7:0] q
);
  assign q = gate ? data : 8'b01111111;
endmodule
