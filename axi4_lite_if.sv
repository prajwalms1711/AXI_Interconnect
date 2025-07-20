`ifndef AXI4_LITE_INTERFACE_SV
`define AXI4_LITE_INTERFACE_SV

interface axi4_lite_if (input bit ACLK, input bit ARESETN);

    // Write address channel
    logic [7:0]  AWADDR;
    logic        AWVALID;
    logic        AWREADY;

    // Write data channel
    logic [31:0] WDATA;
    logic [3:0]  WSTRB;
    logic        WVALID;
    logic        WREADY;

    // Write response channel
    logic [1:0]  BRESP;
    logic        BVALID;
    logic        BREADY;

    // Read address channel
    logic [7:0]  ARADDR;
    logic        ARVALID;
    logic        ARREADY;

    // Read data channel
    logic [31:0] RDATA;
    logic [1:0]  RRESP;
    logic        RVALID;
    logic        RREADY;

    // Clocking block for synchronous sampling
    // This default is for the 'tb' modport, which acts as a master.
    // Master drives outputs, samples inputs.
    clocking cb @(posedge ACLK);
        default input #1step output #1; // Sample inputs after 1 step, drive outputs 1 cycle before
        
        // Master (Testbench) drives these
        output AWVALID, AWADDR, WVALID, WDATA, WSTRB, BREADY, ARVALID, ARADDR, RREADY;
        // Slave (DUT) drives these
        input AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID;
    endclocking

    // Clocking block for the Monitor
    // The Monitor observes signals, so its perspective is different.
    // It inputs what the Driver outputs (AWVALID, AWADDR, etc.)
    // It inputs what the DUT outputs (AWREADY, RDATA, etc.)
    clocking mon_cb @(posedge ACLK);
        default input #1step; // Monitor samples inputs
        
        // Signals driven by the Driver (inputs to DUT, observed by Monitor)
        input AWVALID, AWADDR, WVALID, WDATA, WSTRB, BREADY, ARVALID, ARADDR, RREADY;
        // Signals driven by the DUT (outputs from DUT, observed by Monitor)
        input AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID;
    endclocking


    // Modport for the Design Under Test (DUT)
    modport dut (
        input ACLK, ARESETN,
        input AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,
        output AWREADY, WREADY, BRESP, BVALID, RDATA, RRESP, RVALID
    );

    // Modport for the Testbench (TB)
    modport tb (
        input ACLK, ARESETN,
        output AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,
        input AWREADY, WREADY, BRESP, BVALID, RDATA, RRESP, RVALID,
        clocking cb // Use 'cb' for driver/generator
    );
    
    // Modport for the Monitor
    modport monitor (
        input ACLK, ARESETN,
        input AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,
        input AWREADY, WREADY, BRESP, BVALID, RDATA, RRESP, RVALID,
        clocking mon_cb // Use 'mon_cb' for monitor
    );
// Inside axi4_lite_if
    property awvalid_awready_pulse;
      @(posedge ACLK) disable iff (!ARESETN)
            AWVALID |-> ##[1:$] AWREADY;
    endproperty
    
    awvalid_awready_check: assert property (awvalid_awready_pulse)
      $display("Assertion Passed !!!");
      else $error("AWVALID was asserted but AWREADY not seen on next cycle!");

endinterface

`endif 