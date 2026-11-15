module shiftrows (
    input  wire [7:0] i_state [0:3][0:3],
    output wire [7:0] o_state [0:3][0:3]
);
  assign o_state[0][0] = i_state[0][0];
  assign o_state[0][1] = i_state[0][1];
  assign o_state[0][2] = i_state[0][2];
  assign o_state[0][3] = i_state[0][3];

  assign o_state[1][0] = i_state[1][1];
  assign o_state[1][1] = i_state[1][2];
  assign o_state[1][2] = i_state[1][3];
  assign o_state[1][3] = i_state[1][0];

  assign o_state[2][0] = i_state[2][2];
  assign o_state[2][1] = i_state[2][3];
  assign o_state[2][2] = i_state[2][0];
  assign o_state[2][3] = i_state[2][1];

  assign o_state[3][0] = i_state[3][3];
  assign o_state[3][1] = i_state[3][0];
  assign o_state[3][2] = i_state[3][1];
  assign o_state[3][3] = i_state[3][2];
endmodule
