module sbox (
    input wire clk,
    input wire [7:0] raddr,
    input wire valid_in,
    output wire [7:0] data_out,
    output wire valid_out
);
  // I asserted 2 latency because
  // 1 clock cycle to assign rd_addr to raddr
  // 1 clock cycle for rdata to be populated
  localparam LAT = 1;

  wire [15:0] rdata;
  reg [7:0] waddr = 0;
  reg [15:0] mask = 0;
  reg [15:0] wdata = 0;
  reg [LAT-1:0] valid_pipe = {LAT{1'b0}};
  reg rclke = 1;
  reg re = 1;
  reg wclke = 1;
  reg we = 0;

  SB_RAM40_4K #(
      .INIT_FILE("../common/sbox.mem")
  ) SB_RAM40_4K_inst (
      .RDATA(rdata),
      .RADDR({3'b0, raddr}),
      .WADDR(waddr),
      .MASK(mask),
      .WDATA(wdata),
      .RCLKE(rclke),
      .RCLK(clk),
      .RE(re),
      .WCLKE(wclke),
      .WCLK(clk),
      .WE(we)
  );

  always @(posedge clk) begin
    valid_pipe <= (valid_pipe << 1) | valid_in;
  end

  assign valid_out = valid_pipe[LAT-1];

  assign data_out  = rdata[7:0];
endmodule
