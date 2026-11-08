module sbox (
    input wire clk,
    input wire [7:0] rd_addr,
    input wire valid_in,
    output reg [7:0] data_out,
    output wire valid_out
);
  // I asserted 3 latency because
  // 1 clock cycle to assign rd_addr to raddr
  // 1 clock cycle for rdata to be populated
  // 1 clock cycle to assign data_out to rdata
  localparam LAT = 3;

  wire [15:0] rdata;
  reg [7:0] raddr;
  reg [7:0] waddr;
  reg [15:0] mask;
  reg [15:0] wdata;
  reg [LAT-1:0] valid_pipe;
  reg rclke;
  reg re;
  reg wclke;
  reg we;

  SB_RAM40_4K #(
      .INIT_FILE("../common/sbox.mem")
  ) SB_RAM40_4K_inst (
      .RDATA(rdata),
      .RADDR(raddr),
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

  initial begin
    raddr = 0;
    waddr = 0;
    mask = 0;  //active low
    wdata = 0;
    re = 1;
    wclke = 1;
    we = 0;
    rclke = 1;
    valid_pipe = {LAT{1'b0}};
  end

  always @(posedge clk) begin
    valid_pipe <= {valid_pipe[LAT-2:0], valid_in};
  end

  assign valid_out = valid_pipe[LAT-1];

  always @(posedge clk) begin
    raddr <= rd_addr;

    data_out <= rdata[7:0];
  end
endmodule
