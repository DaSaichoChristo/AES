module sbox (
    input wire clk,
    input wire [7:0] rd_addr,
    output reg [7:0] data_out,
    output reg valid_out
);

  wire [15:0] rdata;
  reg [7:0] raddr;
  reg [7:0] waddr;
  reg [15:0] mask;
  reg [15:0] wdata;
  reg rclke;
  reg re;
  reg wclke;
  reg we;
  reg req_pending;

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
    req_pending = 0;
  end

  always @(posedge clk) begin
    raddr <= rd_addr;
    // i added this step because the bram of ice40 is synchronized.
    // therefore, it will always have one clock latency between raddr being inputed and the rdata being outputted.
    req_pending <= 1'b1;
    valid_out <= req_pending;
    data_out <= rdata[7:0];
  end
endmodule
