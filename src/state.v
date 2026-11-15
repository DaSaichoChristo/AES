module state (
    input  [127:0] i_text,
    output [  7:0] state [0:3][0:3]
);
  assign state[0][0] = i_text[7:0];
  assign state[1][0] = i_text[15:8];
  assign state[2][0] = i_text[23:16];
  assign state[3][0] = i_text[31:24];

  assign state[0][1] = i_text[39:32];
  assign state[1][1] = i_text[47:40];
  assign state[2][1] = i_text[55:48];
  assign state[3][1] = i_text[63:56];

  assign state[0][2] = i_text[71:64];
  assign state[1][2] = i_text[79:72];
  assign state[2][2] = i_text[87:80];
  assign state[3][2] = i_text[95:88];

  assign state[0][3] = i_text[103:96];
  assign state[1][3] = i_text[111:104];
  assign state[2][3] = i_text[119:112];
  assign state[3][3] = i_text[127:120];
endmodule
