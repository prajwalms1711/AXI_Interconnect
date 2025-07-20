`ifndef TOP_MODULE_SV
`define TOP_MODULE_SV

`include "axi4_lite_if.sv"
`include "axi4_lite_test.sv"
// Include your DUT module here
// `include "axi4_lite_1.sv" // Assuming your DUT is in axi4_lite_1.sv

module top_module;
    // Clock and Reset signals
    logic ACLK;
    logic ARESETN;

    // Instantiate the AXI4-Lite Interface
    axi4_lite_if axi_if(.ACLK(ACLK), .ARESETN(ARESETN));

    // Instantiate the Design Under Test (DUT)
    // Ensure the module name and port connections match your provided DUT
    axi4_lite_1 dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),

        // Write address channel
        .AWADDR(axi_if.AWADDR),
        .AWVALID(axi_if.AWVALID),
        .AWREADY(axi_if.AWREADY),

        // Write data channel
        .WDATA(axi_if.WDATA),
        .WSTRB(axi_if.WSTRB),
        .WVALID(axi_if.WVALID),
        .WREADY(axi_if.WREADY),

        // Write response channel
        .BRESP(axi_if.BRESP),
        .BVALID(axi_if.BVALID),
        .BREADY(axi_if.BREADY),

        // Read address channel
        .ARADDR(axi_if.ARADDR),
        .ARVALID(axi_if.ARVALID),
        .ARREADY(axi_if.ARREADY),

        // Read data channel
        .RDATA(axi_if.RDATA),
        .RRESP(axi_if.RRESP),
        .RVALID(axi_if.RVALID),
        .RREADY(axi_if.RREADY)
    );

    // Instantiate the Test Program
    axi4_lite_test tb_program(.vif(axi_if));

    // Clock generation
    initial begin
        ACLK = 0;
        forever #5 ACLK = !ACLK; // 10ns clock period (100 MHz)
    end

    // Reset generation
    initial begin
        ARESETN = 1'b0; // Assert reset
        #10;            // Hold reset for 2 clock cycles
        ARESETN = 1'b1; // De-assert reset
        $display("Top at %0t Reset released.", $time);
    end

endmodule

`endif // TOP_MODULE_SV