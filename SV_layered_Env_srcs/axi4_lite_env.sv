`ifndef AXI4_LITE_ENVIRONMENT_SV
`define AXI4_LITE_ENVIRONMENT_SV

`include "axi4_lite_if.sv"
`include "axi4_lite_generator.sv"
`include "axi4_lite_driver.sv"
`include "axi4_lite_monitor.sv"
`include "axi4_lite_scoreboard.sv"

class axi4_lite_env;
    virtual axi4_lite_if.tb vif; // Virtual interface handle

    axi4_lite_generator generator;
    axi4_lite_driver driver;
    axi4_lite_monitor monitor;
    axi4_lite_scoreboard scoreboard;

    // Mailboxes for communication between components
    mailbox #(axi4_lite_transaction) gen2drv_mb;
    mailbox #(axi4_lite_transaction) drv2sb_mb;
    mailbox #(axi4_lite_transaction) mon2sb_mb;

    // Constructor
    function new(virtual axi4_lite_if.tb vif);
        this.vif = vif;

        // Create mailboxes
        gen2drv_mb = new();
        drv2sb_mb = new();
        mon2sb_mb = new();

        // Instantiate components
        generator = new(gen2drv_mb);
        driver = new(vif, gen2drv_mb, drv2sb_mb);
        // Pass the monitor modport to the monitor
        monitor = new(vif, mon2sb_mb); 
        scoreboard = new(drv2sb_mb, mon2sb_mb);
    endfunction

    // Main run task for the environment
    task run();
        fork
            generator.run();
            driver.run();
            monitor.run();
            scoreboard.run();
        join_any // Wait for any component to finish (e.g., generator)
        // After generator finishes, allow some time for remaining transactions to propagate
        #1000;
        $display("[Environment] at %0t All components finished their main tasks.", $time);
    endtask

endclass

`endif