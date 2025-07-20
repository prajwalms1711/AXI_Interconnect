`ifndef AXI4_LITE_SCOREBOARD_SV
`define AXI4_LITE_SCOREBOARD_SV

`include "axi4_lite_transaction.sv"

class axi4_lite_scoreboard;
    mailbox #(axi4_lite_transaction) drv2sb_mb; // Mailbox to receive transactions from driver
    mailbox #(axi4_lite_transaction) mon2sb_mb; // Mailbox to receive transactions from monitor

    // Reference memory model for expected data
    // Matches the DUT's memory structure (two 128x32 memories)
    logic [31:0] ref_mem_slave0 [0:127];
    logic [31:0] ref_mem_slave1 [0:127];

    // Queue to store outstanding write transactions for response matching
    axi4_lite_transaction outstanding_writes[$];

    // Constructor
    function new(mailbox #(axi4_lite_transaction) drv2sb_mb, mailbox #(axi4_lite_transaction) mon2sb_mb);
        this.drv2sb_mb = drv2sb_mb;
        this.mon2sb_mb = mon2sb_mb;
        // Initialize reference memories to 0
        foreach (ref_mem_slave0[i]) ref_mem_slave0[i] = 32'h0;
        foreach (ref_mem_slave1[i]) ref_mem_slave1[i] = 32'h0;
    endfunction

    // Task to process transactions from the driver (expected)
    task process_driver_transactions();
        forever begin
            axi4_lite_transaction drv_tr;
            drv2sb_mb.get(drv_tr); // Get transaction from driver

            $display("[Scoreboard] at %0t Received expected transaction from Driver. %s, Addr: 0x%0h", $time, drv_tr.kind.name(), drv_tr.addr);

            if (drv_tr.kind == axi4_lite_transaction::WRITE) begin
                // Predict expected memory state based on write transaction
                bit slave_select = (drv_tr.addr <= 8'h7F) ? 1'b0 : 1'b1;
                bit [6:0] mem_addr = drv_tr.addr[6:0];

                if (!slave_select) begin // Slave 0
                    if (drv_tr.wstrb[0]) ref_mem_slave0[mem_addr][7:0]   = drv_tr.wdata[7:0];
                    if (drv_tr.wstrb[1]) ref_mem_slave0[mem_addr][15:8]  = drv_tr.wdata[15:8];
                    if (drv_tr.wstrb[2]) ref_mem_slave0[mem_addr][23:16] = drv_tr.wdata[23:16];
                    if (drv_tr.wstrb[3]) ref_mem_slave0[mem_addr][31:24] = drv_tr.wdata[31:24];
                end else begin // Slave 1
                    if (drv_tr.wstrb[0]) ref_mem_slave1[mem_addr][7:0]   = drv_tr.wdata[7:0];
                    if (drv_tr.wstrb[1]) ref_mem_slave1[mem_addr][15:8]  = drv_tr.wdata[15:8];
                    if (drv_tr.wstrb[2]) ref_mem_slave1[mem_addr][23:16] = drv_tr.wdata[23:16];
                    if (drv_tr.wstrb[3]) ref_mem_slave1[mem_addr][31:24] = drv_tr.wdata[31:24];
                end
                // Add to outstanding writes queue for later response checking
                outstanding_writes.push_back(drv_tr);
            end else begin // READ
                // For read, the driver transaction already contains the expected read data
                // This transaction will be matched against a monitored read
            end
        end
    endtask

    // Task to process transactions from the monitor (actual)
    task process_monitor_transactions();
        forever begin
            axi4_lite_transaction mon_tr;
            mon2sb_mb.get(mon_tr); // Get transaction from monitor

            $display("[Scoreboard] at %0t Received actual transaction from Monitor. %s, Addr: 0x%0h", $time, mon_tr.kind.name(), mon_tr.addr);

            if (mon_tr.kind == axi4_lite_transaction::WRITE) begin
                // Match the write response with an outstanding write transaction
                if (outstanding_writes.size() > 0) begin
                    axi4_lite_transaction expected_write_tr = outstanding_writes.pop_front();
                    if (mon_tr.addr == expected_write_tr.addr && mon_tr.bresp == 2'b00) begin // Assuming OKAY (2'b00) is expected
                        $display("[Scoreboard] at %0t WRITE transaction to 0x%0h verified. BRESP OKAY.", $time, mon_tr.addr);
                    end else begin
                        $error("[Scoreboard] at %0t WRITE transaction to 0x%0h FAILED. Expected BRESP 2'b00, Got %0b.", $time, mon_tr.addr, mon_tr.bresp);
                    end
                 end
             else 
                 begin
                    $error("[Scoreboard] at %0t Received unexpected WRITE response for Addr 0x%0h. No outstanding write.", $time, mon_tr.addr);
                end
            end else begin // READ
                // Compare actual read data with expected data from reference model
                bit slave_select = (mon_tr.addr <= 8'h7F) ? 1'b0 : 1'b1;
                bit [6:0] mem_addr = mon_tr.addr[6:0];
                logic [31:0] expected_rdata;

                if (!slave_select) begin // Slave 0
                    expected_rdata = ref_mem_slave0[mem_addr];
                end else begin // Slave 1
                    expected_rdata = ref_mem_slave1[mem_addr];
                end

                if (mon_tr.rdata == expected_rdata && mon_tr.rresp == 2'b00) begin // Assuming OKAY (2'b00) is expected
                    $display("[Scoreboard] at %0t READ transaction from 0x%0h verified. Expected: 0x%0h, Actual: 0x%0h, RRESP OKAY.",
                             $time, mon_tr.addr, expected_rdata, mon_tr.rdata);
                end else begin
                    $error("[Scoreboard] at %0t READ transaction from 0x%0h FAILED. Expected RData: 0x%0h, Actual RData: 0x%0h. Expected RRESP 2'b00, Got %0b.",
                           $time, mon_tr.addr, expected_rdata, mon_tr.rdata, mon_tr.rresp);
                end
            end
        end
    endtask

    // Main run task for the scoreboard
    task run();
        fork
            process_driver_transactions();
            process_monitor_transactions();
        join_none // Allow both processing tasks to run concurrently
    endtask

endclass

`endif
