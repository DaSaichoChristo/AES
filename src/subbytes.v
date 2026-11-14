module subbytes (
    input  wire       clk,
    input  wire [7:0] i_state[0:3][0:3],
    output reg  [7:0] o_state[0:3][0:3],
    output reg        valid
);

  // parameters
  localparam STATE_FIRST  = 2'b00;
  localparam STATE_SECOND = 2'b01;
  localparam STATE_THIRD  = 2'b10;
  localparam STATE_FOURTH = 2'b11;

  // some declaration
  reg [1:0] state_in = STATE_FIRST;
  reg [1:0] state_d1 = STATE_FIRST;
  reg [1:0] state_out = STATE_FIRST;
  reg [7:0] in[3:0];
  wire [7:0] out[3:0];
  wire [3:0] valid_in = 4'b1111;

  // sbox instances
  sbox sbox0 (
      .clk(clk),
      .raddr(in[0]),
      .valid_in(valid_in[0]),
      .data_out(out[0])
  );
  sbox sbox1 (
      .clk(clk),
      .raddr(in[1]),
      .valid_in(valid_in[1]),
      .data_out(out[1])
  );
  sbox sbox2 (
      .clk(clk),
      .raddr(in[2]),
      .valid_in(valid_in[2]),
      .data_out(out[2])
  );
  sbox sbox3 (
      .clk(clk),
      .raddr(in[3]),
      .valid_in(valid_in[3]),
      .data_out(out[3])
  );

  // for inputs
  always @(posedge clk) begin
    for (integer r = 0; r < 4; r = r + 1) begin
      in[r] <= i_state[r][state_in];
    end
    state_in <= state_in + 1'b1;
  end

  // for outputs
  always @(posedge clk) begin
    // sbox latency is 2 cycles: 1 to register `in`, 1 for the BRAM read.
    state_d1  <= state_in;
    state_out <= state_d1;

    for (integer r = 0; r < 4; r = r + 1) begin
      o_state[r][state_out] <= out[r];
    end

    valid <= (state_out == STATE_FOURTH);
  end
endmodule
