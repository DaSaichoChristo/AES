module subbytes (
    input clk,
    input [127:0] in,
    output [127:0] out
);

  // parameters
  parameter STATE_FIRST  = 2'b00;
  parameter STATE_SECOND = 2'b01;
  parameter STATE_THIRD  = 2'b11;
  parameter STATE_FOURTH = 2'b10;

  reg [1:0] state_in;
  reg [1:0] state_out;

  // wiring
  //assign in_0  = in[31, 0];
  //assign in_1  = in[63, 32];
  //assign in_2  = in[95, 64];
  //assign in_3  = in[127, 96];
  //assign out_0 = out[31, 0];
  //assign out_1 = out[63, 32];
  //assign out_2 = out[95, 64];
  //assign out_3 = out[127, 96];

  initial begin
    state_in  = STATE_FIRST;
    state_out = STATE_FIRST;
  end

endmodule

