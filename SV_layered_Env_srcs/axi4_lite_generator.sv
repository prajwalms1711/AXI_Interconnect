`ifndef AXI4_LITE_GENERATOR_SV
`define AXI4_LITE_GENERATOR_SV

`include "axi4_lite_transaction.sv"

class axi4_lite_generator;
    mailbox #(axi4_lite_transaction) gen2drv_mb; // Mailbox to send transactions to driver
    int num_transactions; // Number of transactions to generate

    // Constructor
    function new(mailbox #(axi4_lite_transaction) gen2drv_mb, int num_transactions = 10);
        this.gen2drv_mb = gen2drv_mb;
        this.num_transactions = num_transactions;
    endfunction

    // Main run task for the generator
    task run();
        axi4_lite_transaction tr;
        repeat (num_transactions) begin
            tr = new();
            if (!tr.randomize()) begin
                $error("[Generator] at %0t Failed to randomize transaction.", $time);
            end
            $display("[Generator] at %0t Generated %s transaction. Addr: 0x%0h", $time, tr.kind.name(), tr.addr);
            gen2drv_mb.put(tr); // Send transaction to driver
            // Add a small delay to allow DUT to process
            #70;
        end
        //$display("[%0t] Generator: Finished generating %0d transactions.", $time, num_transactions);
    endtask

endclass

`endif