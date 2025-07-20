`ifndef AXI4_LITE_DRIVER_SV
`define AXI4_LITE_DRIVER_SV

`include "axi4_lite_if.sv"
`include "axi4_lite_transaction.sv"

class axi4_lite_driver;
    virtual axi4_lite_if.tb vif; // Virtual interface handle
    mailbox #(axi4_lite_transaction) drv_mb; // Mailbox to receive transactions from generator
    mailbox #(axi4_lite_transaction) drv2sb_mb; // Mailbox to send transactions to scoreboard

    // Constructor
    function new(virtual axi4_lite_if.tb vif, mailbox #(axi4_lite_transaction) drv_mb, mailbox #(axi4_lite_transaction) drv2sb_mb);
        this.vif = vif;
        this.drv_mb = drv_mb;
        this.drv2sb_mb = drv2sb_mb;
    endfunction

    // Task to drive AXI4-Lite write transaction
    task drive_write(axi4_lite_transaction tr);
        $display("[Driver] at %0t Driving WRITE transaction to DUT. Addr: 0x%0h, Data: 0x%0h, Strobe: 0x%0h", $time, tr.addr, tr.wdata, tr.wstrb);

        // Drive AW channel
        vif.cb.AWADDR <= tr.addr;
        vif.cb.AWVALID <= 1'b1;
        @(vif.cb); // Wait for clock edge
        while (!vif.cb.AWREADY) @(vif.cb); // Wait for AWREADY
        vif.cb.AWVALID <= 1'b0; // De-assert AWVALID

        // Drive W channel
        vif.cb.WDATA <= tr.wdata;
        vif.cb.WSTRB <= tr.wstrb;
        vif.cb.WVALID <= 1'b1;
        @(vif.cb); // Wait for clock edge
        while (!vif.cb.WREADY) @(vif.cb); // Wait for WREADY
        vif.cb.WVALID <= 1'b0; // De-assert WVALID

        // Wait for B channel response
        vif.cb.BREADY <= 1'b1;
        @(vif.cb); // Wait for clock edge
        while (!vif.cb.BVALID) @(vif.cb); // Wait for BVALID
        tr.bresp = vif.cb.BRESP; // Capture response
        vif.cb.BREADY <= 1'b0; // De-assert BREADY
        //$display("[%0t] Driver: Received WRITE response. BRESP: %0b", $time, tr.bresp);
    endtask

    // Task to drive AXI4-Lite read transaction
    task drive_read(axi4_lite_transaction tr);
        $display("[Driver] at %0t Driving READ transaction to DUT and Scoreboard --> Addr: 0x%0h", $time, tr.addr);

        // Drive AR channel
        vif.cb.ARADDR <= tr.addr;
        vif.cb.ARVALID <= 1'b1;
        @(vif.cb); // Wait for clock edge
        while (!vif.cb.ARREADY) @(vif.cb); // Wait for ARREADY
        vif.cb.ARVALID <= 1'b0; // De-assert ARVALID

        // Wait for R channel response
        vif.cb.RREADY <= 1'b1;
        @(vif.cb); // Wait for clock edge
        while (!vif.cb.RVALID) @(vif.cb); // Wait for RVALID
        tr.rdata = vif.cb.RDATA; // Capture read data
        tr.rresp = vif.cb.RRESP; // Capture read response
        vif.cb.RREADY <= 1'b0; // De-assert RREADY
        //$display("[%0t] Driver: Received READ response. RData: 0x%0h, RResp: %0b", $time, tr.rdata, tr.rresp);
    endtask

    // Main run task for the driver
    task run();
        forever begin
            axi4_lite_transaction tr;
            drv_mb.get(tr); // Get transaction from generator

            if (tr.kind == axi4_lite_transaction::WRITE) begin
                drive_write(tr);
            end else begin // READ
                drive_read(tr);
            end
            drv2sb_mb.put(tr); // Send transaction with captured responses to scoreboard
        end
    endtask

endclass

`endif 