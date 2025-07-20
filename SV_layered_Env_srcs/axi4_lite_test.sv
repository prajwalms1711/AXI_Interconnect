`ifndef AXI4_LITE_TEST_SV
`define AXI4_LITE_TEST_SV

`include "axi4_lite_if.sv"
`include "axi4_lite_env.sv"

program axi4_lite_test (axi4_lite_if.tb vif);
    axi4_lite_env env;

    // Initial block to instantiate and run the environment
    initial begin
        $display("[%0t] Test: Starting AXI4-Lite Test.", $time);
        env = new(vif);
        env.run(); // Run the environment tasks
        $display("[%0t] Test: AXI4-Lite Test Finished.", $time);
        $finish; // End simulation
    end

endprogram

`endif // AXI4_LITE_TEST_SV